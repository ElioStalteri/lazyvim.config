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
    "robitx/gp.nvim",
    lazy = false,
    opts = {
      providers = {
        googleai = {
          endpoint = "https://generativelanguage.googleapis.com/v1beta/models/{{model}}:streamGenerateContent?key={{secret}}",
          secret = os.getenv("AI_API_KEY"),
        },
      },
    },
    keys = {
      { "<leader>at", "<cmd>GpChatToggle vsplit<cr>", desc = "toggle chat" },
      { "<leader>af", "<cmd>GpChatFinder<cr>", desc = "chat finder" },
      { "<leader>ac", "<cmd>GpContext<cr>", desc = "toggle context" },
      { "<leader>ap", ":<C-u>'<,'>GpChatPaste<cr>", desc = "paste chat", mode = { "v" } },
      { "<leader>ar", ":<C-u>'<,'>GpRewrite<cr>", desc = "rewrite", mode = { "v" } },
      { "<leader>aa", ":<C-u>'<,'>GpAppend<cr>", desc = "append", mode = { "v" } },
      { "<leader>ai", ":<C-u>'<,'>GpImplement<cr>", desc = "implement", mode = { "v" } },
    },
  },
}
