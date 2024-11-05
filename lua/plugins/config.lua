return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      -- { "kristijanhusak/vim-dadbod-completion", lazy = true, ft = { "sql", "mysql", "plsql" } },
    },
  },
  { "mbbill/undotree" },
  -- { "nvim-treesitter/playground" },
  -- { "ofirgall/ofirkai.nvim", lazy = false },
  { "rose-pine/neovim", lazy = false, name = "rose-pine" },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    "ElioStalteri/ofirkai.nvim",
    lazy = false,
    opts = { custom_theme = true },
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.cmd.colorscheme("ofirkai-custom")
    end,
  },
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        width = 140,
      },
    },
    keys = {
      { "<leader>z", "<cmd>ZenMode<cr>", desc = "Toggle zen mode" },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    lazy = false,
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-/>]],
        shade_terminals = false,
      })
    end,
    keys = {
      { [[<C-/>]] },
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    },
  },
  {
    "stevearc/oil.nvim",
    opts = {
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name)
          return name == ".."
        end,
      },
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  -- { "tpope/vim-fugitive" },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons", "folke/edgy.nvim" },
    opts = {},
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    opts = {
      dir = vim.fn.stdpath("state") .. "/sessions/", -- directory where session files are saved
      -- minimum number of file buffers that need to be open to save
      -- Set to 0 to always save
      need = 1,
      branch = true, -- use git branch to save session
    },
    -- keys = {
    --   {
    --     "<leader>qs",
    --     function()
    --       require("persistence").load()
    --     end,
    --     desc = "Restore Session",
    --   },
    --   {
    --     "<leader>qS",
    --     function()
    --       require("persistence").select()
    --     end,
    --     desc = "Select Session",
    --   },
    --   {
    --     "<leader>ql",
    --     function()
    --       require("persistence").load({ last = true })
    --     end,
    --     desc = "Restore Last Session",
    --   },
    --   {
    --     "<leader>qd",
    --     function()
    --       require("persistence").stop()
    --     end,
    --     desc = "Don't Save Current Session",
    --   },
    -- },
  },
}
