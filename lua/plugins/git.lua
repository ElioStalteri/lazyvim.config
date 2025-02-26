---@type LazyPluginSpec[]
return {
  -- {
  --   "kdheepak/lazygit.nvim",
  --   lazy = true,
  --   cmd = {
  --     "LazyGit",
  --     "LazyGitConfig",
  --     "LazyGitCurrentFile",
  --     "LazyGitFilter",
  --     "LazyGitFilterCurrentFile",
  --   },
  --   -- optional for floating window border decoration
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --   },
  --   -- setting the keybinding for LazyGit with 'keys' is recommended in
  --   -- order to load the plugin when the command is run for the first time
  --   keys = {
  --     { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
  --   },
  -- },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    opts = {
      default_mappings = {
        ours = "<leader>Co",
        theirs = "<leader>Ct",
        none = "<leader>C0",
        both = "<leader>Cb",
        next = "<leader>Cn",
        prev = "<leader>Cp",
      },
    },
  },
  -- {
  --   "sindrets/diffview.nvim",
  --   opts = {
  --     view = {
  --       merge_tool = {
  --         layout = "diff1_plain",
  --         disable_diagnostics = true, -- Temporarily disable diagnostics for diff buffers while in the view.
  --         winbar_info = true, -- See |diffview-config-view.x.winbar_info|
  --       },
  --     },
  --   },
  --   keys = {
  --     { "<leader>go", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
  --     { "<leader>ge", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
  --     { "<leader>gf", "<cmd>DiffviewToggleFiles<cr>", desc = "Diffview files toggle" },
  --   },
  -- },
  -- {
  --   "tpope/vim-fugitive",
  --   opts = {},
  --   keys = {
  --     { "<leader>gcl", "<cmd>Git mergetool<cr>", desc = "Open conflic list" },
  --     { "<leader>gcd", "<cmd>Gdiff<cr>", desc = "open diff view" },
  --   },
  -- },
  -- {
  --   "NeogitOrg/neogit",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim", -- required
  --     "sindrets/diffview.nvim", -- optional - Diff integration
  --
  --     -- Only one of these is needed.
  --     "nvim-telescope/telescope.nvim", -- optional
  --     "ibhagwan/fzf-lua", -- optional
  --     "echasnovski/mini.pick", -- optional
  --   },
  --   config = true,
  --   keys = {
  --     { "<leader>gG", "<cmd>Neogit<cr>", desc = "NeoGit" },
  --   },
  -- },
}
