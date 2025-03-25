---@type LazyPluginSpec[]
return {
  {
    "supermaven-inc/supermaven-nvim",
    lazy = false,
    opts = {
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        -- accept_word = "<C-j>",
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        display = { chat = { window = { layout = "float", height = 0.9, width = 0.9 } } },
        strategies = {
          chat = {
            adapter = "gemini",
          },
          inline = {
            adapter = "gemini",
          },
          workflow = {
            adapter = "gemini",
          },
        },
        adapters = {
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              env = {
                api_key = os.getenv("AI_API_KEY"),
                model = "gemini-2.0-flash", -- "gemini-2.5-pro-exp-03-25"
              },
            })
          end,
        },
      })
    end,
    keys = {
      { "<leader>at", "<cmd>CodeCompanionChat toggle<cr>", desc = "toggle chat" },
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "actions" },
      { "<leader>ap", "<cmd>CodeCompanion<cr>", desc = "prompt", mode = { "n" } },
      { "<leader>ap", ":'<,'>CodeCompanion<cr>", desc = "prompt", mode = { "v" } },
    },
  },
}
