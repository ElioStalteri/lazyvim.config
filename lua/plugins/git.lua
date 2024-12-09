return {
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    opts = { default_mappings = true },
    keys = {
      { "<leader>gci", "<cmd>GitConflictChooseTheirs<cr>", desc = "Accept incoming" },
      { "<leader>gcc", "<cmd>GitConflictChooseOurs<cr>", desc = "Accept current" },
      { "<leader>gcb", "<cmd>GitConflictChooseBoth<cr>", desc = "Accept both" },
      { "<leader>gcd", "<cmd>GitConflictChooseNone<cr>", desc = "Discard both" },
      { "<leader>gcn", "<cmd>GitConflictNextConflict<cr>", desc = "go to nex" },
      { "<leader>gcp", "<cmd>GitConflictPrevConflict<cr>", desc = "go to prev" },
    },
  },
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
  {
    "tpope/vim-fugitive",
    opts = {},
    keys = {
      { "<leader>gcl", "<cmd>Git mergetool<cr>", desc = "Open conflic list" },
    },
  },
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
