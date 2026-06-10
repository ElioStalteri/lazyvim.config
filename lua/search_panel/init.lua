local uv = vim.uv

local actions = require("search_panel.actions")
local highlights = require("search_panel.highlights")
local preview = require("search_panel.preview")
local replace = require("search_panel.replace")
local results = require("search_panel.results")
local search_backend = require("search_panel.search")
local state = require("search_panel.state")
local tools = require("search_panel.tools")
local ui = require("search_panel.ui")
local utils = require("search_panel.utils")

local M = {}

local queue_signal_value
local queue_signal_update

local function set_section_error(section, message)
  local text = utils.trim(message or "")
  queue_signal_update(function(signal)
    signal[section .. "_error"] = text
    signal[section .. "_error_hidden"] = text == ""
  end)
end

local function clear_section_error(section)
  set_section_error(section, "")
end

local function clear_all_errors()
  clear_section_error("search")
  clear_section_error("replace")
  clear_section_error("include")
  clear_section_error("results")
end

local SPINNER_FRAMES = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

local pending_signal_values = {}
local pending_signal_values_flush = false

queue_signal_value = function(key, value)
  pending_signal_values[key] = value

  if pending_signal_values_flush then
    return
  end

  pending_signal_values_flush = true
  vim.schedule(function()
    pending_signal_values_flush = false
    if not state.signal then
      pending_signal_values = {}
      return
    end

    for k, v in pairs(pending_signal_values) do
      state.signal[k] = v
      pending_signal_values[k] = nil
    end
  end)
end

queue_signal_update = function(fn)
  vim.schedule(function()
    if state.signal then
      fn(state.signal)
    end
  end)
end

local function render_status_line()
  if not state.signal then
    return
  end

  local frame = SPINNER_FRAMES[state.spinner_index]
  if state.search_loading then
    queue_signal_value("status", "Searching " .. frame)
  elseif state.preview_loading then
    queue_signal_value("status", "Updating preview " .. frame)
  else
    queue_signal_value("status", state.status_base)
  end
end

local function stop_spinner()
  if state.spinner_timer then
    state.spinner_timer:stop()
    state.spinner_timer:close()
    state.spinner_timer = nil
  end
end

local function ensure_spinner()
  if state.spinner_timer then
    return
  end

  state.spinner_timer = uv.new_timer()
  state.spinner_timer:start(0, 80, function()
    vim.schedule(function()
      if not state.signal then
        return
      end
      state.spinner_index = (state.spinner_index % #SPINNER_FRAMES) + 1
      render_status_line()
    end)
  end)
end

local function set_loading(kind, value)
  if kind == "search" then
    state.search_loading = value
  elseif kind == "preview" then
    state.preview_loading = value
  end

  if state.search_loading or state.preview_loading then
    ensure_spinner()
  else
    stop_spinner()
  end

  render_status_line()
end

local function set_status(msg)
  state.status_base = msg
  render_status_line()
end

local function reset_results_to_top()
  vim.schedule(function()
    local component = state.results_component
    if not component or not component:is_mounted() then
      return
    end

    local tree = component:get_tree()
    if not tree then
      return
    end

    local first = tree:get_node(1)
    component:set_focused_node(first)
    state.focused_node = first

    if component.winid and vim.api.nvim_win_is_valid(component.winid) then
      pcall(vim.api.nvim_win_set_cursor, component.winid, { 1, 0 })
    end

    if first then
      preview.schedule_origin(first)
    else
      preview.clear_highlight()
    end
  end)
end

local function refresh_nodes(n)
  if not state.signal then
    return
  end

  state.signal.nodes = results.to_tree_nodes(state.files, n)
end

local function set_results(n, files, elapsed)
  clear_section_error("results")
  state.files = files

  local file_count = 0
  local match_count = 0
  for _, file in pairs(files) do
    file_count = file_count + 1
    match_count = match_count + #file.matches
  end

  local nodes = results.to_tree_nodes(state.files, n)
  state.signal.nodes = nodes
  if state.reset_results_to_top_on_next_results then
    state.reset_results_to_top_on_next_results = false
    reset_results_to_top()
  end

  local match_word = match_count == 1 and "match" or "matches"
  local seconds = elapsed or 0
  set_status(string.format("Total: %d %s in %d files, time: %.4fs", match_count, match_word, file_count, seconds))
end

local function current_search_label()
  if state.mode == "regex" then
    return "Search (regex)"
  end

  return "Search (literal)"
end

local function sync_search_border_label()
  local component = state.search_input_component
  if not component or not component:is_mounted() then
    return
  end

  component:set_border_text("top", " " .. current_search_label() .. " ", "left")
end

local function current_mode_help()
  if state.mode == "regex" then
    return "Mode: regex (toggle with m). Capture refs: $1, ${1}, ${name}"
  end

  return "Mode: literal (toggle with m). Replacement is plain text"
end

local function sync_mode_signal()
  if not state.signal then
    return
  end

  state.signal.search_label = current_search_label()
  state.signal.mode_help = current_mode_help()
  sync_search_border_label()
end

local schedule_preview_compute
local schedule_search

local function toggle_mode(n)
  state.mode = state.mode == "literal" and "regex" or "literal"
  state.sd_preview_cache = {}
  sync_mode_signal()
  if state.mode == "regex" and not tools.has_sd(true) then
    set_section_error("replace", "sd is required for regex replacement preview and apply")
  else
    clear_section_error("replace")
  end
  clear_section_error("results")
  set_status("Mode switched to " .. state.mode)
  schedule_search(n, "mode")
end

schedule_search = function(n, source, opts)
  search_backend.schedule(n, source, opts, {
    clear_section_error = clear_section_error,
    schedule_preview_compute = schedule_preview_compute,
    set_loading = set_loading,
    set_results = set_results,
    set_section_error = set_section_error,
    set_status = set_status,
  })
end

schedule_preview_compute = function(n, delay_ms)
  preview.schedule_compute(n, delay_ms, {
    clear_section_error = clear_section_error,
    refresh_nodes = refresh_nodes,
    run_sd_on_text_async = replace.run_on_text_async,
    set_loading = set_loading,
    set_section_error = set_section_error,
  })
end

local function jump_to(node)
  if not node or not node.path then
    return
  end

  local origin_win = state.renderer and state.renderer:get_origin_winid() or nil
  if origin_win and vim.api.nvim_win_is_valid(origin_win) then
    vim.api.nvim_set_current_win(origin_win)
  end

  vim.cmd("edit " .. vim.fn.fnameescape(node.path))
  pcall(vim.api.nvim_win_set_cursor, 0, { node.lnum or 1, math.max((node.col or 1) - 1, 0) })
end

function M.open(opts)
  if state.renderer then
    state.renderer:focus()
    return
  end

  local n = require("nui-components")
  highlights.setup()
  state.cwd = (opts and opts.cwd) or vim.fn.getcwd()

  local width = math.max(44, math.floor(vim.o.columns * 0.34))
  local height = math.max(14, vim.o.lines - 2)
  local col = math.max(vim.o.columns - width, 0)

  local renderer = n.create_renderer({
    width = width,
    height = height,
    relative = "editor",
    position = { row = 1, col = col },
  })

  state.renderer = renderer
  state.signal = n.create_signal({
    search = "",
    replacement = "",
    include = "",
    search_label = current_search_label(),
    mode_help = current_mode_help(),
    search_error = "",
    replace_error = "",
    include_error = "",
    results_error = "",
    search_error_hidden = true,
    replace_error_hidden = true,
    include_error_hidden = true,
    results_error_hidden = true,
    nodes = {},
    status = "Type to search",
  })
  state.status_base = "Type to search"
  state.spinner_index = 1
  state.search_loading = false
  state.preview_loading = false
  sync_mode_signal()
  render_status_line()

  local action_deps = {
    clear_section_error = clear_section_error,
    run_sd_on_text = replace.run_on_text,
    schedule_search = schedule_search,
    set_section_error = set_section_error,
    set_status = set_status,
  }

  local callbacks = {
    apply_current_file = function(target_n)
      actions.apply_current_file(target_n, action_deps)
    end,
    apply_current_match = function(target_n)
      actions.apply_current_match(target_n, action_deps)
    end,
    clear_preview_if_panel_unfocused = preview.clear_if_panel_unfocused,
    clear_section_error = clear_section_error,
    confirm_apply_all_files = function(target_n)
      actions.confirm_apply_all_files(target_n, action_deps)
    end,
    jump_to = jump_to,
    queue_signal_value = queue_signal_value,
    schedule_preview = preview.schedule_origin,
    schedule_preview_compute = schedule_preview_compute,
    schedule_search = schedule_search,
    sync_search_border_label = sync_search_border_label,
    toggle_mode = toggle_mode,
  }

  ui.add_renderer_mappings(renderer, n, callbacks)

  clear_all_errors()

  renderer:on_unmount(function()
    search_backend.cancel_active({ set_loading = set_loading })
    search_backend.clear_timer()
    stop_spinner()
    state.renderer = nil
    state.signal = nil
    state.files = {}
    state.focused_node = nil
    state.search = ""
    state.replacement = ""
    state.include = ""
    state.search_input_component = nil
    state.results_component = nil
    state.reset_results_to_top_on_next_results = false
    state.sd_preview_cache = {}
    state.pending_search_request = nil
    state.search_active_proc = nil
    state.search_active_seq = 0
    state.search_active_started = 0
    state.search_active_request = nil
    state.search_loading = false
    state.preview_loading = false
    preview.stop_origin_timer()
    preview.stop_replacement_timer()
    state.preview_compute_seq = state.preview_compute_seq + 1
    preview.clear_highlight()
  end)

  renderer:render(ui.create_body(n, callbacks))
end

function M.setup()
  vim.api.nvim_create_user_command("SearchPanel", function(command_opts)
    M.open({ cwd = command_opts.args ~= "" and command_opts.args or vim.fn.getcwd() })
  end, {
    nargs = "?",
    complete = "dir",
    desc = "Open search/replace panel",
  })
end

return M
