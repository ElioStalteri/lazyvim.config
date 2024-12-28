return {
  {
    "Exafunction/codeium.vim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    event = "BufEnter",
    -- config = function()
    --   vim.g.codeium_no_map_tab = true
    -- end,
    keys = {
      { "<leader>ac", "<cmd>Codeium Chat<cr>", desc = "open chat" },
      { "<leader>aa", "<cmd>Codeium Auth<cr>", desc = "auth" },
      { "<leader>at", "<cmd>Codeium Toggle<cr>", desc = "Toggle" },
      { mode = { "i" }, "<C-c>", "<Cmd>call codeium#Clear()<CR>", desc = "Clear suggestion" },
      -- WARN: <C-y> does'n work :(
      -- { mode = { "i" }, "<C-y>", "<Cmd>call codeium#Accept()<CR>", desc = "Accept suggestion" },
      { mode = { "i" }, "<C-n>", "<Cmd>call codeium#CycleCompletions(1)<CR>", desc = "Next suggestion" },
      { mode = { "i" }, "<C-p>", "<Cmd>call codeium#CycleCompletions(-1)<CR>", desc = "Previous suggestion" },
    },
  },
}
