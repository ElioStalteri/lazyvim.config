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
  {
    "neovim/nvim-lspconfig",
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      removebyKey(keys, "<Tab>")
      removebyKey(keys, "<S-Tab>")

      -- change a keymap
      keys[#keys + 1] = { mode = { "n" }, "gr", "<cmd>Trouble lsp_references<cr>", desc = "References" }
    end,
  },
  -- { "nvim-treesitter/playground" },
  -- { "ofirgall/ofirkai.nvim", lazy = false },
  { "ElioStalteri/ofirkai.nvim", lazy = false, opts = { custom_theme = true } },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "ofirkai-custom",
    },
  },
  {
    "L3MON4D3/LuaSnip",
    keys = function()
      return {}
    end,
  },
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
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        width = 140,
      },
    },
  },
  {
    "stevearc/overseer.nvim",
    opts = {},
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
      { "<leader>t", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
    },
  },
  { "sindrets/diffview.nvim", opts = {} },
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>gd"] = { name = "+Diffview" },
        ["<leader>ct"] = { name = "+TaskRunner" },
      },
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
  { "tpope/vim-fugitive" },
}
