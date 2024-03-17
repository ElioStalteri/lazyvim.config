-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Disable autoformat
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "*" },
  callback = function()
    ---@diagnostic disable-next-line: inject-field
    vim.b.autoformat = false
  end,
})

local function disableTS()
  vim.cmd("TSBufDisable autotag")
  vim.cmd("TSBufDisable highlight")
  vim.cmd("TSBufDisable incremental_selection")
  vim.cmd("TSBufDisable indent")
  vim.cmd("TSBufDisable playground")
  vim.cmd("TSBufDisable query_linter")
  vim.cmd("TSBufDisable rainbow")
  vim.cmd("TSBufDisable refactor.highlight_definitions")
  vim.cmd("TSBufDisable refactor.navigation")
  vim.cmd("TSBufDisable refactor.smart_rename")
  vim.cmd("TSBufDisable refactor.highlight_current_scope")
  vim.cmd("TSBufDisable textobjects.swap")
  vim.cmd("TSBufDisable textobjects.move")
  vim.cmd("TSBufDisable textobjects.lsp_interop")
  vim.cmd("TSBufDisable textobjects.select")
end

local MAX_LINE_SIZE = 1000
local MAX_FILE_SIZE = 50000

local function loadLargeFiles()
  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()))
  local lines = tonumber(vim.fn.system({ "wc", "-l", vim.fn.expand("%") }):match("%d+"))
  local avgLineSize = ok and stats and stats.size / lines or 0
  -- print("avgLineSize")
  -- vim.print(avgLineSize)

  -- print("lines")
  -- vim.print(lines)
  -- print("stats")
  -- vim.print(stats)

  if (ok and stats and stats.size > MAX_FILE_SIZE) or avgLineSize > MAX_LINE_SIZE then
    ---@diagnostic disable-next-line: inject-field
    vim.b.large_buf = true
    vim.cmd("syntax off")
    disableTS()
    vim.cmd("IlluminatePauseBuf") -- disable vim-illuminate
    vim.cmd("IBLDisable") -- disable indent-blankline.nvim
    vim.cmd("LspStop") -- disable indent-blankline.nvim
    ---@diagnostic disable-next-line: inject-field
    vim.b.miniindentscope_disable = true
    vim.opt_local.spell = false
  else
    ---@diagnostic disable-next-line: inject-field
    vim.b.large_buf = false
  end
end

local aug = vim.api.nvim_create_augroup("buf_large", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufEnter", "LspAttach" }, {
  callback = loadLargeFiles,
  group = aug,
  pattern = "*",
})
