--stylua ignore
local sublimeColors = {
  green = "#a6e228",
  blue = "#56d8ef",
  white = "#f8f8f2",
  red = "#c92468",
  yallow = "#e7db74",
  purple = "#7b76ff",
  orange = "#e76d22",
  comment = "#74705d",
  background = "#282923",
  background1 = "#232418",
  background2 = "#181913",
}

return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      -- { "kristijanhusak/vim-dadbod-completion", lazy = true, ft = { "sql", "mysql", "plsql" } },
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      color_overrides = {
        mocha = {
          rosewater = "#f5e0dc",
          flamingo = "#f2cdcd",
          pink = sublimeColors.orange, -- "#f5c2e7", -- Escape Sequences
          mauve = sublimeColors.red, -- "#cba6f7", Keyword
          red = sublimeColors.blue, -- "#f38ba8", -- Builtins
          maroon = sublimeColors.orange, -- "#eba0ac", Parameters
          -- peach = sublimeColors.purple, -- "#fab387", Constants, Numbers -- it deosn't work :'(
          peach = sublimeColors.white, -- Constants, Numbers
          yellow = sublimeColors.blue, -- "#f9e2af", Classes, Metadata
          green = sublimeColors.yallow, -- "#a6e3a1", Strings
          teal = sublimeColors.green, -- "#94e2d5",
          sky = sublimeColors.red, -- "#89dceb", Operators
          sapphire = sublimeColors.red, -- "#74c7ec",
          blue = sublimeColors.green, -- #89b4fa -- Methods, Functions
          lavender = sublimeColors.white, -- "#b4befe",
          text = sublimeColors.white, -- "#cdd6f4",
          subtext1 = sublimeColors.comment, -- "#bac2de",
          subtext0 = "#a6adc8",
          overlay2 = sublimeColors.white, -- "#9399b2", -- Braces, Delimiters
          overlay1 = "#7f849c",
          overlay0 = sublimeColors.comment, -- "#6c7086", -- Comments
          surface2 = "#585b70",
          surface1 = "#45475a",
          surface0 = "#313244",
          base = sublimeColors.background, -- "#1e1e2e",
          mantle = sublimeColors.background1, -- "#181825",
          crust = sublimeColors.background2, -- "#11111b",
        },
      },
      custom_highlights = function(colors)
        return {
          -- Comment = { fg = colors.flamingo },
          -- TabLineSel = { bg = colors.pink },
          -- CmpBorder = { fg = colors.surface2 },
          -- Pmenu = { bg = colors.none },
          -- Statement = { fg = colors.sky },
          -- Conditional = { fg = colors.sky },
          -- Include = { fg = colors.sky },

          Statement = { fg = colors.yellow },
          -- Conditional = { fg = colors.yellow },
          Repeat = { fg = colors.yellow },
          Keyword = { fg = colors.yellow },
          ["@keyword.coroutine"] = { fg = colors.sky },
          ["@type"] = { fg = colors.subtext0 },
          Type = { fg = colors.subtext0 },
          -- ["@function.builtin"] = { fg = colors.yallow }, -- it doesn't work :'(
          ["@lsp.typemod.method"] = { fg = colors.yallow },
          Title = { fg = colors.text },
          ["@text.title"] = { fg = colors.text },
          Structure = { fg = colors.blue },
          Character = { fg = colors.text },
          htmlH1 = { fg = colors.text },
          htmlH2 = { fg = colors.text },
          ["@boolean"] = { fg = colors.peach },
          DashboardDesc = { fg = colors.text },
          -- Exception = { fg = colors.yellow },
          -- Include = { fg = colors.yellow },
          -- Macro = { fg = colors.yellow },
        }
      end,
    },
  },
  { "nvim-treesitter/playground" },
  {
    "loctvl842/monokai-pro.nvim",
    opts = {
      filter = "spectrum", -- classic | octagon | pro | machine | ristretto | spectrum
      -- transparent_background = true,
    },
  },
  { "ellisonleao/gruvbox.nvim" },
  { "bluz71/vim-nightfly-colors", name = "nightfly", lazy = false, priority = 1000 },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-emoji" },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
      local luasnip = require("luasnip")
      local cmp = require("cmp")
      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "svelte",
        "sql",
      })
    end,
  },
  { "mg979/vim-visual-multi" },
  {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("neorg").setup({
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          -- ["core.concealer"] = {}, -- Adds pretty icons to your documents
          -- ["core.presenter"] = {
          --   config = {
          --     zen_mode = "zen-mode",
          --   },
          -- }, --  this plugin is due to change so I'm gonna hold on untile there is a good version
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                notes = "~/notes",
              },
            },
          },
        },
      })
    end,
  },
  { "folke/zen-mode.nvim" },
}
