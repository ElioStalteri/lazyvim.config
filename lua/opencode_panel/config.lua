local M = {}

M.defaults = {
  keymap_prefix = "<leader>a",
  server = {
    command = "opencode",
    host = "127.0.0.1",
    port = 41173,
    startup_timeout_ms = 12000,
    startup_poll_ms = 150,
  },
  ui = {
    width_ratio = 0.46,
    height_ratio = 0.74,
    min_width = 72,
    min_height = 18,
  },
  agent = "build",
  show_reasoning = false,
}

M.values = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.values = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
  return M.values
end

return setmetatable(M, {
  __index = function(_, key)
    return M.values[key]
  end,
})
