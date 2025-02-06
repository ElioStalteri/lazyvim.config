---@type LazyPluginSpec[]
return {
  {
    "chrisgrieser/nvim-scissors",
    dependencies = "nvim-telescope/telescope.nvim",
    opts = {
      snippetDir = vim.fn.stdpath("config") .. "/snippets",
    },
    keys = {
      {
        "<leader>cse",
        function()
          require("scissors").editSnippet()
        end,
        mode = { "n" },
        desc = "Snippet: Edit",
      },
      {
        "<leader>csa",
        function()
          require("scissors").addNewSnippet()
        end,
        mode = { "n", "x" },
        desc = "Snippet: Add",
      },
    },
  },
}
