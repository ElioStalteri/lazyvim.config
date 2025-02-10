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

vim.keymap.set({ "n", "i", "s" }, "<c-f>", function()
  if not require("noice.lsp").scroll(4) then
    return "<c-f>"
  end
end, { silent = true, expr = true })

vim.keymap.set({ "n", "i", "s" }, "<c-b>", function()
  if not require("noice.lsp").scroll(-4) then
    return "<c-b>"
  end
end, { silent = true, expr = true })

map("n", "<leader>td", "<cmd>DBUIToggle<cr>", { desc = "Toggle DBUI" })
-- map("n", "<leader>z", "<cmd>ZenMode<cr>", { desc = "Toggle ZenMode" })
--
-- map("v", "<leader>r", '"hy:%s/<C-r>h//g<left><left>', { desc = "Replace all instances of highlighted words" })
-- map("v", "<leader>S", ":sort<CR>", { desc = "Sort highlighted text in visual mode with Control+" })
-- -- map("n", "<leader>k", "v:m '>-2<CR>gv=gv<C-c>", { desc = "Move current line up" })
-- -- map("n", "<leader>j", "v:m '>+1<CR>gv=gv<C-c>", { desc = "Move current line dow" })
--
-- map("v", "\\p", '"_dP', { desc = "paste without looding copy register" })
--

map("v", "p", "P", { desc = "paste without looding copy register" })
map("n", "c", '"_c', { desc = "change without looding copy register" })
map("n", "C", '"_C', { desc = "change without looding copy register" })

map("n", "<leader>tu", ":UndotreeToggle<CR>", { desc = "Toggle undo tree" })

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

map(
  "n",
  "<leader>q",
  "<CMD>UndotreeHide<CR><CMD>DBUIClose<CR><CMD>Neotree close<CR><CMD>confirm qa<CR>",
  { desc = "Close All" }
)
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
-- map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })
-- map("n", "<leader>bd", ":bd<cr>", { desc = "Delete Buffer" })

map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
-- map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
-- map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- treewalker
-- movement
vim.keymap.set({ "n" }, "<C-S-k>", "<cmd>Treewalker Up<cr>", { silent = true, noremap = true })
vim.keymap.set({ "n" }, "<C-S-j>", "<cmd>Treewalker Down<cr>", { silent = true, noremap = true })
vim.keymap.set({ "n" }, "<A-h>", "<cmd>Treewalker Left<cr>", { silent = true, noremap = true })
vim.keymap.set({ "n" }, "<A-l>", "<cmd>Treewalker Right<cr>", { silent = true, noremap = true })

-- swapping
-- vim.keymap.set({ "v" }, "<C-k>", "<cmd>Treewalker SwapUp<cr>", { silent = true })
-- vim.keymap.set({ "v" }, "<C-j>", "<cmd>Treewalker SwapDown<cr>", { silent = true })
vim.keymap.set({ "v" }, "<A-h>", "<cmd>Treewalker SwapLeft<CR>", { silent = true })
vim.keymap.set({ "v" }, "<A-l>", "<cmd>Treewalker SwapRight<CR>", { silent = true })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

map("n", "<leader>ut", "<cmd>Telescope themes<cr>", { desc = "change theme" })

-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", "<cmd>InspectTree<cr>", { desc = "Inspect Tree" })

map("n", "<leader>fo", "<cmd>copen<cr>", { desc = "open quick fix" })
map("n", "<leader>fc", "<cmd>cclose<cr>", { desc = "close quick fix" })
map("n", "<M-j>", "<cmd>cnext<cr>", { desc = "next quick fix" })
map("n", "<M-k>", "<cmd>cprev<cr>", { desc = "prev quick fix" })
map("n", "<leader>fd", function()
  vim.fn.setqflist({}, "r")
end, { desc = "delete quick fix" })
