local M = {}

local health = vim.health or require("health")
local start = health.start or health.report_start
local ok = health.ok or health.report_ok
local warn = health.warn or health.report_warn
local err = health.error or health.report_error
local info = health.info or health.report_info

local function trim(value)
  return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function command_version(cmd)
  if vim.fn.executable(cmd) ~= 1 then
    return nil, "missing"
  end

  local ok_proc, proc_or_err = pcall(vim.system, { cmd, "--version" }, { text = true })
  if not ok_proc then
    return nil, trim(tostring(proc_or_err))
  end

  local out = proc_or_err:wait()
  if out.code ~= 0 then
    local msg = trim(out.stderr ~= "" and out.stderr or out.stdout)
    if msg == "" then
      msg = "failed to read version"
    end
    return nil, msg
  end

  local first = trim((out.stdout or ""):match("([^\r\n]+)") or "")
  if first == "" then
    first = "version output unavailable"
  end

  return first, nil
end

local function check_binary(cmd, required, note)
  local version, e = command_version(cmd)
  if version then
    ok(string.format("%s found: %s", cmd, version))
    return true
  end

  if required then
    err(string.format("%s not available: %s", cmd, e or "unknown error"), note and { note } or nil)
  else
    warn(string.format("%s not available: %s", cmd, e or "unknown error"), note and { note } or nil)
  end

  return false
end

function M.check()
  start("search_panel")

  if vim.fn.has("nvim-0.10") == 0 then
    err("Neovim 0.10+ is required (vim.system is used).")
  else
    ok("Neovim version is compatible")
  end

  start("Search backend")
  check_binary("rg", true, "Install ripgrep and ensure `rg` is in PATH")

  start("Replace backend")
  local sd_ok = check_binary(
    "sd",
    false,
    "Install sd for apply actions and regex replacement preview; search still works without it"
  )
  if sd_ok then
    info("Literal and regex replace/apply are available")
  else
    warn("Apply actions are disabled without sd")
  end

  start("UI dependencies")
  if pcall(require, "nui-components") then
    ok("nui-components.nvim is available")
  else
    err("nui-components.nvim is not available")
  end

  if pcall(require, "nui.popup") then
    ok("nui.nvim is available")
  else
    err("nui.nvim is not available")
  end
end

return M
