local uv = vim.uv or vim.loop
local PREVIEW_NS = vim.api.nvim_create_namespace("search_panel_preview")

local M = {}

local state = {
  renderer = nil,
  signal = nil,
  cwd = nil,
  search = "",
  replacement = "",
  include = "",
  mode = "literal",
  files = {},
  focused_node = nil,
  interactive_preview = true,
  search_seq = 0,
  search_active_proc = nil,
  search_active_seq = 0,
  search_active_started = 0,
  search_active_request = nil,
  pending_search_request = nil,
  search_input_last_hrtime = nil,
  search_input_ewma_ms = 90,
  search_timer = nil,
  preview_timer = nil,
  replacement_timer = nil,
  preview_compute_seq = 0,
  sd_preview_cache = {},
  preview_bufnr = nil,
  search_input_component = nil,
  results_component = nil,
  reset_results_to_top_on_next_results = false,
  status_base = "Type to search",
  spinner_timer = nil,
  spinner_index = 1,
  search_loading = false,
  preview_loading = false,
}

local queue_signal_value
local queue_signal_update

local function setup_highlights()
  vim.api.nvim_set_hl(0, "SearchPanelBg", { fg = "#f8f8f0", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "SearchPanelResultsBg", { fg = "#f8f8f0", bg = "#171712" })
  vim.api.nvim_set_hl(0, "SearchPanelStatus", { fg = "#8f908a", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "SearchPanelHelp", { fg = "#7f837d", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "SearchPanelBorder", { fg = "#4d5154", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "SearchPanelHeader", { fg = "#9ca0a4", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "SearchPanelErrorBorder", { fg = "#6b2c3b", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "SearchPanelErrorHeader", { fg = "#e95678", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "SearchPanelErrorText", { fg = "#f3c7d2", bg = "#22171b" })
  vim.api.nvim_set_hl(0, "SearchPanelArrow", { fg = "#8f908a" })
  vim.api.nvim_set_hl(0, "SearchPanelFile", { fg = "#9ca0a4" })
  vim.api.nvim_set_hl(0, "SearchPanelCursorLine", { bg = "#40403a" })
  vim.api.nvim_set_hl(0, "SearchPanelMatch", { fg = "#f8f8f0", bg = "#4a0f23" })
  vim.api.nvim_set_hl(0, "SearchPanelReplace", { fg = "#f8f8f0", bg = "#5c8014" })
  vim.api.nvim_set_hl(0, "SearchPanelPreviewFocus", { fg = "#f8f8f0", bg = "#56791a", nocombine = true })
end

local function get_file_icon(path)
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return "*", "SearchPanelFile"
  end

  local file = vim.fs.basename(path)
  local ext = file:match("%.([^.]+)$")
  local icon, icon_hl = devicons.get_icon(file, ext, { default = true })

  return icon or "*", icon_hl or "SearchPanelFile"
end

local function normalize_path(path)
  if path:sub(1, 1) == "/" then
    return path
  end

  return state.cwd .. "/" .. path
end

local function shorten(str, max_len)
  if #str <= max_len then
    return str
  end

  return str:sub(1, max_len - 3) .. "..."
end

local function trim(str)
  return (str:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function set_section_error(section, message)
  local text = trim(message or "")
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

local SEARCH_EWMA_ALPHA = 0.35
local SEARCH_QUIET_MIN_MS = 50
local SEARCH_QUIET_MAX_MS = 180
local SEARCH_CANCEL_AGE_MS = 220
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

local function stop_preview_timer()
  if state.preview_timer then
    state.preview_timer:stop()
    state.preview_timer:close()
    state.preview_timer = nil
  end
end

local function stop_replacement_timer()
  if state.replacement_timer then
    state.replacement_timer:stop()
    state.replacement_timer:close()
    state.replacement_timer = nil
  end
end

local function clear_preview_highlight()
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

local function clear_preview_if_panel_unfocused()
  vim.schedule(function()
    if not panel_has_focus() then
      clear_preview_highlight()
    end
  end)
end

local function highlight_preview_match(bufnr, node)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  clear_preview_highlight()

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
    clear_preview_highlight()
    return
  end

  local origin_win = state.renderer and state.renderer:get_origin_winid() or nil
  if not origin_win or not vim.api.nvim_win_is_valid(origin_win) then
    clear_preview_highlight()
    return
  end

  local bufnr = vim.fn.bufadd(node.path)
  vim.fn.bufload(bufnr)

  pcall(vim.api.nvim_win_set_buf, origin_win, bufnr)
  pcall(vim.api.nvim_win_set_cursor, origin_win, { node.lnum or 1, math.max((node.col or 1) - 1, 0) })
  highlight_preview_match(bufnr, node)
end

local function schedule_preview(node)
  stop_preview_timer()

  if not state.interactive_preview or not node or node.type ~= "match" then
    clear_preview_highlight()
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
      schedule_preview(first)
    else
      clear_preview_highlight()
    end
  end)
end

local function build_sd_args(opts)
  local args = { "sd" }
  if state.mode == "literal" then
    table.insert(args, "-F")
  end
  if opts and opts.max_replacements then
    table.insert(args, "--max-replacements")
    table.insert(args, tostring(opts.max_replacements))
  end
  table.insert(args, state.search)
  table.insert(args, state.replacement)

  return args
end

local function run_sd_on_text(input, opts)
  local args = build_sd_args(opts)

  local obj = vim.system(args, { text = true, cwd = state.cwd, stdin = input }):wait()
  if obj.code ~= 0 then
    local err = trim(obj.stderr ~= "" and obj.stderr or (obj.stdout ~= "" and obj.stdout or "sd failed"))
    return nil, err
  end

  return obj.stdout or ""
end

local function run_sd_on_text_async(input, opts, callback)
  local args = build_sd_args(opts)

  vim.system(args, { text = true, cwd = state.cwd, stdin = input }, function(obj)
    vim.schedule(function()
      if obj.code ~= 0 then
        local err = trim(obj.stderr ~= "" and obj.stderr or (obj.stdout ~= "" and obj.stdout or "sd failed"))
        callback(nil, err)
        return
      end

      callback(obj.stdout or "", nil)
    end)
  end)
end

local function build_preview_parts(line_text, start_col0, end_col0, match_text, replacement)
  local text = line_text or ""
  local start_col = math.max((start_col0 or 0) + 1, 1)
  local raw_len = math.max((end_col0 or start_col0 or 0) - (start_col0 or 0), 0)
  local visual_len = math.max(raw_len, 1)
  local end_col = start_col + visual_len - 1

  if #text == 0 then
    return {
      left = "",
      match = match_text,
      replacement = replacement,
      right = "",
    }
  end

  if start_col > #text then
    start_col = #text
    end_col = #text
  end

  local from = math.max(1, start_col - 18)
  local to = math.min(#text, end_col + 22)

  local left = text:sub(from, start_col - 1)
  local shown_match = match_text ~= "" and match_text or text:sub(start_col, end_col)
  local right = text:sub(end_col + 1, to)

  if from > 1 then
    left = "..." .. left
  end
  if to < #text then
    right = right .. "..."
  end

  return {
    left = shorten(left, 40),
    match = shorten(shown_match, 30),
    replacement = replacement,
    right = shorten(right, 40),
  }
end

local function parse_rg_output(stdout)
  local files = {}

  for line in (stdout .. "\n"):gmatch("(.-)\n") do
    if line ~= "" then
      local ok, event = pcall(vim.json.decode, line)
      if ok and event and event.type == "match" and event.data then
        local data = event.data
        local rel_path = data.path and data.path.text or nil
        local line_text = data.lines and data.lines.text or ""
        line_text = line_text:gsub("\r?\n$", "")
        local lnum = tonumber(data.line_number) or 1

        if rel_path and data.submatches then
          local abs_path = normalize_path(rel_path)

          if not files[abs_path] then
            files[abs_path] = {
              path = abs_path,
              rel_path = rel_path,
              matches = {},
            }
          end

          for _, submatch in ipairs(data.submatches) do
            local start_col0 = tonumber(submatch.start) or 0
            local end_col0 = tonumber(submatch["end"]) or start_col0
            local raw_match_text = (submatch.match and submatch.match.text) or ""
            local preview = build_preview_parts(line_text, start_col0, end_col0, raw_match_text, state.replacement)
            local match = {
              type = "match",
              rel_path = rel_path,
              path = abs_path,
              lnum = lnum,
              col = start_col0 + 1,
              start_col0 = start_col0,
              end_col0 = end_col0,
              text = line_text,
              raw_match_text = raw_match_text,
              left = preview.left,
              match_text = preview.match,
              replacement_text = preview.replacement,
              right = preview.right,
            }

            table.insert(files[abs_path].matches, match)
          end
        end
      end
    end
  end

  return files
end

local to_tree_nodes

local function refresh_nodes(n)
  if not state.signal then
    return
  end

  state.signal.nodes = to_tree_nodes(n)
end

local function apply_preview_parts_to_files(replacement_map)
  for _, file in pairs(state.files) do
    for _, match in ipairs(file.matches) do
      local replacement_text = replacement_map and replacement_map[match.raw_match_text]
      if replacement_text == nil then
        replacement_text = state.replacement
      end
      local preview = build_preview_parts(
        match.text,
        match.start_col0,
        match.end_col0,
        match.raw_match_text,
        replacement_text
      )
      match.left = preview.left
      match.match_text = preview.match
      match.replacement_text = preview.replacement
      match.right = preview.right
    end
  end
end

to_tree_nodes = function(n)
  local nodes = {}
  local paths = {}

  for path in pairs(state.files) do
    table.insert(paths, path)
  end

  table.sort(paths, function(a, b)
    return state.files[a].rel_path < state.files[b].rel_path
  end)

  for _, path in ipairs(paths) do
    local file = state.files[path]
    local children = {}

    for _, match in ipairs(file.matches) do
      table.insert(children, n.node({
        type = "match",
        path = match.path,
        rel_path = match.rel_path,
        lnum = match.lnum,
        col = match.col,
        start_col0 = match.start_col0,
        end_col0 = match.end_col0,
        raw_match_text = match.raw_match_text,
        left = match.left,
        match_text = match.match_text,
        replacement_text = match.replacement_text,
        right = match.right,
      }))
    end

    local first = file.matches[1]
    local icon, icon_hl = get_file_icon(file.rel_path)
    local file_node = n.node({
      type = "file",
      path = file.path,
      rel_path = file.rel_path,
      lnum = first and first.lnum or 1,
      col = first and first.col or 1,
      icon = icon,
      icon_hl = icon_hl,
      text = string.format("%s (%d)", file.rel_path, #file.matches),
    }, children)
    file_node:expand()
    table.insert(nodes, file_node)
  end

  return nodes
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

  local nodes = to_tree_nodes(n)
  state.signal.nodes = nodes
  if state.reset_results_to_top_on_next_results then
    state.reset_results_to_top_on_next_results = false
    reset_results_to_top()
  end

  local match_word = match_count == 1 and "match" or "matches"
  local seconds = elapsed or 0
  set_status(string.format("Total: %d %s in %d files, time: %.4fs", match_count, match_word, file_count, seconds))
end

local function parse_include_globs(include_value)
  local value = trim(include_value or state.include or "")
  local globs = {}

  if value == "" then
    return globs
  end

  for token in value:gmatch("[^,]+") do
    local part = trim(token)
    if part ~= "" then
      local has_wildcard = part:find("[%*%?%{%}]") ~= nil
      local is_file = part:match("%.[^/]+$") ~= nil

      if has_wildcard or is_file then
        table.insert(globs, part)
      elseif part:sub(-1) == "/" then
        table.insert(globs, part .. "**")
      else
        table.insert(globs, part .. "/**")
      end
    end
  end

  return globs
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

local schedule_search
local schedule_preview_compute
local enqueue_start_search

local function toggle_mode(n)
  state.mode = state.mode == "literal" and "regex" or "literal"
  state.sd_preview_cache = {}
  sync_mode_signal()
  clear_section_error("replace")
  clear_section_error("results")
  set_status("Mode switched to " .. state.mode)
  schedule_search(n, "mode")
end

local function clear_search_timer()
  if state.search_timer then
    state.search_timer:stop()
    state.search_timer:close()
    state.search_timer = nil
  end
end

local function search_requests_equal(a, b)
  if not a or not b then
    return false
  end

  return a.search == b.search and a.include == b.include and a.mode == b.mode
end

local function snapshot_search_request(source)
  return {
    search = state.search,
    include = state.include,
    mode = state.mode,
    source = source or "manual",
  }
end

local function cancel_active_search()
  local proc = state.search_active_proc
  if proc then
    pcall(proc.kill, proc, 15)
  end

  state.search_active_proc = nil
  state.search_active_seq = 0
  state.search_active_started = 0
  state.search_active_request = nil
  set_loading("search", false)
end

local function adaptive_search_quiet_ms(now)
  if not state.search_input_last_hrtime then
    state.search_input_last_hrtime = now
    return SEARCH_QUIET_MIN_MS, nil
  end

  local delta_ms = (now - state.search_input_last_hrtime) / 1000000
  state.search_input_last_hrtime = now
  state.search_input_ewma_ms = (SEARCH_EWMA_ALPHA * delta_ms) + ((1 - SEARCH_EWMA_ALPHA) * state.search_input_ewma_ms)

  local quiet = math.floor(state.search_input_ewma_ms * 0.9)
  return math.max(SEARCH_QUIET_MIN_MS, math.min(SEARCH_QUIET_MAX_MS, quiet)), delta_ms
end

local function start_search(n, request)
  if not state.signal then
    return
  end

  clear_search_timer()

  state.search_seq = state.search_seq + 1
  local seq = state.search_seq
  state.search_active_seq = seq
  state.search_active_started = uv.hrtime()
  state.search_active_request = request

  stop_replacement_timer()
  state.preview_compute_seq = state.preview_compute_seq + 1
  set_loading("preview", false)

  local search = request.search
  if search == "" then
    state.search_active_proc = nil
    state.search_active_seq = 0
    state.search_active_started = 0
    state.search_active_request = nil
    set_loading("search", false)
    state.files = {}
    state.signal.nodes = {}
    set_status("Type to search")
    clear_section_error("results")
    clear_section_error("replace")
    clear_preview_highlight()
    return
  end

  clear_section_error("results")
  set_loading("search", true)

  local args = {
    "rg",
    "--json",
    "--hidden",
    "--glob",
    "!.git",
    "--glob",
    "!node_modules",
    "--glob",
    "!.venv",
  }

  if request.mode == "literal" then
    table.insert(args, "--fixed-strings")
  end

  local include_globs = parse_include_globs(request.include)
  for _, glob in ipairs(include_globs) do
    table.insert(args, "--glob")
    table.insert(args, glob)
  end

  table.insert(args, search)
  local started = uv.hrtime()

  state.search_active_proc = vim.system(args, { text = true, cwd = state.cwd }, function(obj)
    vim.schedule(function()
      if not state.signal or seq ~= state.search_active_seq then
        return
      end

      state.search_active_proc = nil
      state.search_active_seq = 0
      state.search_active_started = 0
      state.search_active_request = nil
      set_loading("search", false)

      if obj.code > 1 then
        stop_replacement_timer()
        state.preview_compute_seq = state.preview_compute_seq + 1
        set_loading("preview", false)
        set_status("Search failed")
        set_section_error("results", obj.stderr ~= "" and obj.stderr or "rg failed")
      else
        local files = parse_rg_output(obj.stdout or "")
        local elapsed = (uv.hrtime() - started) / 1000000000
        set_results(n, files, elapsed)
        schedule_preview_compute(n, 180)
        if next(files) == nil then
          clear_preview_highlight()
        end
      end

      if state.pending_search_request then
        local pending = state.pending_search_request
        state.pending_search_request = nil
        enqueue_start_search(n, pending)
      end
    end)
  end)
end

enqueue_start_search = function(n, request)
  vim.schedule(function()
    if not state.signal then
      return
    end

    if request then
      start_search(n, request)
    end
  end)
end

schedule_search = function(n, source, opts)
  opts = opts or {}
  if not state.signal then
    return
  end

  local request = snapshot_search_request(source)

  if state.search_active_request and search_requests_equal(request, state.search_active_request) and not opts.force then
    if not state.search_active_proc and not state.pending_search_request then
      return
    end
  end

  if state.pending_search_request and search_requests_equal(request, state.pending_search_request) and not opts.force then
    return
  end

  state.pending_search_request = request

  local now = uv.hrtime()
  local quiet_ms = 0
  local delta_ms = nil
  if request.source == "search" and not opts.force then
    quiet_ms, delta_ms = adaptive_search_quiet_ms(now)
  end

  if state.search_active_proc then
    if opts.force then
      cancel_active_search()
    else
    local age_ms = (now - state.search_active_started) / 1000000
    if age_ms >= SEARCH_CANCEL_AGE_MS then
      cancel_active_search()
    else
      return
    end
    end
  end

  if request.source == "search" and not opts.force then
    if delta_ms and delta_ms >= quiet_ms then
      local pending_now = state.pending_search_request
      state.pending_search_request = nil
      if pending_now then
        enqueue_start_search(n, pending_now)
      end
      return
    end

    clear_search_timer()
    state.search_timer = uv.new_timer()
    state.search_timer:start(quiet_ms, 0, function()
      vim.schedule(function()
        if state.search_active_proc then
          return
        end

        local pending = state.pending_search_request
        state.pending_search_request = nil
        if pending then
          enqueue_start_search(n, pending)
        end
      end)
    end)
    return
  end

  local pending = state.pending_search_request
  state.pending_search_request = nil
  if pending then
    enqueue_start_search(n, pending)
  end
end

local function preview_cache_key(match_text)
  return table.concat({ state.mode, state.search, state.replacement, match_text }, "\31")
end

local function run_preview_compute(n, seq)
  if not state.signal or seq ~= state.preview_compute_seq then
    return
  end

  if next(state.files) == nil then
    clear_section_error("replace")
    set_loading("preview", false)
    return
  end

  if state.mode == "literal" then
    apply_preview_parts_to_files(nil)
    refresh_nodes(n)
    clear_section_error("replace")
    set_loading("preview", false)
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

    apply_preview_parts_to_files(replacement_map)
    refresh_nodes(n)

    if preview_error then
      set_section_error("replace", preview_error)
    else
      clear_section_error("replace")
    end

    set_loading("preview", false)
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

    run_sd_on_text_async(text, { max_replacements = 1 }, function(replaced, err)
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

schedule_preview_compute = function(n, delay_ms)
  stop_replacement_timer()
  state.preview_compute_seq = state.preview_compute_seq + 1
  local seq = state.preview_compute_seq

  set_loading("preview", true)

  state.replacement_timer = uv.new_timer()
  state.replacement_timer:start(delay_ms or 300, 0, function()
    vim.schedule(function()
      run_preview_compute(n, seq)
    end)
  end)
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

local function read_file(path)
  local fd, open_err = uv.fs_open(path, "r", 438)
  if not fd then
    return nil, open_err
  end

  local stat, stat_err = uv.fs_fstat(fd)
  if not stat then
    uv.fs_close(fd)
    return nil, stat_err
  end

  local data, read_err = uv.fs_read(fd, stat.size, 0)
  uv.fs_close(fd)

  if not data then
    return nil, read_err
  end

  return data
end

local function write_file(path, content)
  local mode = 420
  local fd, open_err = uv.fs_open(path, "w", mode)
  if not fd then
    return false, open_err
  end

  local ok, write_err = uv.fs_write(fd, content, 0)
  uv.fs_close(fd)

  if not ok then
    return false, write_err
  end

  return true
end

local function get_line_start_index(content, lnum)
  local line = 1
  local idx = 1

  while line < lnum do
    local nl = content:find("\n", idx, true)
    if not nl then
      return nil
    end
    idx = nl + 1
    line = line + 1
  end

  return idx
end

local function reload_buffer_if_loaded(path)
  local bufnr = vim.fn.bufnr(path)
  if bufnr == -1 or not vim.api.nvim_buf_is_loaded(bufnr) then
    return true
  end

  if vim.bo[bufnr].modified then
    return false
  end

  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd("silent checktime")
  end)

  return true
end

local function apply_paths(paths, n)
  if state.search == "" then
    set_section_error("search", "Search value is empty")
    set_status("Cannot apply without search text")
    return
  end

  clear_section_error("search")
  clear_section_error("results")

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

    local original, read_err = read_file(path)
    if not original then
      table.insert(failures, string.format("Cannot read %s: %s", path, read_err or "unknown error"))
      goto continue
    end

    local updated, replace_err = run_sd_on_text(original)
    if not updated then
      table.insert(failures, string.format("Cannot replace in %s: %s", path, replace_err or "sd failed"))
      goto continue
    end

    if updated ~= original then
      local ok, write_err = write_file(path, updated)
      if not ok then
        table.insert(failures, string.format("Cannot write %s: %s", path, write_err or "unknown error"))
        goto continue
      end

      changed_files = changed_files + 1
      local estimated = state.files[path] and #state.files[path].matches or 0
      replaced_total = replaced_total + math.max(estimated, 1)
      reload_buffer_if_loaded(path)
    end

    ::continue::
  end

  local msg = string.format("Applied %d replacements in %d files", replaced_total, changed_files)
  if skipped_modified > 0 then
    msg = msg .. string.format(" (%d modified buffers skipped)", skipped_modified)
  end
  set_status(msg)

  if #failures > 0 then
    local err = failures[1]
    if #failures > 1 then
      err = string.format("%s (+%d more)", err, #failures - 1)
    end
    set_section_error("results", err)
  end

  schedule_search(n, "manual", { force = true })
end

local function apply_current_file(n)
  local node = state.focused_node
  if not node then
    set_section_error("results", "No file selected")
    set_status("Select a file or preview row first")
    return
  end

  local path = node.path
  if node.type ~= "file" and node.type ~= "match" then
    set_section_error("results", "No file selected")
    set_status("Select a file or preview row first")
    return
  end

  clear_section_error("results")
  apply_paths({ path }, n)
end

local function apply_current_match(n)
  local node = state.focused_node
  if not node or node.type ~= "match" then
    set_section_error("results", "Select a diff line first")
    set_status("No focused diff line")
    return
  end

  if state.search == "" then
    set_section_error("search", "Search value is empty")
    set_status("Cannot apply without search text")
    return
  end

  clear_section_error("search")
  clear_section_error("results")

  local path = node.path
  local bufnr = vim.fn.bufnr(path)
  if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified then
    set_section_error("results", "Buffer has unsaved changes")
    set_status("Save buffer before applying diff")
    return
  end

  local original, read_err = read_file(path)
  if not original then
    set_section_error("results", string.format("Cannot read %s: %s", path, read_err or "unknown error"))
    set_status("Apply failed")
    return
  end

  local line_start = get_line_start_index(original, node.lnum or 1)
  if not line_start then
    set_section_error("results", "Match line is out of range")
    set_status("Apply failed")
    return
  end

  local start_idx = line_start + (node.start_col0 or math.max((node.col or 1) - 1, 0))
  local end_idx_exclusive = line_start + (node.end_col0 or (start_idx - line_start + #state.search))
  if end_idx_exclusive < start_idx then
    end_idx_exclusive = start_idx
  end

  local target = original:sub(start_idx, end_idx_exclusive - 1)
  if node.raw_match_text and node.raw_match_text ~= "" and target ~= node.raw_match_text then
    set_section_error("results", "Focused diff is stale. Refresh search and try again")
    set_status("Apply failed")
    return
  end

  local replaced_segment, replace_err = run_sd_on_text(target, { max_replacements = 1 })
  local updated = nil
  if replaced_segment then
    updated = original:sub(1, start_idx - 1) .. replaced_segment .. original:sub(end_idx_exclusive)
  end

  if not updated then
    set_section_error("results", replace_err or "Apply failed")
    set_status("Apply failed")
    return
  end

  if updated == original then
    set_status("No change applied")
    return
  end

  local ok, write_err = write_file(path, updated)
  if not ok then
    set_section_error("results", string.format("Cannot write %s: %s", path, write_err or "unknown error"))
    set_status("Apply failed")
    return
  end

  reload_buffer_if_loaded(path)
  set_status(string.format("Applied 1 replacement in %s:%d", node.rel_path or path, node.lnum or 1))
  schedule_search(n, "manual", { force = true })
end

local function apply_all_files(n)
  local paths = {}
  for path in pairs(state.files) do
    table.insert(paths, path)
  end

  table.sort(paths)
  if #paths == 0 then
    set_section_error("results", "No files to apply")
    set_status("No files matched current search")
    return
  end

  clear_section_error("results")
  apply_paths(paths, n)
end

local function confirm_apply_all_files(n)
  local answer = vim.fn.confirm("Replace in all matched files?", "&Apply all\n&Cancel", 2)
  if answer == 1 then
    apply_all_files(n)
  end
end

local function register_results_which_key(bufnr)
  local ok, wk = pcall(require, "which-key")
  if not ok then
    return
  end

  wk.add({
    { "a", desc = "Apply current diff", mode = "n", buffer = bufnr },
    { "A", desc = "Apply current file", mode = "n", buffer = bufnr },
  })
end

function M.open(opts)
  if state.renderer then
    state.renderer:focus()
    return
  end

  local n = require("nui-components")
  setup_highlights()
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

  local function error_panel(lines_signal, hidden_signal)
    return n.paragraph({
      lines = lines_signal,
      hidden = hidden_signal,
      is_focusable = false,
      border_style = "rounded",
      border_label = "Error",
      truncate = true,
      max_lines = 2,
      window = {
        highlight = {
          FloatBorder = "SearchPanelErrorBorder",
          FloatTitle = "SearchPanelErrorHeader",
          Normal = "SearchPanelErrorText",
          NormalFloat = "SearchPanelErrorText",
        },
      },
    })
  end

  local function body()
    return n.rows(
      n.paragraph({
        lines = state.signal.mode_help,
        is_focusable = false,
        window = {
          highlight = {
            Normal = "SearchPanelHelp",
            NormalFloat = "SearchPanelHelp",
          },
        },
      }),
      n.text_input({
        id = "search-input",
        border_label = state.signal.search_label,
        max_lines = 1,
        autofocus = true,
        on_mount = function(component)
          state.search_input_component = component
          sync_search_border_label()
        end,
        on_unmount = function(component)
          if state.search_input_component == component then
            state.search_input_component = nil
          end
        end,
        on_blur = clear_preview_if_panel_unfocused,
        window = {
          highlight = {
            FloatBorder = "SearchPanelBorder",
            FloatTitle = "SearchPanelHeader",
            Normal = "SearchPanelBg",
            NormalFloat = "SearchPanelBg",
          },
        },
        value = state.signal.search,
        on_change = function(value)
          state.search = value
          queue_signal_value("search", value)
          state.reset_results_to_top_on_next_results = true
          state.sd_preview_cache = {}
          clear_section_error("search")
          schedule_search(n, "search")
        end,
      }),
      error_panel(state.signal.search_error, state.signal.search_error_hidden),
      n.text_input({
        id = "replace-input",
        border_label = "Replace",
        max_lines = 1,
        on_blur = clear_preview_if_panel_unfocused,
        window = {
          highlight = {
            FloatBorder = "SearchPanelBorder",
            FloatTitle = "SearchPanelHeader",
            Normal = "SearchPanelBg",
            NormalFloat = "SearchPanelBg",
          },
        },
        value = state.signal.replacement,
        on_change = function(value)
          state.replacement = value
          queue_signal_value("replacement", value)
          state.sd_preview_cache = {}
          clear_section_error("replace")
          schedule_preview_compute(n, 300)
        end,
      }),
      error_panel(state.signal.replace_error, state.signal.replace_error_hidden),
      n.text_input({
        id = "include-input",
        border_label = "Files to include",
        max_lines = 1,
        on_blur = clear_preview_if_panel_unfocused,
        window = {
          highlight = {
            FloatBorder = "SearchPanelBorder",
            FloatTitle = "SearchPanelHeader",
            Normal = "SearchPanelBg",
            NormalFloat = "SearchPanelBg",
          },
        },
        value = state.signal.include,
        placeholder = "lua/**/*.lua,lua/config/**",
        on_change = function(value)
          state.include = value
          queue_signal_value("include", value)
          state.sd_preview_cache = {}
          clear_section_error("include")
          schedule_search(n, "include")
        end,
      }),
      error_panel(state.signal.include_error, state.signal.include_error_hidden),
      n.tree({
        id = "result-tree",
        flex = 1,
        border_label = "Results",
        on_blur = clear_preview_if_panel_unfocused,
        mappings = function()
          return {
            {
              mode = "n",
              key = "a",
              handler = function()
                apply_current_match(n)
              end,
            },
            {
              mode = "n",
              key = "A",
              handler = function()
                apply_current_file(n)
              end,
            },
          }
        end,
        on_mount = function(component)
          state.results_component = component
          register_results_which_key(component.bufnr)
        end,
        on_unmount = function(component)
          if state.results_component == component then
            state.results_component = nil
          end
        end,
        window = {
          highlight = {
            FloatBorder = "SearchPanelBorder",
            FloatTitle = "SearchPanelHeader",
            Normal = "SearchPanelResultsBg",
            NormalFloat = "SearchPanelResultsBg",
            CursorLine = "SearchPanelCursorLine",
          },
        },
        data = state.signal.nodes,
        on_change = function(node)
          state.focused_node = node
          schedule_preview(node)
        end,
        on_select = function(node, component)
          if not node then
            return
          end

          state.focused_node = node

          if node.type == "file" then
            local tree = component:get_tree()
            if node:is_expanded() then
              node:collapse()
            else
              node:expand()
            end
            tree:render()
            component:set_focused_node(node)
            return
          end

          jump_to(node)
        end,
        prepare_node = function(node, line)
          if node.type == "file" then
            local marker = node:is_expanded() and " " or " "
            line:append(marker, "SearchPanelArrow")
            line:append((node.icon or "*") .. " ", node.icon_hl or "SearchPanelFile")
            line:append(node.text, "SearchPanelFile")
          else
            line:append("  ")
            line:append(string.format("%d:%d ", node.lnum, node.col), "Comment")
            line:append(node.left or "")
            line:append(node.match_text or "", "SearchPanelMatch")
            local replacement_text = node.replacement_text
            if replacement_text == "" then
              replacement_text = "<empty>"
            end
            line:append(replacement_text, "SearchPanelReplace")
            line:append(node.right or "")
          end
          return line
        end,
      }),
      error_panel(state.signal.results_error, state.signal.results_error_hidden),
      n.paragraph({
        lines = "Results panel only: a apply focused diff, A apply focused file\n"
          .. "Any panel section: m toggle literal/regex, R apply all (confirm)",
        is_focusable = false,
        window = {
          highlight = {
            Normal = "SearchPanelHelp",
            NormalFloat = "SearchPanelHelp",
          },
        },
      }),
      n.paragraph({
        lines = state.signal.status,
        is_focusable = false,
        window = {
          highlight = {
            Normal = "SearchPanelStatus",
            NormalFloat = "SearchPanelStatus",
          },
        },
      })
    )
  end

  renderer:add_mappings({
    {
      mode = "n",
      key = "q",
      handler = function()
        renderer:close()
      end,
    },
    {
      mode = "n",
      key = "r",
      handler = function()
        schedule_search(n, "manual", { force = true })
      end,
    },
    {
      mode = "n",
      key = "m",
      handler = function()
        toggle_mode(n)
      end,
    },
    {
      mode = "n",
      key = "R",
      handler = function()
        confirm_apply_all_files(n)
      end,
    },
  })

  clear_all_errors()

  renderer:on_unmount(function()
    cancel_active_search()
    clear_search_timer()
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
    stop_preview_timer()
    stop_replacement_timer()
    state.preview_compute_seq = state.preview_compute_seq + 1
    clear_preview_highlight()
    if state.search_timer then
      state.search_timer:stop()
      state.search_timer:close()
      state.search_timer = nil
    end
  end)

  renderer:render(body)
end

function M.setup()
  vim.api.nvim_create_user_command("SearchPanel", function(command_opts)
    M.open({ cwd = command_opts.args ~= "" and command_opts.args or vim.fn.getcwd() })
  end, {
    nargs = "?",
    complete = "dir",
    desc = "Open literal search/replace panel",
  })
end

return M
