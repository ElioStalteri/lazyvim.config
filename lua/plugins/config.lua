return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      -- { "kristijanhusak/vim-dadbod-completion", lazy = true, ft = { "sql", "mysql", "plsql" } },
    },
  },
  { "mbbill/undotree" },
  {
    "neovim/nvim-lspconfig",
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- change a keymap
      keys[#keys + 1] = { mode = { "n" }, "gr", "<cmd>Trouble lsp_references<cr>", desc = "References" }
    end,
  },
  -- { "rose-pine/neovim", name = "rose-pine" },
  {
    "Iron-E/nvim-highlite",
    config = function()
      -- OPTIONAL: setup the plugin. See "Configuration" for information
      require("highlite").setup({ generator = { plugins = { vim = false }, syntax = false } })

      -- or one of the alternate colorschemes (see the "Built-in Colorschemes" section)
      vim.api.nvim_command("colorscheme highlite")
    end,
    lazy = false,
    priority = math.huge,
    version = "^4.0.0",
  },
  { "nvim-treesitter/playground" },
  { "bluz71/vim-nightfly-colors", name = "nightfly", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "sublime",
      -- colorscheme = "rose-pine-moon",
    },
  },
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "svelte",
        "sql",
        "http",
        "json",
      })
    end,
  },
  -- { "mg979/vim-visual-multi" },
  { "folke/zen-mode.nvim" },
  {
    "j-hui/fidget.nvim",
    lazy = false,
    config = function()
      require("fidget").setup({})
    end,
  },
}
