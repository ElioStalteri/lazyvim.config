return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      -- { "kristijanhusak/vim-dadbod-completion", lazy = true, ft = { "sql", "mysql", "plsql" } },
    },
  },
  { "mbbill/undotree" },
  -- { "nvim-treesitter/playground" },
  -- { "ofirgall/ofirkai.nvim", lazy = false },
  -- { "rose-pine/neovim", lazy = false, name = "rose-pine" },
  -- { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    "ElioStalteri/ofirkai.nvim",
    lazy = false,
    opts = { custom_theme = true },
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.cmd.colorscheme("ofirkai-custom")
    end,
  },
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        width = 140,
      },
    },
    keys = {
      { "<leader>tz", "<cmd>ZenMode<cr>", desc = "Toggle zen mode" },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    lazy = false,
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-/>]],
        shade_terminals = false,
      })
    end,
    keys = {
      { [[<C-/>]] },
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    },
  },
  {
    "stevearc/oil.nvim",
    opts = {
      skip_confirm_for_simple_edits = true,
      view_options = {
        show_hidden = true,
        natural_order = true,
        is_always_hidden = function(name)
          return name == ".."
        end,
      },
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  -- { "tpope/vim-fugitive" },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons", "folke/edgy.nvim" },
    opts = {},
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    opts = {
      dir = vim.fn.stdpath("state") .. "/sessions/", -- directory where session files are saved
      -- minimum number of file buffers that need to be open to save
      -- Set to 0 to always save
      need = 1,
      branch = true, -- use git branch to save session
    },
  },
  {
    "MagicDuck/grug-far.nvim",
    config = function()
      require("grug-far").setup({
        -- options, see Configuration section below
        -- there are no required options atm
        -- engine = 'ripgrep' is default, but 'astgrep' can be specified
      })
    end,
    keys = {
      { "<leader>sr", "<cmd>GrugFar<cr>", desc = "Open find and replace" },
    },
  },
  {
    "gbprod/yanky.nvim",
    recommended = true,
    desc = "Better Yank/Paste",
    -- event = "LazyFile",
    opts = {
      highlight = { timer = 150 },
    },
    keys = {
      {
        "<leader>p",
        function()
          require("telescope").extensions.yank_history.yank_history({})
        end,
        mode = { "n", "x" },
        desc = "Open Yank History",
      },
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Cursor" },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put Text After Selection" },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Selection" },
      { "[y", "<Plug>(YankyCycleForward)", desc = "Cycle Forward Through Yank History" },
      { "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle Backward Through Yank History" },
    },
  },
  {
    "saecki/live-rename.nvim",
    opts = {},
    keys = {
      {
        "<leader>cr",
        function()
          require("live-rename").rename({ insert = true })
        end,
        mode = { "n" },
        desc = "LSP Rename",
      },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {
      modes = {
        lsp = {
          win = { position = "right" },
        },
      },
    },
    keys = {
      { "<leader>cx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>cX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
      -- {
      --   "[q",
      --   function()
      --     if require("trouble").is_open() then
      --       require("trouble").prev({ skip_groups = true, jump = true })
      --     else
      --       local ok, err = pcall(vim.cmd.cprev)
      --       if not ok then
      --         vim.notify(err, vim.log.levels.ERROR)
      --       end
      --     end
      --   end,
      --   desc = "Previous Trouble/Quickfix Item",
      -- },
      -- {
      --   "]q",
      --   function()
      --     if require("trouble").is_open() then
      --       require("trouble").next({ skip_groups = true, jump = true })
      --     else
      --       local ok, err = pcall(vim.cmd.cnext)
      --       if not ok then
      --         vim.notify(err, vim.log.levels.ERROR)
      --       end
      --     end
      --   end,
      --   desc = "Next Trouble/Quickfix Item",
      -- },
    },
  },
}
