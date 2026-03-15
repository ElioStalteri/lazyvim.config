local uv = vim.uv

local client = require("opencode_panel.client")
local config = require("opencode_panel.config")
local edits = require("opencode_panel.edits")
local picker = require("opencode_panel.picker")
local process = require("opencode_panel.process")
local state = require("opencode_panel.state")

local M = {}

local SPINNER_FRAMES = { "-", "\\", "|", "/" }
local pending_signal_values = {}
local pending_signal_values_flush = false

local function trim(value)
  return (value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function shorten(value, max_len)
  if #value <= max_len then
    return value
  end

  return value:sub(1, max_len - 3) .. "..."
end

local function queue_signal_value(key, value)
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

    for key_name, signal_value in pairs(pending_signal_values) do
      state.signal[key_name] = signal_value
      pending_signal_values[key_name] = nil
    end
  end)
end

local function stop_spinner()
  if state.spinner_timer then
    state.spinner_timer:stop()
    state.spinner_timer:close()
    state.spinner_timer = nil
  end
end

local function render_status_line()
  local edit_count = edits.count_files()
  local conflict_count = edits.count_conflicts()
  local edit_suffix = edit_count > 0 and string.format(" | %d pending file%s", edit_count, edit_count == 1 and "" or "s")
    or ""
  local conflict_suffix = conflict_count > 0 and string.format(" | %d conflict%s", conflict_count, conflict_count == 1 and "" or "s")
    or ""

  if state.loading then
    queue_signal_value("status", state.status .. " " .. SPINNER_FRAMES[state.spinner_index] .. edit_suffix .. conflict_suffix)
    return
  end

  queue_signal_value("status", state.status .. edit_suffix .. conflict_suffix)
end

local function ensure_spinner()
  if state.spinner_timer then
    return
  end

  state.spinner_timer = uv.new_timer()
  state.spinner_timer:start(0, 100, function()
    vim.schedule(function()
      state.spinner_index = (state.spinner_index % #SPINNER_FRAMES) + 1
      render_status_line()
    end)
  end)
end

local function set_loading(value, status)
  state.loading = value
  if status and status ~= "" then
    state.status = status
  end

  if state.loading then
    ensure_spinner()
  else
    stop_spinner()
  end

  render_status_line()
end

local function set_status(value)
  state.status = value
  render_status_line()
end

local function session_title(session)
  if not session then
    return "No session"
  end

  return trim(session.title) ~= "" and session.title or session.id
end

local function model_title()
  return state.current_model or "server default"
end

local function variant_title()
  return state.current_variant or "default"
end

local function update_header()
  local session_text = string.format("Session: %s", session_title(state.active_session))
  local model_text = string.format("Model: %s", model_title())
  local variant_text = string.format("Thinking: %s", variant_title())
  local agent_text = string.format("Agent: %s", state.current_agent or config.agent)
  local edit_text = edits.summary()

  queue_signal_value("header", table.concat({ session_text, model_text, variant_text, agent_text, edit_text }, "\n"))
end

local function summarize_tool(part)
  if part.tool == "apply_patch" then
    local metadata = part.state and part.state.metadata or {}
    local files = metadata.files or {}
    if #files == 0 then
      return "apply patch"
    end

    local first = files[1].relativePath or files[1].filePath or "file"
    if #files == 1 then
      return "apply patch -> " .. first
    end

    return string.format("apply patch -> %s (+%d)", first, #files - 1)
  end

  return part.tool or "tool"
end

local function extend_lines(target, text, prefix)
  local lines = vim.split(text or "", "\n", { plain = true, trimempty = false })
  for _, line in ipairs(lines) do
    table.insert(target, prefix and (prefix .. line) or line)
  end
end

local function format_messages(messages)
  if not messages or #messages == 0 then
    return "No messages yet. Write a prompt below to start a session."
  end

  local lines = {}

  for _, message in ipairs(messages) do
    local role = message.info and message.info.role or "assistant"
    local header = role == "user" and "You" or "AI"
    table.insert(lines, header)

    for _, part in ipairs(message.parts or {}) do
      if part.type == "text" and part.text then
        extend_lines(lines, part.text, "  ")
      elseif part.type == "reasoning" and config.show_reasoning and part.text then
        extend_lines(lines, part.text, "  > ")
      elseif part.type == "tool" then
        table.insert(lines, "  [" .. summarize_tool(part) .. "]")
      elseif part.type == "patch" then
        local files = part.files or {}
        if #files > 0 then
          table.insert(lines, "  [patch] " .. table.concat(files, ", "))
        else
          table.insert(lines, "  [patch]")
        end
      end
    end

    table.insert(lines, "")
  end

  return table.concat(lines, "\n")
end

local function sync_transcript()
  queue_signal_value("transcript", format_messages(state.messages))
  update_header()
  render_status_line()
end

local function extract_model_from_messages(messages)
  for index = #messages, 1, -1 do
    local info = messages[index].info or {}
    local provider = info.providerID or (info.model and info.model.providerID)
    local model = info.modelID or (info.model and info.model.modelID)

    if provider and model then
      state.current_model = provider .. "/" .. model
      state.current_variant = info.variant or state.current_variant
      return
    end
  end
end

local function stop_refresh_timer()
  if state.refresh_timer then
    state.refresh_timer:stop()
    state.refresh_timer:close()
    state.refresh_timer = nil
  end
end

local function refresh_sessions(select_latest, cb)
  client.list_sessions(function(ok, result)
    if not ok then
      set_status("Failed to load sessions")
      if cb then
        cb(false, result)
      end
      return
    end

    table.sort(result, function(a, b)
      local a_time = a.time and a.time.updated or 0
      local b_time = b.time and b.time.updated or 0
      return a_time > b_time
    end)

    state.sessions = result

    if select_latest and (not state.active_session) and result[1] then
      state.active_session = result[1]
    elseif state.active_session then
      for _, session in ipairs(result) do
        if session.id == state.active_session.id then
          state.active_session = session
          break
        end
      end
    end

    update_header()

    if cb then
      cb(true, result)
    end
  end)
end

local function refresh_messages()
  if not state.active_session then
    state.messages = {}
    sync_transcript()
    return
  end

  set_loading(true, "Refreshing conversation")
  client.list_messages(state.active_session.id, function(ok, result)
    set_loading(false)

    if not ok then
      set_status("Failed to load messages")
      return
    end

    state.messages = result or {}
    extract_model_from_messages(state.messages)
    state.pending_edits = edits.update(state.messages)
    sync_transcript()
    set_status("Conversation ready")
  end)
end

local function schedule_refresh(delay_ms)
  stop_refresh_timer()
  state.refresh_timer = uv.new_timer()
  state.refresh_timer:start(delay_ms, 0, function()
    vim.schedule(function()
      stop_refresh_timer()
      refresh_messages()
    end)
  end)
end

local function load_models(cb)
  client.list_models(function(ok, result)
    if not ok then
      set_status("Failed to load models")
      if cb then
        cb(false, result)
      end
      return
    end

    state.providers = result.providers
    if cb then
      cb(true, result.models)
    end
  end)
end

local function current_variants()
  if not state.current_model or not state.providers then
    return {}
  end

  local provider_id, model_id = state.current_model:match("^(.-)/(.+)$")
  if not provider_id or not model_id then
    return {}
  end

  for _, provider in ipairs(state.providers) do
    if provider.id == provider_id then
      local model = provider.models and provider.models[model_id]
      local items = {
        {
          label = "default",
          value = nil,
        },
      }

      for name, _ in pairs(model and model.variants or {}) do
        table.insert(items, {
          label = name,
          value = name,
        })
      end

      table.sort(items, function(a, b)
        return a.label < b.label
      end)

      return items
    end
  end

  return {}
end

local function ensure_event_subscription()
  if state.subscriptions_ready then
    return
  end

  client.subscribe_to_events(function(event)
    local event_type = event.type
    local properties = event.properties or {}
    local session_id = properties.sessionID
      or (properties.info and properties.info.id)
      or (properties.part and properties.part.sessionID)

    if event_type == "session.status" and state.active_session and session_id == state.active_session.id then
      local status = properties.status or {}
      set_loading(true, status.message or status.type or "Working")
      return
    end

    if event_type == "session.idle" and state.active_session and session_id == state.active_session.id then
      set_loading(false, "Idle")
      schedule_refresh(60)
      return
    end

    if event_type == "session.error" and state.active_session and session_id == state.active_session.id then
      set_loading(false, "Session error")
      schedule_refresh(60)
      return
    end

    if event_type == "permission.asked" and state.active_session and session_id == state.active_session.id then
      set_status("Permission requested")
      return
    end

    if event_type == "question.asked" and state.active_session and session_id == state.active_session.id then
      set_status("Question pending")
      return
    end

    if event_type == "session.deleted" and state.active_session and session_id == state.active_session.id then
      state.active_session = nil
      state.messages = {}
      sync_transcript()
      refresh_sessions(true)
      return
    end

    if state.active_session and session_id == state.active_session.id then
      schedule_refresh(120)
      return
    end

    if event_type == "session.updated" or event_type == "session.deleted" then
      refresh_sessions(false)
    end
  end, function()
    state.subscriptions_ready = false
    state.event_job = nil
  end, function(job_id)
    state.subscriptions_ready = true
    state.event_job = job_id
  end)
end

local function create_session_from_prompt(prompt, cb)
  client.create_session(shorten(prompt, 60), function(ok, result)
    if not ok then
      set_loading(false, "Failed to create session")
      return
    end

    state.active_session = result
    refresh_sessions(false)
    if cb then
      cb(result)
    end
  end)
end

local function submit_prompt()
  local prompt = trim(state.prompt)
  if prompt == "" then
    set_status("Prompt is empty")
    return
  end

  local function send_message(session)
    set_loading(true, "Sending prompt")
    state.prompt = ""
    queue_signal_value("prompt", "")

    client.create_message(session.id, client.build_message_payload(prompt, {
      agent = state.current_agent,
      model = state.current_model,
      variant = state.current_variant,
    }), function(ok, result)
      if not ok then
        set_loading(false, "Failed to send prompt")
        return
      end

      if result and result.info then
        set_status("Prompt sent")
      end

      refresh_sessions(false)
      schedule_refresh(120)
    end)
  end

  if state.active_session then
    send_message(state.active_session)
    return
  end

  create_session_from_prompt(prompt, send_message)
end

local function select_session()
  refresh_sessions(false, function(ok, sessions)
    if not ok then
      return
    end

    local items = {}
    for _, session in ipairs(sessions) do
      local updated = session.time and session.time.updated and os.date("%H:%M · %m/%d", math.floor(session.time.updated / 1000)) or ""
      table.insert(items, {
        id = session.id,
        label = session_title(session),
        detail = updated,
        highlight = state.active_session and state.active_session.id == session.id and "OpencodePanelPickerAccent" or nil,
        value = session,
      })
    end

    picker.open({
      title = "Sessions",
      description = "Continue an existing opencode conversation",
      items = items,
      status = string.format("%d session%s", #items, #items == 1 and "" or "s"),
      on_select = function(choice)
      if not choice then
        return
      end

      state.active_session = choice
      state.messages = {}
      sync_transcript()
      if not state.renderer then
        M.open()
      end
      refresh_messages()
      end,
    })
  end)
end

local function select_model()
  load_models(function(ok, result)
    if not ok then
      return
    end

    local items = {}
    for _, model in ipairs(result) do
      local detail = model.provider_name
      table.insert(items, {
        id = model.label,
        label = model.label,
        detail = detail,
        highlight = state.current_model == model.label and "OpencodePanelPickerAccent" or nil,
        value = model,
      })
    end

    picker.open({
      title = "Models",
      description = "Select the model for the next prompt",
      items = items,
      on_select = function(choice)
      if not choice then
        return
      end

      state.current_model = choice.label
      state.current_variant = nil
      update_header()
      set_status("Model updated")
      end,
    })
  end)
end

local function select_variant()
  local variants = current_variants()
  if #variants == 0 then
    set_status("Current model has no variants")
    return
  end

  local items = {}
  for _, variant in ipairs(variants) do
    table.insert(items, {
      id = variant.label,
      label = variant.label,
      detail = variant.value == nil and "use model default" or "reasoning variant",
      highlight = state.current_variant == variant.value and "OpencodePanelPickerAccent" or nil,
      value = variant,
    })
  end

  picker.open({
    title = "Thinking Strength",
    description = "Select the reasoning variant for the current model",
    items = items,
    on_select = function(choice)
    if not choice then
      return
    end

    state.current_variant = choice.value
    update_header()
    set_status("Thinking strength updated")
    end,
  })
end

local function new_session()
  client.create_session(false, function(ok, result)
    if not ok then
      set_status("Failed to create session")
      return
    end

    state.active_session = result
    state.messages = {}
    sync_transcript()
    refresh_sessions(false)
    set_status("New session ready")
    if not state.renderer then
      M.open()
    end
  end)
end

local function cancel_active_session()
  if not state.active_session then
    set_status("No active session")
    return
  end

  client.abort_session(state.active_session.id, function(ok)
    if ok then
      set_loading(false, "Cancelled")
      schedule_refresh(80)
      return
    end

    set_status("Failed to cancel session")
  end)
end

local function accept_current_edit()
  local ok, message = edits.accept_current()
  if ok then
    sync_transcript()
    set_status(message)
    return
  end

  set_status(message)
end

local function reject_current_edit()
  local ok, message = edits.reject_current()
  if ok then
    sync_transcript()
    set_status(message)
    return
  end

  set_status(message)
end

local function jump_next_edit()
  local ok, message = edits.jump_next()
  if ok then
    set_status(message)
    return
  end

  set_status(message)
end

local function jump_prev_edit()
  local ok, message = edits.jump_prev()
  if ok then
    set_status(message)
    return
  end

  set_status(message)
end

local function browse_edits()
  local items = edits.list_hunks()
  if #items == 0 then
    set_status("No pending AI edits")
    return
  end

  picker.open({
    title = "Pending Edits",
    description = "Browse AI hunks and jump to them",
    items = items,
    status = edits.summary(),
    help = "Enter jump | q close",
    on_select = function(hunk_id)
      local ok, message = edits.jump_to_id(hunk_id)
      set_status(message)
      if ok and state.renderer then
        state.renderer:focus()
      end
    end,
  })
end

local function setup_highlights()
  vim.api.nvim_set_hl(0, "OpencodePanelBg", { fg = "#f8f8f0", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "OpencodePanelMuted", { fg = "#8f908a", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "OpencodePanelBorder", { fg = "#4d5154", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "OpencodePanelHeader", { fg = "#9ca0a4", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "OpencodePanelConversation", { fg = "#f8f8f0", bg = "#171712" })
  vim.api.nvim_set_hl(0, "OpencodePanelStatus", { fg = "#8f908a", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "OpencodePanelHelp", { fg = "#7f837d", bg = "#1a1a18" })
end

function M.open()
  if state.renderer then
    state.renderer:focus()
    return
  end

  local n = require("nui-components")
  setup_highlights()
  ensure_event_subscription()
  load_models()
  refresh_sessions(true, function()
    if state.active_session then
      refresh_messages()
    else
      sync_transcript()
    end
  end)

  local width = math.max(config.ui.min_width, math.floor(vim.o.columns * config.ui.width_ratio))
  local height = math.max(config.ui.min_height, math.floor(vim.o.lines * config.ui.height_ratio))
  local row = math.max(math.floor((vim.o.lines - height) / 2) - 1, 0)
  local col = math.max(math.floor((vim.o.columns - width) / 2), 0)

  local renderer = n.create_renderer({
    width = width,
    height = height,
    relative = "editor",
    position = { row = row, col = col },
  })

  state.renderer = renderer
  state.signal = n.create_signal({
    header = "Loading...",
    transcript = "Loading...",
    prompt = state.prompt,
    status = state.status,
  })

  local function body()
    return n.rows(
      n.paragraph({
        lines = state.signal.header,
        border_style = "rounded",
        border_label = "Opencode",
        is_focusable = false,
        window = {
          highlight = {
            FloatBorder = "OpencodePanelBorder",
            FloatTitle = "OpencodePanelHeader",
            Normal = "OpencodePanelBg",
            NormalFloat = "OpencodePanelBg",
          },
        },
      }),
      n.paragraph({
        lines = state.signal.transcript,
        flex = 1,
        is_focusable = false,
        border_style = "rounded",
        border_label = "Conversation",
        window = {
          highlight = {
            FloatBorder = "OpencodePanelBorder",
            FloatTitle = "OpencodePanelHeader",
            Normal = "OpencodePanelConversation",
            NormalFloat = "OpencodePanelConversation",
          },
        },
      }),
      n.text_input({
        id = "prompt-input",
        border_label = "Prompt",
        max_lines = 6,
        autofocus = true,
        value = state.signal.prompt,
        on_change = function(value)
          state.prompt = value
          queue_signal_value("prompt", value)
        end,
        window = {
          highlight = {
            FloatBorder = "OpencodePanelBorder",
            FloatTitle = "OpencodePanelHeader",
            Normal = "OpencodePanelBg",
            NormalFloat = "OpencodePanelBg",
          },
        },
      }),
      n.paragraph({
        lines = "<S-CR> send | q close | r refresh | s sessions | m model | t thinking | n new | c cancel | p edits | ge next | gE prev | ga accept | gd reject",
        is_focusable = false,
        window = {
          highlight = {
            Normal = "OpencodePanelHelp",
            NormalFloat = "OpencodePanelHelp",
          },
        },
      }),
      n.paragraph({
        lines = state.signal.status,
        is_focusable = false,
        window = {
          highlight = {
            Normal = "OpencodePanelStatus",
            NormalFloat = "OpencodePanelStatus",
          },
        },
      })
    )
  end

  renderer:add_mappings({
    {
      mode = { "n", "i" },
      key = "<S-CR>",
      handler = submit_prompt,
    },
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
      handler = refresh_messages,
    },
    {
      mode = "n",
      key = "s",
      handler = select_session,
    },
    {
      mode = "n",
      key = "m",
      handler = select_model,
    },
    {
      mode = "n",
      key = "t",
      handler = select_variant,
    },
    {
      mode = "n",
      key = "n",
      handler = new_session,
    },
    {
      mode = "n",
      key = "p",
      handler = browse_edits,
    },
    {
      mode = "n",
      key = "c",
      handler = cancel_active_session,
    },
    {
      mode = "n",
      key = "ga",
      handler = accept_current_edit,
    },
    {
      mode = "n",
      key = "gd",
      handler = reject_current_edit,
    },
    {
      mode = "n",
      key = "ge",
      handler = jump_next_edit,
    },
    {
      mode = "n",
      key = "gE",
      handler = jump_prev_edit,
    },
  })

  renderer:on_unmount(function()
    stop_refresh_timer()
    stop_spinner()
    state.renderer = nil
    state.signal = nil
  end)

  sync_transcript()
  renderer:render(body)
end

function M.close()
  if state.renderer then
    state.renderer:close()
  end
end

function M.toggle()
  if state.renderer then
    M.close()
    return
  end

  M.open()
end

function M.select_session()
  select_session()
end

function M.select_model()
  select_model()
end

function M.select_variant()
  select_variant()
end

function M.new_session()
  new_session()
end

function M.browse_edits()
  browse_edits()
end

function M.accept_edit()
  accept_current_edit()
end

function M.reject_edit()
  reject_current_edit()
end

function M.next_edit()
  jump_next_edit()
end

function M.prev_edit()
  jump_prev_edit()
end

function M.setup(opts)
  config.setup(opts)
  state.current_agent = config.agent
  edits.setup()

  vim.api.nvim_create_user_command("OpencodePanel", function()
    M.toggle()
  end, { desc = "Toggle custom opencode panel" })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      process.stop()
    end,
  })
end

return M
