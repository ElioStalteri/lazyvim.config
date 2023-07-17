-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- local opt = vim.opt
-- opt.foldmethod = "expr"
-- opt.foldexpr = "nvim_treesitter#foldexpr()"
--

vim.opt.fillchars      = { fold = " " }
vim.opt.foldmethod     = "indent"
vim.opt.foldenable     = false
vim.opt.foldlevel      = 99
vim.g.markdown_folding = 1 -- enable markdown folding

vim.g.VM_theme         = 'purplegray'
vim.g.VM_Mono_hl       = 'DiffText'
vim.g.VM_Extend_hl     = 'DiffAdd'
vim.g.VM_Cursor_hl     = 'Visual'
vim.g.VM_Insert_hl     = 'DiffChange'
