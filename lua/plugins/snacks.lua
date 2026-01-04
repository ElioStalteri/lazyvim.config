---@type LazyPluginSpec[]
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      lazygit = {
        configure = false,
        win = {
          style = "lazygit",
        },
      },
      bigfile = { enabled = true },
      bufDelete = { enabled = true },
      statuscolumn = { enabled = true },
      toggle = {
        enabled = true,
        map = vim.keymap.set, -- keymap.set function to use
        which_key = true, -- integrate with which-key to show enabled/disabled icons and colors
        notify = true, -- show a notification when toggling
        -- icons for enabled/disabled states
        icon = {
          enabled = " ",
          disabled = " ",
        },
        -- colors for enabled/disabled states
        color = {
          enabled = "green",
          disabled = "yellow",
        },
      },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      quickfile = { enabled = true },
      words = { enabled = true },
      styles = {
        notification = {
          wo = { wrap = true }, -- Wrap notifications
        },
      },
      indent = {
        enabled = false,
        -- indent = {
        --   char = "▏",
        --   only_current = true,
        --   -- only_scope = true,
        -- },
        -- scope = {
        --   char = "▏",
        -- },
        -- animate = {
        --   enabled = false,
        -- },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd -- Override print to use snacks for `:=` command

          -- Create some toggle mappings
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle
            .option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
            :map("<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.inlay_hints():map("<leader>uh")
          -- Snacks.toggle():map("<leader>ut")
        end,
      })
    end,
    keys = {
      {
        "<leader>nh",
        function()
          Snacks.notifier.show_history()
        end,
        desc = "Notification history",
      },
      {
        "<leader>gg",
        function()
          Snacks.lazygit.open()
        end,
        desc = "Lazygit",
      },
      {
        "<leader>nd",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Hide notifications",
      },
      -- {
      --   "<leader>bo",
      --   function()
      --     Snacks.bufdelete.other()
      --   end,
      --   desc = "Delete other buffers",
      -- },

      {
        "<leader>bd",
        function()
          Snacks.bufdelete()
        end,
        desc = "Delete buffer",
      },
    },
  },
  {
    "josephburgess/nvumi",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      virtual_text = "inline", -- "newline", -- or "inline"
      prefix = "= ", -- prefix shown before the virtual text output
      keys = {
        run = "<CR>", -- run calculations
        reset = "R", -- reset buffer
        yank = "<leader>y", -- yank last output
      },
    },
    keys = {
      {
        "<leader>xn",
        "<cmd>Nvumi<cr>",
        desc = "run Nvumi",
      },
    },
  },
}
