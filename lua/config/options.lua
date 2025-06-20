-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- vim.opt.fillchars = { fold = " " }
vim.opt.foldmethod = "indent"
vim.opt.foldenable = false
vim.opt.foldlevel = 99
vim.opt.shiftround = true -- Round indent
vim.opt.expandtab = true -- expand tab input with spaces characters
vim.opt.smartindent = true --  syntax aware indentations for newline inserts
vim.opt.tabstop = 2 -- num of space characters per tab
vim.opt.shiftwidth = 2 -- spaces per indentation level
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.smartcase = true -- Don't ignore case with capitals
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.spelllang = { "en" }
vim.g.markdown_folding = 1 -- enable markdown folding
vim.opt.termguicolors = true
-- vim.g.autoformat = false
-- vim.g.lazygit_config = false
-- vim.opt.clipboard = "unnamed,unnamedplus"
