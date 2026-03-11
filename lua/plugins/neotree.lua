---@type LazyPluginSpec[]
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = { "Neotree" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
    {
      "s1n7ax/nvim-window-picker",
      version = "2.*",
      config = function()
        require("window-picker").setup({
          filter_rules = {
            include_current_win = false,
            autoselect_one = true,
            -- filter using buffer options
            bo = {
              -- if the file type is one of following, the window will be ignored
              filetype = { "neo-tree", "neo-tree-popup", "notify" },
              -- if the buffer type is one of following, the window will be ignored
              buftype = { "terminal", "quickfix" },
            },
          },
        })
      end,
    },
  },
  opts = {
    close_if_last_window = true,
    filesystem = {
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
    },
    event_handlers = {
      {
        event = "neo_tree_buffer_enter",
        handler = function()
          vim.cmd([[
              setlocal relativenumber
            ]])
        end,
      },
    },
  },
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
    { "<leader>gs", "<cmd>Neotree toggle git_status<cr>", desc = "Toggle file changed" },
  },
}
