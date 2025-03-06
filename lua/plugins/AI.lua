---@type LazyPluginSpec[]
return {
  {
    "supermaven-inc/supermaven-nvim",
    lazy = false,
    opts = {
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        accept_word = "<C-j>",
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
                model = "gemini-2.0-flash",
              },
            })
          end,
        },
      })
    end,
    keys = {
      { "<leader>at", "<cmd>CodeCompanionChat toggle<cr>", desc = "toggle chat" },
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "actions" },
    },
  },
  -- {
  --   "robitx/gp.nvim",
  --   lazy = false,
  --   opts = {
  --     providers = {
  --       googleai = {
  --         -- endpoint = "https://generativelanguage.googleapis.com/v1beta/models/{{model}}:streamGenerateContent?key={{secret}}",
  --         secret = os.getenv("AI_API_KEY"),
  --       },
  --     },
  --     agents = {
  --       {
  --         provider = "googleai",
  --         name = "ChatGemini",
  --         chat = true,
  --         command = true,
  --         model = { model = "gemini-2.0-flash", temperature = 0.8, top_p = 1 },
  --         system_prompt = "You are a general AI assistant.\n\n"
  --           .. "The user provided the additional info about how they would like you to respond:\n\n"
  --           .. "- If you're unsure don't guess and say you don't know instead.\n"
  --           .. "- Ask question if you need clarification to provide better answer.\n"
  --           .. "- Think deeply and carefully from first principles step by step.\n"
  --           .. "- Zoom out first to see the big picture and then zoom in to details.\n"
  --           .. "- Use Socratic method to improve your thinking and coding skills.\n"
  --           .. "- Don't elide any code from your output if the answer requires coding.\n"
  --           .. "- Take a deep breath; You've got this!\n",
  --       },
  --     },
  --   },
  --   keys = {
  --     { "<leader>at", "<cmd>GpChatToggle vsplit<cr>", desc = "toggle chat" },
  --     { "<leader>af", "<cmd>GpChatFinder<cr>", desc = "chat finder" },
  --     { "<leader>ac", "<cmd>GpContext<cr>", desc = "toggle context" },
  --     { "<leader>ap", ":<C-u>'<,'>GpChatPaste<cr>", desc = "paste chat", mode = { "v" } },
  --     { "<leader>ar", ":<C-u>'<,'>GpRewrite<cr>", desc = "rewrite", mode = { "v" } },
  --     { "<leader>aa", ":<C-u>'<,'>GpAppend<cr>", desc = "append", mode = { "v" } },
  --     { "<leader>ai", ":<C-u>'<,'>GpImplement<cr>", desc = "implement", mode = { "v" } },
  --   },
  -- },
}
