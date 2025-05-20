---@type LazyPluginSpec[]
return {
  { -- Fuzzy Finder (files, lsp, etc)
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      "andrew-george/telescope-themes",
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },
    config = function()
      local builtin_schemes = require("telescope._extensions.themes").builtin_schemes
      require("telescope").setup({
        pickers = {
          find_files = {
            theme = "ivy",
            file_ignore_patterns = { "node_modules", ".git", ".venv" },
            hidden = true,
          },
          live_grep = {
            theme = "ivy",
            file_ignore_patterns = { "node_modules", ".git", ".venv" },
            additional_args = function(_)
              return { "--hidden" }
            end,
          },
          buffers = {
            theme = "ivy",
            mappings = {
              i = {
                ["<c-d>"] = "delete_buffer",
              },
            },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_ivy(),
          },
          themes = {
            -- (boolean) -> show/hide previewer window
            enable_previewer = true,
            -- (boolean) -> enable/disable live preview
            enable_live_preview = true,
            ignore = vim.list_extend(builtin_schemes, { "embark" }),
            light_themes = {
              ignore = true,
              keywords = { "light", "day", "frappe" },
            },
            dark_themes = {
              ignore = false,
              keywords = { "dark", "night", "black" },
            },
            persist = {
              enabled = true,
              path = vim.fn.stdpath("config") .. "/lua/colorscheme.lua",
            },
          },
        },
      })

      -- Enable Telescope extensions if they are installed
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")
      pcall(require("telescope").load_extension, "themes")

      -- See `:help telescope.builtin`
      local builtin = require("telescope.builtin")

      vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "Search Help" })
      vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "Search Keymaps" })
      vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "Search Files" })
      -- vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "Search Select Telescope" })
      vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "Search current Word" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "Search by Grep" })
      vim.keymap.set("n", "<leader>/", builtin.live_grep, { desc = "Search by Grep" })
      vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "Search Diagnostics" })
      vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "Search commands" })
      vim.keymap.set("n", "<leader>sC", builtin.command_history, { desc = "Search commands history" })
      vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = 'Search Recent Files ("." for repeat)' })
      vim.keymap.set(
        "n",
        "<leader>bl",
        '<CMD>lua require("telescope.builtin").buffers()<CR><ESC>',
        { desc = "Find existing buffers" }
      )

      -- Slightly advanced example of overriding default behavior and theme
      -- vim.keymap.set("n", "<leader>/", function()
      --   -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      --   builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
      --     winblend = 10,
      --     previewer = false,
      --   }))
      -- end, { desc = "/ Fuzzily search in current buffer" })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set("n", "<leader>s/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, { desc = "Search / in Open Files" })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set("n", "<leader>sn", function()
        builtin.find_files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "Search Neovim files" })
    end,
  },
}
