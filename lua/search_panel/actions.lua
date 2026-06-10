local fs = require("search_panel.fs")
local state = require("search_panel.state")
local tools = require("search_panel.tools")

local M = {}

local function apply_paths(paths, n, deps)
  if state.search == "" then
    deps.set_section_error("search", "Search value is empty")
    deps.set_status("Cannot apply without search text")
    return
  end

  if not tools.has_sd(true) then
    deps.set_section_error("replace", "sd is required for apply actions")
    deps.set_status("Replace unavailable")
    return
  end

  deps.clear_section_error("search")
  deps.clear_section_error("results")

  local changed_files = 0
  local replaced_total = 0
  local skipped_modified = 0
  local failures = {}

  for _, path in ipairs(paths) do
    local bufnr = vim.fn.bufnr(path)
    if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified then
      skipped_modified = skipped_modified + 1
      goto continue
    end

    local original, read_err = fs.read_file(path)
    if not original then
      table.insert(failures, string.format("Cannot read %s: %s", path, read_err or "unknown error"))
      goto continue
    end

    local updated, replace_err = deps.run_sd_on_text(original)
    if not updated then
      table.insert(failures, string.format("Cannot replace in %s: %s", path, replace_err or "sd failed"))
      goto continue
    end

    if updated ~= original then
      local ok, write_err = fs.write_file(path, updated)
      if not ok then
        table.insert(failures, string.format("Cannot write %s: %s", path, write_err or "unknown error"))
        goto continue
      end

      changed_files = changed_files + 1
      local estimated = state.files[path] and #state.files[path].matches or 0
      replaced_total = replaced_total + math.max(estimated, 1)
      fs.reload_buffer_if_loaded(path)
    end

    ::continue::
  end

  local msg = string.format("Applied %d replacements in %d files", replaced_total, changed_files)
  if skipped_modified > 0 then
    msg = msg .. string.format(" (%d modified buffers skipped)", skipped_modified)
  end
  deps.set_status(msg)

  if #failures > 0 then
    local err = failures[1]
    if #failures > 1 then
      err = string.format("%s (+%d more)", err, #failures - 1)
    end
    deps.set_section_error("results", err)
  end

  deps.schedule_search(n, "manual", { force = true })
end

function M.apply_current_file(n, deps)
  local node = state.focused_node
  if not node then
    deps.set_section_error("results", "No file selected")
    deps.set_status("Select a file or preview row first")
    return
  end

  local path = node.path
  if node.type ~= "file" and node.type ~= "match" then
    deps.set_section_error("results", "No file selected")
    deps.set_status("Select a file or preview row first")
    return
  end

  deps.clear_section_error("results")
  apply_paths({ path }, n, deps)
end

function M.apply_current_match(n, deps)
  local node = state.focused_node
  if not node or node.type ~= "match" then
    deps.set_section_error("results", "Select a diff line first")
    deps.set_status("No focused diff line")
    return
  end

  if state.search == "" then
    deps.set_section_error("search", "Search value is empty")
    deps.set_status("Cannot apply without search text")
    return
  end

  if not tools.has_sd(true) then
    deps.set_section_error("replace", "sd is required for apply actions")
    deps.set_status("Replace unavailable")
    return
  end

  deps.clear_section_error("search")
  deps.clear_section_error("results")

  local path = node.path
  local bufnr = vim.fn.bufnr(path)
  if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified then
    deps.set_section_error("results", "Buffer has unsaved changes")
    deps.set_status("Save buffer before applying diff")
    return
  end

  local original, read_err = fs.read_file(path)
  if not original then
    deps.set_section_error("results", string.format("Cannot read %s: %s", path, read_err or "unknown error"))
    deps.set_status("Apply failed")
    return
  end

  local line_start = fs.get_line_start_index(original, node.lnum or 1)
  if not line_start then
    deps.set_section_error("results", "Match line is out of range")
    deps.set_status("Apply failed")
    return
  end

  local start_idx = line_start + (node.start_col0 or math.max((node.col or 1) - 1, 0))
  local end_idx_exclusive = line_start + (node.end_col0 or (start_idx - line_start + #state.search))
  if end_idx_exclusive < start_idx then
    end_idx_exclusive = start_idx
  end

  local target = original:sub(start_idx, end_idx_exclusive - 1)
  if node.raw_match_text and node.raw_match_text ~= "" and target ~= node.raw_match_text then
    deps.set_section_error("results", "Focused diff is stale. Refresh search and try again")
    deps.set_status("Apply failed")
    return
  end

  local replaced_segment, replace_err = deps.run_sd_on_text(target, { max_replacements = 1 })
  local updated = nil
  if replaced_segment then
    updated = original:sub(1, start_idx - 1) .. replaced_segment .. original:sub(end_idx_exclusive)
  end

  if not updated then
    deps.set_section_error("results", replace_err or "Apply failed")
    deps.set_status("Apply failed")
    return
  end

  if updated == original then
    deps.set_status("No change applied")
    return
  end

  local ok, write_err = fs.write_file(path, updated)
  if not ok then
    deps.set_section_error("results", string.format("Cannot write %s: %s", path, write_err or "unknown error"))
    deps.set_status("Apply failed")
    return
  end

  fs.reload_buffer_if_loaded(path)
  deps.set_status(string.format("Applied 1 replacement in %s:%d", node.rel_path or path, node.lnum or 1))
  deps.schedule_search(n, "manual", { force = true })
end

function M.apply_all_files(n, deps)
  local paths = {}
  for path in pairs(state.files) do
    table.insert(paths, path)
  end

  table.sort(paths)
  if #paths == 0 then
    deps.set_section_error("results", "No files to apply")
    deps.set_status("No files matched current search")
    return
  end

  deps.clear_section_error("results")
  apply_paths(paths, n, deps)
end

function M.confirm_apply_all_files(n, deps)
  local answer = vim.fn.confirm("Replace in all matched files?", "&Apply all\n&Cancel", 2)
  if answer == 1 then
    M.apply_all_files(n, deps)
  end
end

return M
