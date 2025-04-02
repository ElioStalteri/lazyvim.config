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
  -- commit-ai
  {
    "Abizrh/commit-ai.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      icons = true,
      -- unopiniated commit conventions
      git_conventions = {
        docs = { icon = "📖", prefix = "docs", type = "Documentation changes" },
        fix = { icon = "🐛", prefix = "fix", type = "Bug fix" },
        feat = { icon = "✨", prefix = "feat", type = "New feature" },
        enhance = { icon = "⚡", prefix = "enhance", type = "Enhancement" },
        chore = { icon = "🧹", prefix = "chore", type = "Chore" },
        refactor = { icon = "⚠️", prefix = "refactor", type = "Breaking change" },
      },
      provider_options = {
        gemini = {
          model = "gemini-2.0-flash",
          api_key = os.getenv("AI_API_KEY"),
          stream = false,
        },
      },
    },
    keys = {
      { "<leader>gm", "<cmd>Commit<cr>", desc = "generate commit message" },
    },
  },
}
