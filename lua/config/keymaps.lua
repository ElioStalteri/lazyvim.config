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

-- map("n", "<C-d>", "<C-d>zz", { remap = true })
-- map("n", "<C-u>", "<C-u>zz", { remap = true })
vim.keymap.set("n", "<C-U>", function()
  require("cinnamon").scroll("<C-U>zz")
end)
vim.keymap.set("n", "<C-D>", function()
  require("cinnamon").scroll("<C-D>zz")
end)

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
map("n", "<leader>tu", ":UndotreeToggle<CR>", { desc = "Toggle undo tree" })

map("n", "<leader>xr", ":call VrcQuery()<CR>", { desc = "exec HTTP request" })
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
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
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
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", "<cmd>InspectTree<cr>", { desc = "Inspect Tree" })
