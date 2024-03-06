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
  { "nvim-treesitter/playground" },
  -- { "ofirgall/ofirkai.nvim", lazy = false },
  { "ElioStalteri/ofirkai.nvim", lazy = false, opts = { custom_theme = true } },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "ofirkai-custom",
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
  { "folke/zen-mode.nvim" },
  {
    "stevearc/overseer.nvim",
    opts = {},
  },
}
