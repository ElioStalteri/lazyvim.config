-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    if opts.desc then
      opts.desc = opts.desc
    end
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

map("n", "<C-d>", "<C-d>zz", { remap = true })
map("n", "<C-u>", "<C-u>zz", { remap = true })
map("n", "<leader>d", "<cmd>DBUIToggle<cr>", { desc = "Toggle DBUI" })
map("n", "<leader>z", "<cmd>ZenMode<cr>", { desc = "Toggle ZenMode" })

map("v", "<leader>r", '"hy:%s/<C-r>h//g<left><left>', { desc = "Replace all instances of highlighted words" })
map("v", "<leader>S", ":sort<CR>", { desc = "Sort highlighted text in visual mode with Control+" })
map("v", "<leader>j", ":m '>+1<CR>gv=gv", { desc = "Move current line dow" })
map("v", "<leader>k", ":m '>-2<CR>gv=gv", { desc = "Move current line up" })
