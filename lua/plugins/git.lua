return {
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
    "sindrets/diffview.nvim",
    opts = {
      view = {
        merge_tool = {
          layout = "diff1_plain",
          disable_diagnostics = true, -- Temporarily disable diagnostics for diff buffers while in the view.
          winbar_info = true, -- See |diffview-config-view.x.winbar_info|
        },
      },
      keymaps = {
        disable_defaults = true, -- Disable the default keymaps
      },
    },
    keys = {
      { "<leader>go", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<leader>ge", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
      { "<leader>gf", "<cmd>DiffviewToggleFiles<cr>", desc = "Diffview files toggle" },
      -- require("diffview.actions")
      {
        "<leader>gco",
        function()
          require("diffview.actions").conflict_choose("ours")
        end,
        desc = "Choose the OURS version of a conflict",
      },
      {
        "<leader>gct",
        function()
          require("diffview.actions").conflict_choose("theirs")
        end,
        desc = "Choose the THEIRS version of a conflict",
      },
      {
        "<leader>gcb",
        function()
          require("diffview.actions").conflict_choose("base")
        end,
        desc = "Choose the BASE version of a conflict",
      },
      {
        "<leader>gca",
        function()
          require("diffview.actions").conflict_choose("all")
        end,
        desc = "Choose all the versions of a conflict",
      },
      {
        "<leader>gcx",
        function()
          require("diffview.actions").conflict_choose("none")
        end,
        desc = "Delete the conflict region",
      },
      {
        "<leader>gcO",
        function()
          require("diffview.actions").conflict_choose_all("ours")
        end,
        desc = "Choose the OURS version of a conflict for the whole file",
      },
      {
        "<leader>gcT",
        function()
          require("diffview.actions").conflict_choose_all("theirs")
        end,
        desc = "Choose the THEIRS version of a conflict for the whole file",
      },
      {
        "<leader>gcB",
        function()
          require("diffview.actions").conflict_choose_all("base")
        end,
        desc = "Choose the BASE version of a conflict for the whole file",
      },
      {
        "<leader>gcA",
        function()
          require("diffview.actions").conflict_choose_all("all")
        end,
        desc = "Choose all the versions of a conflict for the whole file",
      },
      {
        "<leader>gcX",
        function()
          require("diffview.actions").conflict_choose_all("none")
        end,
        desc = "Delete the conflict region for the whole file",
      },
    },
  },
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
