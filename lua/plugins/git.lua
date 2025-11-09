---@type LazyPluginSpec[]
return {
  {
    "ahkohd/difft.nvim",
    keys = {
      {
        "<leader>gd",
        function()
          if Difft.is_visible() then
            Difft.hide()
          else
            Difft.diff()
          end
        end,
        desc = "Toggle diff",
      },
      {
        "<leader>gD",
        function()
          if Difft.is_visible() then
            Difft.hide()
          else
            Difft.diff({ cmd = "GIT_EXTERNAL_DIFF='difft --color=always' git diff HEAD^ HEAD" })
          end
        end,
        desc = "Toggle diff last commit",
      },
    },
    config = function()
      require("difft").setup({
        command = "GIT_EXTERNAL_DIFF='difft --color=always' git diff", -- or "jj diff --no-pager"
        layout = "ivy_taller", -- nil (buffer), "float", or "ivy_taller"
      })
    end,
  },
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
