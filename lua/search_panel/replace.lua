local state = require("search_panel.state")
local tools = require("search_panel.tools")
local utils = require("search_panel.utils")

local M = {}

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

function M.run_on_text(input, opts)
  if not tools.has_sd(true) then
    return nil, "sd is required for replace actions and regex substitutions"
  end

  local args = build_sd_args(opts)

  local ok_proc, proc_or_err = pcall(vim.system, args, { text = true, cwd = state.cwd, stdin = input })
  if not ok_proc then
    return nil, utils.trim(tostring(proc_or_err))
  end

  local obj = proc_or_err:wait()
  if obj.code ~= 0 then
    local err = utils.trim(obj.stderr ~= "" and obj.stderr or (obj.stdout ~= "" and obj.stdout or "sd failed"))
    return nil, err
  end

  return obj.stdout or ""
end

function M.run_on_text_async(input, opts, callback)
  if not tools.has_sd(true) then
    vim.schedule(function()
      callback(nil, "sd is required for replace actions and regex substitutions")
    end)
    return
  end

  local args = build_sd_args(opts)

  local ok_proc, proc_or_err = pcall(vim.system, args, { text = true, cwd = state.cwd, stdin = input }, function(obj)
    vim.schedule(function()
      if obj.code ~= 0 then
        local err = utils.trim(obj.stderr ~= "" and obj.stderr or (obj.stdout ~= "" and obj.stdout or "sd failed"))
        callback(nil, err)
        return
      end

      callback(obj.stdout or "", nil)
    end)
  end)

  if not ok_proc then
    vim.schedule(function()
      callback(nil, utils.trim(tostring(proc_or_err)))
    end)
  end
end

return M
