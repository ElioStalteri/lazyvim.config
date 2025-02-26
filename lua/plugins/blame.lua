---@type LazyPluginSpec[]
return {
  {
    "FabijanZulj/blame.nvim",
    lazy = false,
    opts = {
      blame_options = { "-w" },
    },
    keys = {
      { "<leader>gb", "<cmd>BlameToggle<cr>", desc = "Toggle blame" },
    },
  },
}
