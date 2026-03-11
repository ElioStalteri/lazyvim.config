---@type LazyPluginSpec[]
return {
  {
    "esmuellert/vscode-diff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = "CodeDiff",
    keys = {
      { "<leader>gd", "<cmd>CodeDiff<cr>", desc = "Toggle diff" },
    },
  },
  {
    "FabijanZulj/blame.nvim",
    cmd = { "BlameToggle" },
    opts = {
      blame_options = { "-w" },
    },
    keys = {
      { "<leader>gb", "<cmd>BlameToggle<cr>", desc = "Toggle blame" },
    },
  },
}
