local config = require("opencode_panel.config")
local process = require("opencode_panel.process")

local M = {}

local function url_encode(value)
  return tostring(value):gsub("\n", "\r\n"):gsub("([^%w%-_%.~])", function(char)
    return string.format("%%%02X", string.byte(char))
  end)
end

local function build_url(endpoint, query)
  local url = process.get_base_url() .. endpoint
  local params = {}
  local full_query = vim.tbl_extend("force", { directory = vim.fn.getcwd() }, query or {})

  for key, value in pairs(full_query) do
    if value ~= nil and value ~= "" then
      table.insert(params, url_encode(key) .. "=" .. url_encode(value))
    end
  end

  if #params > 0 then
    url = url .. "?" .. table.concat(params, "&")
  end

  return url
end

local function parse_response(stdout)
  local lines = vim.split(stdout or "", "\n", { plain = true, trimempty = false })
  local code = tonumber(lines[#lines])

  if not code then
    return nil, stdout or "", "Invalid HTTP response"
  end

  table.remove(lines, #lines)
  local body = table.concat(lines, "\n")
  local decoded = nil

  if body ~= "" then
    local ok, parsed = pcall(vim.json.decode, body)
    if ok then
      decoded = parsed
    end
  end

  return code, decoded, body
end

local function request(method, endpoint, opts, cb)
  opts = opts or {}

  process.ensure_started(function(ok, err)
    if not ok then
      cb(false, err)
      return
    end

    local cmd = {
      "curl",
      "-sS",
      "-o",
      "-",
      "-w",
      "\n%{http_code}",
      "-X",
      method,
      build_url(endpoint, opts.query),
      "-H",
      "Accept: application/json",
    }

    if opts.body ~= nil then
      table.insert(cmd, "-H")
      table.insert(cmd, "Content-Type: application/json")
      table.insert(cmd, "--data-binary")
      table.insert(cmd, vim.json.encode(opts.body))
    end

    vim.system(cmd, { text = true }, function(obj)
      vim.schedule(function()
        if obj.code ~= 0 then
          cb(false, obj.stderr ~= "" and obj.stderr or obj.stdout)
          return
        end

        local code, decoded, body = parse_response(obj.stdout)
        if not code then
          cb(false, body)
          return
        end

        if code >= 200 and code < 300 then
          cb(true, decoded or body)
          return
        end

        cb(false, decoded or body)
      end)
    end)
  end)
end

function M.list_sessions(cb)
  request("GET", "/session", nil, cb)
end

function M.create_session(title, cb)
  local body = title and title ~= "" and { title = title } or false
  request("POST", "/session", { body = body }, cb)
end

function M.get_session(session_id, cb)
  request("GET", "/session/" .. session_id, nil, cb)
end

function M.list_messages(session_id, cb)
  request("GET", "/session/" .. session_id .. "/message", nil, cb)
end

function M.create_message(session_id, payload, cb)
  request("POST", "/session/" .. session_id .. "/message", { body = payload }, cb)
end

function M.abort_session(session_id, cb)
  request("POST", "/session/" .. session_id .. "/abort", nil, cb)
end

function M.list_providers(cb)
  request("GET", "/config/providers", nil, cb)
end

function M.list_models(cb)
  M.list_providers(function(ok, data)
    if not ok then
      cb(false, data)
      return
    end

    local models = {}
    for _, provider in ipairs(data.providers or {}) do
      for _, model in pairs(provider.models or {}) do
        table.insert(models, {
          label = string.format("%s/%s", provider.id, model.id),
          provider = provider.id,
          provider_name = provider.name,
          model = model.id,
          model_name = model.name,
          variants = model.variants or {},
        })
      end
    end

    table.sort(models, function(a, b)
      return a.label < b.label
    end)

    cb(true, {
      providers = data.providers or {},
      models = models,
    })
  end)
end

function M.subscribe_to_events(on_event, on_exit, on_open)
  process.ensure_started(function(ok, err)
    if not ok then
      if on_exit then
        on_exit(err)
      end
      return
    end

    local buffer = ""
    local job_id = vim.fn.jobstart({
      "curl",
      "-N",
      "-sS",
      build_url("/event"),
    }, {
      stdout_buffered = false,
      on_stdout = function(_, data)
        if not data then
          return
        end

        buffer = buffer .. table.concat(data, "\n")
        local lines = vim.split(buffer, "\n", { plain = true, trimempty = false })
        buffer = table.remove(lines) or ""

        for _, line in ipairs(lines) do
          local payload = line:match("^data:%s*(.+)$")
          if payload and payload ~= "" then
            local ok_decode, decoded = pcall(vim.json.decode, payload)
            if ok_decode and decoded then
              vim.schedule(function()
                on_event(decoded)
              end)
            end
          end
        end
      end,
      on_exit = function(_, code)
        if on_exit then
          vim.schedule(function()
            on_exit(code)
          end)
        end
      end,
    })

    if job_id > 0 then
      if on_open then
        vim.schedule(function()
          on_open(job_id)
        end)
      end
      return
    end

    if on_exit then
      on_exit("Failed to subscribe to opencode events")
    end
  end)
end

function M.build_message_payload(prompt, opts)
  opts = opts or {}
  local payload = {
    agent = opts.agent or config.agent,
    parts = {
      {
        type = "text",
        text = prompt,
      },
    },
  }

  if opts.model then
    local provider, model = opts.model:match("^(.-)/(.+)$")
    if provider and model then
      payload.model = {
        providerID = provider,
        modelID = model,
      }
    end
  end

  if opts.variant then
    payload.variant = opts.variant
  end

  return payload
end

return M
