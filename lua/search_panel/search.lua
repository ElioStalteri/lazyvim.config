local uv = vim.uv

local preview = require("search_panel.preview")
local results = require("search_panel.results")
local state = require("search_panel.state")
local tools = require("search_panel.tools")
local utils = require("search_panel.utils")

local M = {}

local SEARCH_EWMA_ALPHA = 0.35
local SEARCH_QUIET_MIN_MS = 50
local SEARCH_QUIET_MAX_MS = 180
local SEARCH_CANCEL_AGE_MS = 220

function M.clear_timer()
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

local function snapshot_request(source)
  return {
    search = state.search,
    include = state.include,
    mode = state.mode,
    source = source or "manual",
  }
end

function M.cancel_active(deps)
  local proc = state.search_active_proc
  if proc then
    pcall(proc.kill, proc, 15)
  end

  state.search_active_proc = nil
  state.search_active_seq = 0
  state.search_active_started = 0
  state.search_active_request = nil
  deps.set_loading("search", false)
end

local function adaptive_quiet_ms(now)
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

local start_search
local enqueue_start_search

start_search = function(n, request, deps)
  if not state.signal then
    return
  end

  M.clear_timer()

  state.search_seq = state.search_seq + 1
  local seq = state.search_seq
  state.search_active_seq = seq
  state.search_active_started = uv.hrtime()
  state.search_active_request = request

  preview.stop_replacement_timer()
  state.preview_compute_seq = state.preview_compute_seq + 1
  deps.set_loading("preview", false)

  local search = request.search
  if search == "" then
    state.search_active_proc = nil
    state.search_active_seq = 0
    state.search_active_started = 0
    state.search_active_request = nil
    deps.set_loading("search", false)
    state.files = {}
    state.signal.nodes = {}
    deps.set_status("Type to search")
    deps.clear_section_error("results")
    deps.clear_section_error("replace")
    preview.clear_highlight()
    return
  end

  if not tools.has_rg(true) then
    state.search_active_proc = nil
    state.search_active_seq = 0
    state.search_active_started = 0
    state.search_active_request = nil
    deps.set_loading("search", false)
    deps.set_loading("preview", false)
    state.files = {}
    state.signal.nodes = {}
    deps.set_status("Search unavailable")
    deps.set_section_error("results", "ripgrep (rg) is required but not found in PATH")
    preview.clear_highlight()
    return
  end

  deps.clear_section_error("results")
  deps.set_loading("search", true)

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

  for _, glob in ipairs(utils.parse_include_globs(request.include)) do
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
      deps.set_loading("search", false)

      if obj.code > 1 then
        preview.stop_replacement_timer()
        state.preview_compute_seq = state.preview_compute_seq + 1
        deps.set_loading("preview", false)
        deps.set_status("Search failed")
        deps.set_section_error("results", obj.stderr ~= "" and obj.stderr or "rg failed")
      else
        local files = results.parse_rg_output(obj.stdout or "", state.cwd, state.replacement)
        local elapsed = (uv.hrtime() - started) / 1000000000
        deps.set_results(n, files, elapsed)
        deps.schedule_preview_compute(n, 180)
        if next(files) == nil then
          preview.clear_highlight()
        end
      end

      if state.pending_search_request then
        local pending = state.pending_search_request
        state.pending_search_request = nil
        enqueue_start_search(n, pending, deps)
      end
    end)
  end)
end

enqueue_start_search = function(n, request, deps)
  vim.schedule(function()
    if not state.signal then
      return
    end

    if request then
      start_search(n, request, deps)
    end
  end)
end

function M.schedule(n, source, opts, deps)
  opts = opts or {}
  if not state.signal then
    return
  end

  local request = snapshot_request(source)

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
    quiet_ms, delta_ms = adaptive_quiet_ms(now)
  end

  if state.search_active_proc then
    if opts.force then
      M.cancel_active(deps)
    else
      local age_ms = (now - state.search_active_started) / 1000000
      if age_ms >= SEARCH_CANCEL_AGE_MS then
        M.cancel_active(deps)
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
        enqueue_start_search(n, pending_now, deps)
      end
      return
    end

    M.clear_timer()
    state.search_timer = uv.new_timer()
    state.search_timer:start(quiet_ms, 0, function()
      vim.schedule(function()
        if state.search_active_proc then
          return
        end

        local pending = state.pending_search_request
        state.pending_search_request = nil
        if pending then
          enqueue_start_search(n, pending, deps)
        end
      end)
    end)
    return
  end

  local pending = state.pending_search_request
  state.pending_search_request = nil
  if pending then
    enqueue_start_search(n, pending, deps)
  end
end

return M
