local uv = vim.uv

local results = require("search_panel.results")
local state = require("search_panel.state")
local tools = require("search_panel.tools")

local M = {}

local PREVIEW_NS = vim.api.nvim_create_namespace("search_panel_preview")

function M.stop_origin_timer()
  if state.preview_timer then
    state.preview_timer:stop()
    state.preview_timer:close()
    state.preview_timer = nil
  end
end

function M.stop_replacement_timer()
  if state.replacement_timer then
    state.replacement_timer:stop()
    state.replacement_timer:close()
    state.replacement_timer = nil
  end
end

function M.clear_highlight()
  if state.preview_bufnr and vim.api.nvim_buf_is_valid(state.preview_bufnr) then
    pcall(vim.api.nvim_buf_clear_namespace, state.preview_bufnr, PREVIEW_NS, 0, -1)
  end
  state.preview_bufnr = nil
end

local function panel_has_focus()
  if not state.renderer then
    return false
  end

  local current_win = vim.api.nvim_get_current_win()
  local components = state.renderer:get_focusable_components() or {}

  for _, component in ipairs(components) do
    if component.winid and vim.api.nvim_win_is_valid(component.winid) and component.winid == current_win then
      return true
    end
  end

  return false
end

function M.clear_if_panel_unfocused()
  vim.schedule(function()
    if not panel_has_focus() then
      M.clear_highlight()
    end
  end)
end

local function highlight_match(bufnr, node)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  M.clear_highlight()

  local lnum = (node.lnum or 1) - 1
  local start_col = node.start_col0 or math.max((node.col or 1) - 1, 0)
  local end_col = node.end_col0 or (start_col + math.max(#state.search, 1))

  local line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1]
  if line then
    end_col = math.min(end_col, #line)
  end
  if end_col <= start_col then
    end_col = start_col + 1
  end

  pcall(vim.api.nvim_buf_set_extmark, bufnr, PREVIEW_NS, lnum, start_col, {
    end_row = lnum,
    end_col = end_col,
    hl_group = "SearchPanelPreviewFocus",
    priority = 250,
  })
  state.preview_bufnr = bufnr
end

local function preview_in_origin(node)
  if not node or node.type ~= "match" or not node.path then
    M.clear_highlight()
    return
  end

  local origin_win = state.renderer and state.renderer:get_origin_winid() or nil
  if not origin_win or not vim.api.nvim_win_is_valid(origin_win) then
    M.clear_highlight()
    return
  end

  local bufnr = vim.fn.bufadd(node.path)
  vim.fn.bufload(bufnr)

  pcall(vim.api.nvim_win_set_buf, origin_win, bufnr)
  pcall(vim.api.nvim_win_set_cursor, origin_win, { node.lnum or 1, math.max((node.col or 1) - 1, 0) })
  highlight_match(bufnr, node)
end

function M.schedule_origin(node)
  M.stop_origin_timer()

  if not state.interactive_preview or not node or node.type ~= "match" then
    M.clear_highlight()
    return
  end

  local target = {
    type = node.type,
    path = node.path,
    lnum = node.lnum,
    col = node.col,
    start_col0 = node.start_col0,
    end_col0 = node.end_col0,
  }

  state.preview_timer = uv.new_timer()
  state.preview_timer:start(60, 0, function()
    vim.schedule(function()
      preview_in_origin(target)
    end)
  end)
end

local function preview_cache_key(match_text)
  return table.concat({ state.mode, state.search, state.replacement, match_text }, "\31")
end

local function run_compute(n, seq, deps)
  if not state.signal or seq ~= state.preview_compute_seq then
    return
  end

  if next(state.files) == nil then
    deps.clear_section_error("replace")
    deps.set_loading("preview", false)
    return
  end

  if state.mode == "literal" then
    results.apply_preview_parts_to_files(state.files, nil, state.replacement)
    deps.refresh_nodes(n)
    deps.clear_section_error("replace")
    deps.set_loading("preview", false)
    return
  end

  if not tools.has_sd(true) then
    results.apply_preview_parts_to_files(state.files, nil, state.replacement)
    deps.refresh_nodes(n)
    deps.set_section_error("replace", "sd is required for regex replacement preview and apply")
    deps.set_loading("preview", false)
    return
  end

  local replacement_map = {}
  local pending_texts = {}
  local seen = {}

  for _, file in pairs(state.files) do
    for _, match in ipairs(file.matches) do
      local text = match.raw_match_text or ""
      local key = preview_cache_key(text)
      local cached = state.sd_preview_cache[key]
      if cached ~= nil then
        replacement_map[text] = cached
      elseif not seen[text] then
        seen[text] = true
        table.insert(pending_texts, text)
      end
    end
  end

  local preview_error = nil
  local index = 1

  local function finalize()
    if not state.signal or seq ~= state.preview_compute_seq then
      return
    end

    results.apply_preview_parts_to_files(state.files, replacement_map, state.replacement)
    deps.refresh_nodes(n)

    if preview_error then
      deps.set_section_error("replace", preview_error)
    else
      deps.clear_section_error("replace")
    end

    deps.set_loading("preview", false)
  end

  local function step()
    if not state.signal or seq ~= state.preview_compute_seq then
      return
    end

    local text = pending_texts[index]
    if text == nil then
      finalize()
      return
    end

    deps.run_sd_on_text_async(text, { max_replacements = 1 }, function(replaced, err)
      if not state.signal or seq ~= state.preview_compute_seq then
        return
      end

      local key = preview_cache_key(text)
      if replaced then
        state.sd_preview_cache[key] = replaced
        replacement_map[text] = replaced
      else
        if preview_error == nil then
          preview_error = err
        end
        replacement_map[text] = state.replacement
      end

      index = index + 1
      if index % 25 == 0 then
        vim.schedule(step)
      else
        step()
      end
    end)
  end

  if #pending_texts == 0 then
    finalize()
    return
  end

  step()
end

function M.schedule_compute(n, delay_ms, deps)
  M.stop_replacement_timer()
  state.preview_compute_seq = state.preview_compute_seq + 1
  local seq = state.preview_compute_seq

  deps.set_loading("preview", true)

  state.replacement_timer = uv.new_timer()
  state.replacement_timer:start(delay_ms or 300, 0, function()
    vim.schedule(function()
      run_compute(n, seq, deps)
    end)
  end)
end

return M
