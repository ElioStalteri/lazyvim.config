local M = {
  renderer = nil,
  signal = nil,
  prompt = "",
  status = "Idle",
  spinner_index = 1,
  spinner_timer = nil,
  loading = false,
  subscriptions_ready = false,
  event_job = nil,
  refresh_timer = nil,
  sessions = {},
  messages = {},
  providers = nil,
  active_session = nil,
  current_model = nil,
  current_variant = nil,
  current_agent = nil,
  pending_edits = {},
}

return M
