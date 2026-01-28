return {
  {
    "supermaven-inc/supermaven-nvim",
    lazy = false,
    opts = {
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
      },
    },
  },

  {
    "sudo-tee/opencode.nvim",
    config = function()
      require("opencode").setup({
        keymap_prefix = "<leader>a",
      })
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          anti_conceal = { enabled = false },
          file_types = { "markdown", "opencode_output" },
        },
        ft = { "markdown", "Avante", "copilot-chat", "opencode_output" },
      },
      "saghen/blink.cmp",
      "folke/snacks.nvim",
    },
  },

  -- {
  --   "NickvanDyke/opencode.nvim",
  --   dependencies = {
  --     -- Recommended for `ask()` and `select()`.
  --     -- Required for `snacks` provider.
  --     ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
  --     { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  --   },
  --   config = function()
  --     ---@type opencode.Opts
  --     vim.g.opencode_opts = {
  --       -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
  --     }
  --
  --     -- Required for `opts.events.reload`.
  --     vim.o.autoread = true
  --   end,
  --   keys = {
  --     {
  --       "<leader>at",
  --       function()
  --         require("opencode").toggle()
  --       end,
  --       desc = "Toggle opencode",
  --     },
  --     {
  --       "<leader>aa",
  --       function()
  --         require("opencode").ask("@this: ", { submit = true })
  --       end,
  --       desc = "Ask opencode",
  --     },
  --     {
  --       "<leader>ax",
  --       function()
  --         require("opencode").select()
  --       end,
  --       desc = "Execute opencode action…",
  --     },
  --   },
  -- },
}
