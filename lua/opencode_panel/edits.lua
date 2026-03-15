local M = {}

local NS = vim.api.nvim_create_namespace("opencode_panel_pending_edits")

local state = {
  initialized = false,
  by_file = {},
  by_id = {},
  decisions = {},
}

local function normalize_path(path)
  if not path or path == "" then
    return nil
  end

  if path:sub(1, 1) == "/" or path:match("^%a:[/\\]") then
    return vim.uv.fs_realpath(path) or path
  end

  return vim.uv.fs_realpath(vim.fs.normalize(vim.fn.getcwd() .. "/" .. path)) or vim.fs.normalize(vim.fn.getcwd() .. "/" .. path)
end

local function ensure_highlights()
  vim.api.nvim_set_hl(0, "OpencodePanelEditPending", { bg = "#3d3224" })
  vim.api.nvim_set_hl(0, "OpencodePanelEditConflict", { bg = "#512c34" })
  vim.api.nvim_set_hl(0, "OpencodePanelEditVirtual", { fg = "#d4b483", bg = "#2a2218" })
  vim.api.nvim_set_hl(0, "OpencodePanelEditConflictVirtual", { fg = "#f3c7d2", bg = "#311a21" })
end

local function parse_count(value)
  if value == nil or value == "" then
    return 1
  end

  return tonumber(value) or 1
end

local function build_hunk_id(message_id, part_id, file_path, index)
  return table.concat({ message_id or "message", part_id or "part", file_path, tostring(index) }, "::")
end

local function finalize_hunk(hunks, current, file_path, message_id, part_id, index)
  if not current then
    return
  end

  local anchor_row
  if current.old_count == 0 then
    anchor_row = math.max(current.old_start, 0)
  else
    anchor_row = math.max(current.old_start - 1, 0)
  end

  local display_span = math.max(current.old_count, 1)
  table.insert(hunks, {
    id = build_hunk_id(message_id, part_id, file_path, index),
    file_path = file_path,
    message_id = message_id,
    part_id = part_id,
    index = index,
    old_start = current.old_start,
    old_count = current.old_count,
    new_start = current.new_start,
    new_count = current.new_count,
    old_lines = current.old_lines,
    new_lines = current.new_lines,
    anchor_row = anchor_row,
    display_span = display_span,
  })
end

local function parse_hunks(diff, file_path, message_id, part_id)
  local hunks = {}
  local current = nil
  local index = 0

  for line in (diff or ""):gmatch("[^\n]+") do
    local old_start, old_count, new_start, new_count = line:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")
    if old_start then
      finalize_hunk(hunks, current, file_path, message_id, part_id, index)
      index = index + 1
      current = {
        old_start = tonumber(old_start) or 0,
        old_count = old_count == "" and 1 or tonumber(old_count) or 0,
        new_start = tonumber(new_start) or 0,
        new_count = new_count == "" and 1 or tonumber(new_count) or 0,
        old_lines = {},
        new_lines = {},
      }
    elseif current then
      local prefix = line:sub(1, 1)
      local text = line:sub(2)
      if prefix == " " then
        table.insert(current.old_lines, text)
        table.insert(current.new_lines, text)
      elseif prefix == "-" then
        table.insert(current.old_lines, text)
      elseif prefix == "+" then
        table.insert(current.new_lines, text)
      end
    end
  end

  finalize_hunk(hunks, current, file_path, message_id, part_id, index)
  return hunks
end

local function get_loaded_bufnr(file_path)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
      local name = normalize_path(vim.api.nvim_buf_get_name(bufnr))
      if name == file_path then
        return bufnr
      end
    end
  end

  return nil
end

local function get_display_row(hunk, bufnr)
  if not bufnr or not hunk.extmark_id then
    return hunk.anchor_row, hunk.anchor_row + hunk.display_span
  end

  local ok, mark = pcall(vim.api.nvim_buf_get_extmark_by_id, bufnr, NS, hunk.extmark_id, { details = true })
  if not ok or not mark or #mark == 0 then
    return hunk.anchor_row, hunk.anchor_row + hunk.display_span
  end

  local details = mark[3] or {}
  local row = mark[1]
  local end_row = details.end_row or (row + hunk.display_span)
  return row, end_row
end

local function get_apply_range(hunk, bufnr)
  local row = get_display_row(hunk, bufnr)
  local start_row = row
  local end_row = row + hunk.old_count
  return start_row, end_row
end

local function delete_extmark(bufnr, hunk)
  if bufnr and hunk.extmark_id then
    pcall(vim.api.nvim_buf_del_extmark, bufnr, NS, hunk.extmark_id)
  end
  hunk.extmark_id = nil
end

local function hunk_status(hunk, bufnr)
  local decision = state.decisions[hunk.id]
  if decision then
    return decision
  end

  if not bufnr then
    return "pending"
  end

  local start_row, end_row = get_apply_range(hunk, bufnr)
  local current = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row, false)
  if vim.deep_equal(current, hunk.old_lines) then
    return "pending"
  end

  return "conflict"
end

local function upsert_extmark(bufnr, hunk, status)
  local row, end_row = get_display_row(hunk, bufnr)
  local pending = status ~= "conflict"
  local virt_text = pending and " AI patch pending" or " AI patch conflict"
  local hl_group = pending and "OpencodePanelEditPending" or "OpencodePanelEditConflict"
  local virt_hl = pending and "OpencodePanelEditVirtual" or "OpencodePanelEditConflictVirtual"

  hunk.extmark_id = vim.api.nvim_buf_set_extmark(bufnr, NS, row, 0, {
    id = hunk.extmark_id,
    end_row = end_row,
    hl_group = hl_group,
    hl_eol = true,
    virt_text = {
      { virt_text, virt_hl },
    },
    virt_text_pos = "eol",
    priority = 120,
    right_gravity = false,
    end_right_gravity = true,
  })
end

local function render_file(file_path)
  local file_state = state.by_file[file_path]
  if not file_state then
    return
  end

  local bufnr = get_loaded_bufnr(file_path)
  if not bufnr then
    return
  end

  for _, hunk in ipairs(file_state.hunks) do
    local status = hunk_status(hunk, bufnr)
    if status == "accepted" or status == "rejected" then
      delete_extmark(bufnr, hunk)
    else
      upsert_extmark(bufnr, hunk, status)
    end
  end
end

local function render_all()
  for file_path in pairs(state.by_file) do
    render_file(file_path)
  end
end

local function clear_stale_extmarks(previous)
  for hunk_id, hunk in pairs(previous or {}) do
    if not state.by_id[hunk_id] then
      local bufnr = get_loaded_bufnr(hunk.file_path)
      delete_extmark(bufnr, hunk)
    end
  end
end

local function build_file_entry(file_path)
  return {
    file_path = file_path,
    hunks = {},
  }
end

local function collect_files(messages)
  local files = {}
  local by_id = {}

  for _, message in ipairs(messages or {}) do
    local message_id = message.info and message.info.id
    for _, part in ipairs(message.parts or {}) do
      if part.type == "tool" and part.tool == "apply_patch" then
        local metadata = part.state and part.state.metadata or {}
        for _, file in ipairs(metadata.files or {}) do
          local file_path = normalize_path(file.filePath or file.relativePath)
          if file_path then
            files[file_path] = files[file_path] or build_file_entry(file_path)
            local hunks = parse_hunks(file.diff, file_path, message_id, part.id)
            for _, hunk in ipairs(hunks) do
              table.insert(files[file_path].hunks, hunk)
              by_id[hunk.id] = hunk
            end
          end
        end
      end
    end
  end

  return files, by_id
end

local function undecided_hunks()
  local hunks = {}
  for _, file_state in pairs(state.by_file) do
    for _, hunk in ipairs(file_state.hunks) do
      if not state.decisions[hunk.id] then
        table.insert(hunks, hunk)
      end
    end
  end
  return hunks
end

local function location_tuple(hunk)
  local bufnr = get_loaded_bufnr(hunk.file_path)
  local row = get_display_row(hunk, bufnr)
  return hunk.file_path, row
end

local function sort_hunks(hunks)
  table.sort(hunks, function(a, b)
    local file_a, row_a = location_tuple(a)
    local file_b, row_b = location_tuple(b)
    if file_a == file_b then
      return row_a < row_b
    end
    return file_a < file_b
  end)
  return hunks
end

local function find_current_hunk()
  local bufnr = vim.api.nvim_get_current_buf()
  local file_path = normalize_path(vim.api.nvim_buf_get_name(bufnr))
  if not file_path or file_path == "" then
    return nil, "Current buffer has no file path"
  end

  local file_state = state.by_file[file_path]
  if not file_state then
    return nil, "No pending AI edit for current file"
  end

  local cursor_row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local best_hunk = nil
  local best_distance = math.huge

  for _, hunk in ipairs(file_state.hunks) do
    if not state.decisions[hunk.id] then
      local row, end_row = get_display_row(hunk, bufnr)
      local distance
      if cursor_row >= row and cursor_row <= math.max(end_row - 1, row) then
        distance = 0
      elseif cursor_row < row then
        distance = row - cursor_row
      else
        distance = cursor_row - end_row
      end

      if distance < best_distance then
        best_distance = distance
        best_hunk = hunk
      end
    end
  end

  if not best_hunk then
    return nil, "No pending AI edit for current file"
  end

  return best_hunk
end

local function jump_to_hunk(hunk)
  vim.cmd("edit " .. vim.fn.fnameescape(hunk.file_path))
  render_file(hunk.file_path)
  local bufnr = vim.api.nvim_get_current_buf()
  local row = get_display_row(hunk, bufnr)
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
end

local function compact_preview(lines)
  local chunks = {}
  for _, line in ipairs(lines or {}) do
    local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
    if trimmed ~= "" then
      table.insert(chunks, trimmed)
    end
    if #chunks >= 2 then
      break
    end
  end

  if #chunks == 0 then
    return ""
  end

  return table.concat(chunks, " | ")
end

function M.setup()
  if state.initialized then
    return
  end

  state.initialized = true
  ensure_highlights()

  vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "TextChanged", "TextChangedI" }, {
    callback = function(args)
      local path = normalize_path(vim.api.nvim_buf_get_name(args.buf))
      if path and path ~= "" and state.by_file[path] then
        vim.schedule(function()
          render_file(path)
        end)
      end
    end,
  })
end

function M.update(messages)
  local previous_by_id = state.by_id
  local files, by_id = collect_files(messages)
  state.by_file = files
  state.by_id = by_id

  for hunk_id, hunk in pairs(state.by_id) do
    local previous = previous_by_id[hunk_id]
    if previous and previous.extmark_id then
      hunk.extmark_id = previous.extmark_id
    end
  end

  clear_stale_extmarks(previous_by_id)
  render_all()
  return state.by_file
end

function M.count_files()
  local seen = {}
  for _, hunk in ipairs(undecided_hunks()) do
    seen[hunk.file_path] = true
  end

  local count = 0
  for _ in pairs(seen) do
    count = count + 1
  end
  return count
end

function M.count_hunks()
  local count = 0
  for _, hunk in ipairs(undecided_hunks()) do
    if not state.decisions[hunk.id] then
      count = count + 1
    end
  end
  return count
end

function M.count_conflicts()
  local count = 0
  for _, hunk in ipairs(undecided_hunks()) do
    local bufnr = get_loaded_bufnr(hunk.file_path)
    if hunk_status(hunk, bufnr) == "conflict" then
      count = count + 1
    end
  end
  return count
end

function M.summary()
  local hunk_count = M.count_hunks()
  local file_count = M.count_files()
  local conflict_count = M.count_conflicts()
  if hunk_count == 0 then
    return "Edits: none pending"
  end

  local suffix = conflict_count > 0 and string.format(" | %d conflict%s", conflict_count, conflict_count == 1 and "" or "s")
    or ""
  return string.format("Edits: %d hunk%s across %d file%s%s", hunk_count, hunk_count == 1 and "" or "s", file_count, file_count == 1 and "" or "s", suffix)
end

function M.list_files()
  local seen = {}
  for _, hunk in ipairs(undecided_hunks()) do
    seen[hunk.file_path] = true
  end

  local files = {}
  for file_path in pairs(seen) do
    table.insert(files, file_path)
  end
  table.sort(files)
  return files
end

function M.list_hunks()
  local items = {}
  for _, hunk in ipairs(sort_hunks(undecided_hunks())) do
    local bufnr = get_loaded_bufnr(hunk.file_path)
    local status = hunk_status(hunk, bufnr)
    local row = get_display_row(hunk, bufnr)
    local preview = compact_preview(hunk.new_lines)
    local label = string.format("%s:%d", vim.fn.fnamemodify(hunk.file_path, ":~:."), row + 1)
    local detail = preview ~= "" and preview or (status == "conflict" and "conflict" or "pending edit")
    local highlight = status == "conflict" and "OpencodePanelPickerDanger" or "OpencodePanelPickerAccent"
    table.insert(items, {
      id = hunk.id,
      label = label,
      detail = detail,
      highlight = highlight,
      value = hunk.id,
    })
  end
  return items
end

function M.jump_to_id(hunk_id)
  local hunk = state.by_id[hunk_id]
  if not hunk or state.decisions[hunk_id] then
    return false, "AI edit is no longer pending"
  end

  jump_to_hunk(hunk)
  return true, "Jumped to AI edit"
end

function M.accept_current()
  local hunk, err = find_current_hunk()
  if not hunk then
    return false, err
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local status = hunk_status(hunk, bufnr)
  if status == "conflict" then
    render_file(hunk.file_path)
    return false, "Pending edit conflicts with current buffer changes"
  end

  local start_row, end_row = get_apply_range(hunk, bufnr)
  vim.api.nvim_buf_set_lines(bufnr, start_row, end_row, false, hunk.new_lines)
  state.decisions[hunk.id] = "accepted"
  delete_extmark(bufnr, hunk)
  render_file(hunk.file_path)
  return true, "Accepted AI edit"
end

function M.reject_current()
  local hunk, err = find_current_hunk()
  if not hunk then
    return false, err
  end

  local bufnr = vim.api.nvim_get_current_buf()
  state.decisions[hunk.id] = "rejected"
  delete_extmark(bufnr, hunk)
  render_file(hunk.file_path)
  return true, "Rejected AI edit"
end

function M.jump_next()
  local hunks = sort_hunks(undecided_hunks())
  if #hunks == 0 then
    return false, "No pending AI edits"
  end

  local file_path = normalize_path(vim.api.nvim_buf_get_name(0)) or ""
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1

  for _, hunk in ipairs(hunks) do
    local hunk_file, hunk_row = location_tuple(hunk)
    if hunk_file > file_path or (hunk_file == file_path and hunk_row > row) then
      jump_to_hunk(hunk)
      return true, "Jumped to next AI edit"
    end
  end

  jump_to_hunk(hunks[1])
  return true, "Jumped to next AI edit"
end

function M.jump_prev()
  local hunks = sort_hunks(undecided_hunks())
  if #hunks == 0 then
    return false, "No pending AI edits"
  end

  local file_path = normalize_path(vim.api.nvim_buf_get_name(0)) or ""
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1

  for index = #hunks, 1, -1 do
    local hunk = hunks[index]
    local hunk_file, hunk_row = location_tuple(hunk)
    if hunk_file < file_path or (hunk_file == file_path and hunk_row < row) then
      jump_to_hunk(hunk)
      return true, "Jumped to previous AI edit"
    end
  end

  jump_to_hunk(hunks[#hunks])
  return true, "Jumped to previous AI edit"
end

return M
