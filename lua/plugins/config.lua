---@type LazyPluginSpec[]
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
  -- { "rose-pine/neovim" },
  -- { "catppuccin/nvim" },
  -- { "rebelot/kanagawa.nvim" },
  {
    "ElioStalteri/ofirkai.nvim",
    lazy = false,
    opts = { custom_theme = true },
    priority = 9000, -- Make sure to load this before all the other start plugins.
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
    "stevearc/dressing.nvim",
    opts = {},
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
      messages = { enabled = false },
      -- popupmenu = { enabled = false },
      notify = { enabled = false },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
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
      -- { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      -- { "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
      -- { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      -- { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
  },
  { -- Collection of various small independent plugins/modules
    "echasnovski/mini.nvim",
    keys = {
      {
        "<leader>gd",
        function()
          require("mini.diff").toggle_overlay(0)
        end,
        desc = "Diff",
      },
    },
    config = function()
      -- Better Around/Inside textobjects
      require("mini.ai").setup({ n_lines = 500 })

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      require("mini.surround").setup()

      -- hunk diff view
      require("mini.diff").setup()
    end,
  },
  -- Highlight todo, notes, etc in comments
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
    keys = {
      { "<leader>ct", "<cmd>TodoQuickFix<cr>", desc = "TODO QuickFix" },
    },
  },
  { -- smooth scrolling
    "declancm/cinnamon.nvim",
    version = "*", -- use latest release
    opts = {
      keymaps = {
        -- Enable the provided 'basic' keymaps
        -- basic = true,
        -- Enable the provided 'extra' keymaps
        -- extra = true,
      },
      options = { mode = "window", delay = 8 },
    },
    keys = {
      {
        "<C-U>",
        function()
          require("cinnamon").scroll("<C-U>zz")
        end,
        mode = { "n" },
        desc = "Scroll Up",
      },
      {
        "<C-D>",
        function()
          require("cinnamon").scroll("<C-D>zz")
        end,
        mode = { "n" },
        desc = "Scroll Down",
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = { enabled = true },
    lazy = false,
    keys = {
      { "<leader>tm", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown view" },
    },
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        offsets = {
          {
            filetype = "neo-tree",
            text = "Nvim Tree",
            separator = true,
            text_align = "left",
          },

          {
            filetype = "dbui",
            text = "DB-UI",
            separator = true,
            text_align = "left",
          },

          {
            filetype = "undotree",
            text = "Undo Tree",
            separator = true,
            text_align = "left",
          },
        },
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(count, level)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        indicator = {
          -- icon = "▎▎▎▎", -- this should be omitted if indicator style is not 'icon'
          -- style = "icon", --'icon' | 'underline' | 'none',
          style = "none", --'icon' | 'underline' | 'none',
        },
      },
    },
    keys = {
      { "<leader>bp", "<CMD>BufferLineTogglePin<CR>", desc = "toggle pin buffer" },
      { "<leader>bo", "<CMD>BufferLineCloseOthers<CR>", desc = "close other buffers" },
    },
  },
  {
    "leath-dub/snipe.nvim",
    keys = {
      {
        "<leader><leader>",
        function()
          require("snipe").open_buffer_menu()
        end,
        desc = "Open Snipe buffer menu",
      },
    },
    opts = {},
  },
  { "sigmasd/deno-nvim" },
  { -- markdown presentations
    "tjdevries/present.nvim",
    config = function()
      local present = require("present")
      present.setup({
        syntax = {},
        executors = {
          js = present.create_system_executor("node"),
        },
      })
    end,
    keys = {
      { "<leader>tp", "<cmd>PresentStart<cr>", desc = "Start markdown presentation" },
    },
  },
  {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      user_default_options = {
        names = false,
        tailwind = "lsp",
      },
    },
  },
  { -- color picker
    "nvzone/minty",
    dependencies = { { "nvzone/volt", lazy = true } },
    cmd = { "Shades", "Huefy" },
    keys = {
      -- { "<leader>xp", "<cmd>Shades<cr>", desc = "open color picker" },
      { "<leader>xp", "<cmd>Huefy<cr>", desc = "open color picker" },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    opts = {
      options = {
        -- theme = "seoul256",
        theme = "onedark",
        -- theme = "base16",
      },
    },
  },
  { "elliotxx/copypath.nvim", opts = {} },
  {
    "danitrap/cheatsh.nvim",
    opts = {}, -- Optional configuration, you can leave it empty
  },
  { -- add console log for selected variables
    "Goose97/timber.nvim",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("timber").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end,
  },
  {
    "chrisgrieser/nvim-justice",
    keys = {
      { "<leader>j", "<cmd>Justice<cr>", desc = "run just task" },
    },
  },
  {
    "OXY2DEV/foldtext.nvim",
    lazy = false,
    opts = {
      default = { {
        type = "raw",
        text = "Fold",
        hl = "Folded",
      } },
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    ---@module "ibl"
    ---@type ibl.config
    opts = {},
  },
  { "eandrju/cellular-automaton.nvim" },
}
