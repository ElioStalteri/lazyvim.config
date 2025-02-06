---@type LazyPluginSpec[]
return {
  -- {
  --   "diepm/vim-rest-console",
  --   config = function()
  --     vim.g.vrc_set_default_mapping = 0
  --     vim.g.vrc_response_default_content_type = "application/json"
  --     vim.g.vrc_output_buffer_name = "_RESPONSE.json"
  --     vim.g.vrc_auto_format_response_patterns = {
  --       json = "jq",
  --     }
  --     map("n", "<leader>xr", ":call VrcQuery()<CR>", { desc = "exec HTTP request" })
  --   end,
  -- },
  { -- https://kulala.mwco.app/
    "mistweaverco/kulala.nvim",
    opts = {},
    keys = {
      { "<leader>xr", "<cmd>lua require('kulala').run()<cr>", desc = "Run HTTP request" },
      { "<leader>xR", "<cmd>lua require('kulala').run_all()<cr>", desc = "Run ALL HTTP request" },
      { "<leader>xi", "<cmd>lua require('kulala').inspect()<cr>", desc = "Inspect HTTP request" },
      { "<leader>xc", "<cmd>lua require('kulala').copy()<cr>", desc = "Copy HTTP request as CUrl" },
      {
        "<leader>xC",
        "<cmd>lua require('kulala').from_curl()<cr>",
        desc = "Paste curl from clipboard as http request",
      },
    },
  },
  -- {
  --   "rest-nvim/rest.nvim",
  --   keys = {
  --     { "<leader>tr", "<cmd>Rest run<cr>", desc = "Run HTTP request" },
  --   },
  -- },
}
