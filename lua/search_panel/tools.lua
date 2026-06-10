local M = {}

local cache = {
  rg = nil,
  sd = nil,
}

function M.has_tool(cmd, refresh)
  if refresh or cache[cmd] == nil then
    cache[cmd] = vim.fn.executable(cmd) == 1
  end

  return cache[cmd]
end

function M.has_rg(refresh)
  return M.has_tool("rg", refresh)
end

function M.has_sd(refresh)
  return M.has_tool("sd", refresh)
end

return M
