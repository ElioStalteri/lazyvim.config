return {
  {
    "diepm/vim-rest-console",
    config = function()
      vim.g.vrc_set_default_mapping = 0
      vim.g.vrc_response_default_content_type = "application/json"
      vim.g.vrc_output_buffer_name = "_RESPONSE.json"
      vim.g.vrc_auto_format_response_patterns = {
        json = "jq",
      }
    end,
  },
  -- {
  --   "rest-nvim/rest.nvim",
  --   keys = {
  --     { "<leader>tr", "<cmd>Rest run<cr>", desc = "Run HTTP request" },
  --   },
  -- },
}
