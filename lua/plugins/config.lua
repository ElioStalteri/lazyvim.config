local function removebyKey(tab, val)
  for i, v in ipairs(tab) do
    if v.id == val then
      tab[i] = nil
    end
  end
end

return {
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      -- { "kristijanhusak/vim-dadbod-completion", lazy = true, ft = { "sql", "mysql", "plsql" } },
    },
  },
  { "mbbill/undotree" },
  -- {
  --   "neovim/nvim-lspconfig",
  --   opts = {
  --     inlay_hints = { enabled = false },
  --   },
  --   init = function()
  --     local keys = require("lazyvim.plugins.lsp.keymaps").get()
  --     removebyKey(keys, "<Tab>")
  --     removebyKey(keys, "<S-Tab>")
  --
  --     -- change a keymap
  --     keys[#keys + 1] = { mode = { "n" }, "gr", "<cmd>Trouble lsp_references<cr>", desc = "References" }
  --   end,
  -- },
  -- { "nvim-treesitter/playground" },
  -- { "ofirgall/ofirkai.nvim", lazy = false },
  { "rose-pine/neovim", lazy = false, name = "rose-pine" },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    "ElioStalteri/ofirkai.nvim",
    lazy = false,
    opts = { custom_theme = true },
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.cmd.colorscheme("ofirkai-custom")
    end,
  },
  -- {
  --   "LazyVim/LazyVim",
  --   opts = {
  --     colorscheme = "ofirkai-custom",
  --     -- colorscheme = "catppuccin",
  --   },
  -- },
  -- {
  --   "L3MON4D3/LuaSnip",
  --   keys = function()
  --     return {}
  --   end,
  -- },
  -- {
  --   "nvim-treesitter/nvim-treesitter",
  --   opts = function(_, opts)
  --     vim.list_extend(opts.ensure_installed, {
  --       "svelte",
  --       "sql",
  --       "http",
  --       "json",
  --     })
  --   end,
  -- },
  -- {
  --   "folke/zen-mode.nvim",
  --   opts = {
  --     window = {
  --       width = 140,
  --     },
  --   },
  -- },
  -- {
  --   "stevearc/overseer.nvim",
  --   opts = {},
  -- },
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
  -- { "sindrets/diffview.nvim", opts = {} },
  -- {
  --   "folke/which-key.nvim",
  --   opts = {
  --     spec = {
  --       ["<leader>gd"] = { name = "+Diffview" },
  --       ["<leader>ct"] = { name = "+TaskRunner" },
  --     },
  --   },
  -- },
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
  -- { "IndianBoy42/tree-sitter-just" },
  {
    "echasnovski/mini.surround",
    recommended = true,
    keys = function(_, keys)
      -- Populate the keys based on the user's options
      local mappings = {
        { "gsa", desc = "Add Surrounding", mode = { "n", "v" } },
        { "gsd", desc = "Delete Surrounding" },
        { "gsr", desc = "Replace Surrounding" },
      }
      mappings = vim.tbl_filter(function(m)
        return m[1] and #m[1] > 0
      end, mappings)
      return vim.list_extend(mappings, keys)
    end,
  },
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
}
