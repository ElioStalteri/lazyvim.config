---@type LazyPluginSpec[]
return {
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    opts = {
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
      },
    },
  },
  -- {
  --   "sudo-tee/opencode.nvim",
  --   event = "VeryLazy",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     {
  --       "MeanderingProgrammer/render-markdown.nvim",
  --       opts = {
  --         anti_conceal = { enabled = false },
  --         file_types = { "markdown", "opencode_output" },
  --       },
  --       ft = { "markdown", "Avante", "copilot-chat", "opencode_output" },
  --     },
  --     "saghen/blink.cmp",
  --     "folke/snacks.nvim",
  --   },
  --   config = function()
  --     require("opencode").setup({
  --       keymap_prefix = "<leader>a",
  --     })
  --   end,
  -- },
}
