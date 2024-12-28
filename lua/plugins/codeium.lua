return {
  {
    "Exafunction/codeium.vim",
    event = "BufEnter",
    keys = {
      { "<leader>ac", "<cmd>Codeium Chat<cr>", desc = "open chat" },
      { "<leader>aa", "<cmd>Codeium Auth<cr>", desc = "auth" },
      { "<leader>at", "<cmd>Codeium Toggle<cr>", desc = "Toggle" },
    },
  },
}
