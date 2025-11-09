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
  -- {
  --   "StackInTheWild/headhunter.nvim",
  --   lazy = true,
  --   opts = {
  --     register_keymaps = false, -- Disable internal keymaps if using lazy.nvim keys
  --   },
  --   keys = {
  --     { "<leader>gq", "<cmd>HeadhunterQuickFix<cr>", desc = "Conflicts Quickfix list" },
  --     { "<leader>gn", "<cmd>HeadhunterNext<cr>", desc = "Go to next Conflict" },
  --     { "<leader>gp", "<cmd>HeadhunterPrevious<cr>", desc = "Go to previous Conflict" },
  --     { "<leader>gh", "<cmd>HeadhunterTakeHead<cr>", desc = "Take changes from HEAD" },
  --     { "<leader>go", "<cmd>HeadhunterTakeOrigin<cr>", desc = "Take changes from origin" },
  --     { "<leader>gb", "<cmd>HeadhunterTakeBoth<cr>", desc = "Take both changes" },
  --   },
  -- },
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
