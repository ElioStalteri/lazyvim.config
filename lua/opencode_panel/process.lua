local config = require("opencode_panel.config")

local M = {
  job_id = nil,
  started_by_plugin = false,
  starting = false,
  callbacks = {},
  stderr = {},
}

local function url_encode(value)
  return tostring(value):gsub("\n", "\r\n"):gsub("([^%w%-_%.~])", function(char)
    return string.format("%%%02X", string.byte(char))
  end)
end

local function base_url()
  return string.format("http://%s:%d", config.server.host, config.server.port)
end

local function push_callback(cb, ok, err)
  vim.schedule(function()
    cb(ok, err)
  end)
end

local function flush_callbacks(ok, err)
  local callbacks = M.callbacks
  M.callbacks = {}
  M.starting = false

  for _, cb in ipairs(callbacks) do
    push_callback(cb, ok, err)
  end
end

local function probe_server(cb)
  local url = base_url() .. "/config?directory=" .. url_encode(vim.fn.getcwd())
  vim.system({ "curl", "-sS", "--max-time", "1", url }, { text = true }, function(obj)
    local ok = obj.code == 0 and obj.stdout and obj.stdout ~= ""
    vim.schedule(function()
      cb(ok)
    end)
  end)
end

local function poll_until_ready(deadline, cb)
  probe_server(function(ok)
    if ok then
      cb(true)
      return
    end

    if vim.uv.now() >= deadline then
      cb(false)
      return
    end

    vim.defer_fn(function()
      poll_until_ready(deadline, cb)
    end, config.server.startup_poll_ms)
  end)
end

function M.get_base_url()
  return base_url()
end

function M.ensure_started(cb)
  if M.starting then
    table.insert(M.callbacks, cb)
    return
  end

  probe_server(function(ok)
    if ok then
      cb(true)
      return
    end

    M.starting = true
    table.insert(M.callbacks, cb)

    local cmd = {
      config.server.command,
      "serve",
      "--hostname",
      config.server.host,
      "--port",
      tostring(config.server.port),
    }

    M.stderr = {}
    M.job_id = vim.fn.jobstart(cmd, {
      on_stderr = function(_, data)
        if not data then
          return
        end

        for _, line in ipairs(data) do
          if line and line ~= "" then
            table.insert(M.stderr, line)
          end
        end
      end,
      on_exit = function()
        M.job_id = nil
      end,
    })

    if M.job_id <= 0 then
      flush_callbacks(false, "Failed to start opencode server")
      return
    end

    M.started_by_plugin = true

    poll_until_ready(vim.uv.now() + config.server.startup_timeout_ms, function(ready)
      if ready then
        flush_callbacks(true)
        return
      end

      local reason = #M.stderr > 0 and table.concat(M.stderr, "\n") or "Timed out waiting for opencode serve"
      flush_callbacks(false, reason)
    end)
  end)
end

function M.stop()
  if M.started_by_plugin and M.job_id and M.job_id > 0 then
    pcall(vim.fn.jobstop, M.job_id)
  end

  M.job_id = nil
  M.started_by_plugin = false
  M.starting = false
  M.callbacks = {}
end

return M
