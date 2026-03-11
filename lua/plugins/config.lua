---@type LazyPluginSpec[]
return {
  {
    "kristijanhusak/vim-dadbod-ui",
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer", "DBUIClose" },
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
    },
  },
  {
    "XXiaoA/atone.nvim",
    cmd = "Atone",
    opts = {},
    keys = {
      { "<leader>tu", "<cmd>Atone toggle<cr>", desc = "Toggle undo tree" },
      { "<leader>tU", "<cmd>Atone close<cr>", desc = "Close undo tree" },
    },
  },
  {
    "sitiom/nvim-numbertoggle",
    event = "InsertEnter",
  },
  {
    "ElioStalteri/ofirkai.nvim",
    lazy = false,
    priority = 9000,
    opts = { custom_theme = true },
  },
  {
    "aileot/ex-colors.nvim",
    cmd = "ExColors",
    opts = {},
  },
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
    },
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
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "MunifTanjim/nui.nvim",
    commit = "de740991c12411b663994b2860f1a4fd0937c130",
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      messages = { enabled = false },
      notify = { enabled = false },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      dir = vim.fn.stdpath("state") .. "/sessions/",
      need = 1,
      branch = true,
    },
  },
  {
    "grapp-dev/nui-components.nvim",
    commit = "1654dd709f13874089eefc80d82e0eb667f7fdfb",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("search_panel").setup()
    end,
    keys = {
      {
        "<leader>sr",
        function()
          require("search_panel").open()
        end,
        desc = "Search and replace panel",
      },
    },
  },
  {
    "gbprod/yanky.nvim",
    opts = {
      highlight = { timer = 150 },
    },
    keys = {
      {
        "<leader>p",
        function()
          vim.cmd("YankyRingHistory")
        end,
        mode = { "n", "x" },
        desc = "Open Yank History",
      },
      { "y", "<Plug>(YankyYank)", mode = { "n" }, desc = "Yank Text" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n" }, desc = "Put Text After Cursor" },
      { "p", '"_dp', mode = { "v" }, desc = "Paste without loading copy register" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n" }, desc = "Put Text Before Cursor" },
      { "gp", "<Plug>(YankyGPutAfter)", mode = { "n" }, desc = "Put Text After Selection" },
      { "gP", "<Plug>(YankyGPutBefore)", mode = { "n" }, desc = "Put Text Before Selection" },
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
    },
  },
  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    config = function()
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.surround").setup()
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
    keys = {
      { "<leader>ct", "<cmd>TodoQuickFix<cr>", desc = "TODO QuickFix" },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "opencode_output" },
    cmd = { "RenderMarkdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
    opts = { enabled = true },
    keys = {
      { "<leader>tm", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown view" },
    },
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
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
          style = "none",
        },
      },
    },
    keys = {
      { "<leader>bp", "<CMD>BufferLineTogglePin<CR>", desc = "Toggle pin buffer" },
      { "<leader>bo", "<CMD>BufferLineCloseOthers<CR>", desc = "Close other buffers" },
    },
  },
  {
    "brenoprata10/nvim-highlight-colors",
    event = "BufReadPre",
    opts = {},
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "ElioStalteri/ofirkai.nvim",
    },
    config = function()
      require("lualine").setup({
        options = {
          theme = require("ofirkai.statuslines.lualine").theme,
        },
      })
    end,
  },
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "mhanberg/output-panel.nvim",
    version = "*",
    event = "VeryLazy",
    cmd = { "OutputPanel" },
    keys = {
      {
        "<leader>cl",
        vim.cmd.OutputPanel,
        mode = "n",
        desc = "Toggle LSP logs",
      },
    },
    config = function()
      require("output_panel").setup({
        max_buffer_size = 5000,
      })
    end,
  },
  { "saecki/live-rename.nvim", event = "LspAttach" },
  {
    "lesnik2u/herald.nvim",
    event = "VeryLazy",
    opts = {
      filename_mode = "relative",
      show_git_branch = true,
    },
    keys = {
      { "<leader>uf", "<cmd>Herald toggle<cr>", desc = "Toggle file path" },
    },
  },
}
