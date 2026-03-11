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
  local ok, noice_lsp = pcall(require, "noice.lsp")
  if not ok or not noice_lsp.scroll(4) then
    return "<c-f>"
  end
end, { silent = true, expr = true })

vim.keymap.set({ "n", "i", "s" }, "<c-b>", function()
  local ok, noice_lsp = pcall(require, "noice.lsp")
  if not ok or not noice_lsp.scroll(-4) then
    return "<c-b>"
  end
end, { silent = true, expr = true })

-- scroll up and down
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll Up" })
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll Down" })

map("n", "<leader>td", "<cmd>DBUIToggle<cr>", { desc = "Toggle DBUI" })
map("v", "<leader>r", '"hy:%s/<C-r>h//g<left><left>', { desc = "Replace all instances of highlighted words" })

map("n", "<leader>q", function()
  pcall(vim.cmd, "Atone close")
  pcall(vim.cmd, "DBUIClose")
  pcall(vim.cmd, "Neotree close")
  vim.cmd("confirm qa")
end, { desc = "Close All" })
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })

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
map("n", "<C-A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<C-A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<C-A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<C-A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<C-A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<C-A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

map("n", "<leader>ut", "<cmd>FzfLua colorschemes<cr>", { desc = "change theme" })

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

map("n", "<leader>y", function()
  local file_path = vim.fn.expand("%:p")
  local git_root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("\n", "")

  if git_root ~= "" and vim.v.shell_error == 0 then
    file_path = file_path:sub(#git_root + 2)
  end

  vim.fn.setreg("+", file_path)
  vim.notify("Copied: " .. file_path, vim.log.levels.INFO)
end, { desc = "copy path (relative to git root)" })
