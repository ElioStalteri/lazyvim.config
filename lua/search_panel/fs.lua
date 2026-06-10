local uv = vim.uv

local M = {}

function M.read_file(path)
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

function M.write_file(path, content)
  local fd, open_err = uv.fs_open(path, "w", 420)
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

function M.get_line_start_index(content, lnum)
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

function M.reload_buffer_if_loaded(path)
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

return M
