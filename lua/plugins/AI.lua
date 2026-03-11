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
  --   "ThePrimeagen/99",
  --   config = function()
  --     local _99 = require("99")
  --
  --     _99.setup({
  --       model = "opencode/mimo-v2-flash-free",
  --       tmp_dir = "./tmp",
  --     })
  --
  --     vim.keymap.set("n", "<leader>aa", function()
  --       _99.search()
  --     end, { desc = "AI Search" })
  --
  --     vim.keymap.set("v", "<leader>aa", function()
  --       _99.visual()
  --     end, { desc = "AI Visual" })
  --
  --     vim.keymap.set("n", "<leader>av", function()
  --       _99.vibe()
  --     end, { desc = "AI Vibe" })
  --
  --     vim.keymap.set("n", "<leader>ao", function()
  --       _99.open()
  --     end, { desc = "AI Open" })
  --
  --     vim.keymap.set("n", "<leader>am", function()
  --       require("99.extensions.fzf_lua").select_model()
  --     end, { desc = "AI Model" })
  --
  --     vim.keymap.set("n", "<leader>al", function()
  --       _99.view_logs()
  --     end, { desc = "AI Logs" })
  --
  --     vim.keymap.set("n", "<leader>ax", function()
  --       _99.stop_all_requests()
  --     end, { desc = "AI Stop" })
  --   end,
  -- },

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
