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
map("n", "<leader>dd", "<cmd>DBUIToggle<cr>", { desc = "Toggle DBUI" })
-- map("n", "<leader>z", "<cmd>ZenMode<cr>", { desc = "Toggle ZenMode" })
--
-- map("v", "<leader>r", '"hy:%s/<C-r>h//g<left><left>', { desc = "Replace all instances of highlighted words" })
-- map("v", "<leader>S", ":sort<CR>", { desc = "Sort highlighted text in visual mode with Control+" })
-- -- map("n", "<leader>k", "v:m '>-2<CR>gv=gv<C-c>", { desc = "Move current line up" })
-- -- map("n", "<leader>j", "v:m '>+1<CR>gv=gv<C-c>", { desc = "Move current line dow" })
--
-- map("v", "\\p", '"_dP', { desc = "paste without looding copy register" })
--
map("n", "<leader>u", ":UndotreeToggle<CR>", { desc = "Toggle undo tree" })
--
-- map("n", "<leader>ctt", ":OverseerToggle<CR>", { desc = "Toggle task runner" })
-- map("n", "<leader>ctr", ":OverseerRun<CR>", { desc = "Run task" })
--
-- map("n", "<leader>gdo", ":DiffviewOpen<CR>", { desc = "Open Diffview" })
-- map("n", "<leader>gdh", ":DiffviewFileHistory<CR>", { desc = "Open Diffview file history" })
-- map("n", "<leader>gdc", ":DiffviewClose<CR>", { desc = "Close Diffview" })

-- real inspiration for a minimal config
-- https://gitlab.com/linuxdabbler/dotfiles/-/blob/main/.config/nvim/init.lua?ref_type=heads#L151

map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

map("n", "<leader>q", ":confirm qa<CR>", { desc = "Close All" })
map("n", "<C-s>", ":w<CR>", { desc = "Save" })

map("n", "<leader>w", "<c-w>", { desc = "Windows", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })
map("n", "<leader>bd", ":bd<cr>", { desc = "Delete Buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
