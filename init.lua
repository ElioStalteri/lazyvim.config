vim.opt.winborder = "rounded"
vim.opt.tabstop = 2
vim.opt.cursorcolumn = false
vim.opt.ignorecase = true
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.incsearch = true
vim.opt.signcolumn = "yes"

local map = vim.keymap.set

vim.g.mapleader = " "
-- map({ "n", "v", "x" }, "<leader>s", ":e #<CR>")
-- map({ "n", "v", "x" }, "<leader>S", ":sf #<CR>")

-- TODO: add go to references
vim.pack.add({
	{ src = "https://github.com/folke/trouble.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/supermaven-inc/supermaven-nvim" },
	-- { src = "kristijanhusak/vim-dadbod-ui" },
	-- { src = "tpope/vim-dadbod" },
	-- { src = "https://github.com/vague2k/vague.nvim" },
	{ src = "https://github.com/echasnovski/mini.icons" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	-- { src = "https://github.com/echasnovski/mini.pick" },
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/saghen/blink.cmp" },

	-- { src = "https://github.com/NvChad/showkeys", opt = true },
})

require("which-key").setup({
	preset = "helix",
})
require("mason").setup()
require("supermaven-nvim").setup({})
-- require("showkeys").setup({ position = "top-right" })
-- require("mini.pick").setup()
require("oil").setup()
require("trouble").setup({
	modes = {
		lsp = {
			win = { position = "right" },
		},
	},
})

require("blink.cmp").setup({
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = {
			download = true,
			force_version = "1.*"
		},
	},
	signature = {
		enabled = true,
	},
	cmdline = {
		completion = { menu = { auto_show = true } },
	},
	keymap = {
		preset = "default",
	},
	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "mono",
	},
	sources = {
		default = {
			"lsp",
			"path",
			"buffer",
		},
	},
	completion = {
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 500,
		},
		menu = {
			auto_show = true,
			draw = {
				columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" }, { "source_name" } },
			},
		},
	},
})


map("n", "<leader>cx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>cX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
map("n", "<leader>o", ":update<CR> :source<CR>")
map("n", "<leader>u", vim.pack.update)
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
map(
	"n",
	"<leader>q",
	-- "<CMD>UndotreeHide<CR><CMD>DBUIClose<CR><CMD>Neotree close<CR><CMD>confirm qa<CR>",
	"<CMD>confirm qa<CR>",
	{ desc = "Close All" }
)
map({ "n", "v", "x" }, "<leader>y", '"+y<CR>')
map({ "n", "v", "x" }, "<leader>p", '"+p<CR>')
map({ "n", "v", "x" }, "<leader>d", '"+d<CR>')

-- map("n", "<leader>sf", ":Pick files<CR>")
-- map("n", "<leader>sh", ":Pick help<CR>")
-- map("n", "<leader>td", "<cmd>DBUIToggle<cr>", { desc = "Toggle DBUI" })
map("n", "<leader>sf", require("fzf-lua").files)
map("n", "<leader>sg", require("fzf-lua").grep)
map("n", "<leader>gf", require("fzf-lua").git_files)
map("n", "<leader>sh", require("fzf-lua").helptags)
map("n", "<leader>sb", require("fzf-lua").buffers)
map("n", "gd", require("fzf-lua").lsp_definitions)
map("n", "gr", require("fzf-lua").lsp_references)

map("n", "-", ":Oil<CR>")
-- map("t", "", "")
-- map("t", "", "")
map("n", "<leader>cf", vim.lsp.buf.format)

vim.lsp.enable({ "lua_ls", "svelte", "tinymist", "emmetls" })
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			}
		}
	}
})

-- colors
-- require("vague").setup({ transparent = true })
-- vim.cmd("colorscheme vague")
vim.cmd("colorscheme ex-ofirkai")
vim.cmd(":hi statusline guibg=NONE")
