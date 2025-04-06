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
    keys = {
      { "<leader>gc", "<cmd>GitConflictListQf<cr>", desc = "show conflicts" },
    },
  },
  {
    "fredeeb/tardis.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      keymap = {
        ["next"] = "<leader>h", -- next entry in log (older)
        ["prev"] = "<leader>l", -- previous entry in log (newer)
        ["quit"] = "q", -- quit all
        ["revision_message"] = "<leader>m", -- show revision message for current revision
        ["commit"] = "<leader>ga", -- replace contents of origin buffer with contents of tardis buffer
      },
      initial_revisions = 10, -- initial revisions to create buffers for
      max_revisions = 256,
    },
    keys = {
      { "<leader>gt", "<cmd>Tardis<cr>", desc = "Tardis load and cicle trough file revisions" },
    },
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
