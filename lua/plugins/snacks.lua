---@type LazyPluginSpec[]
return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    event = "VeryLazy",
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
        map = vim.keymap.set,
        which_key = true,
        notify = true,
        icon = {
          enabled = " ",
          disabled = " ",
        },
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
          wo = { wrap = true },
        },
      },
      indent = {
        enabled = false,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          _G.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _G.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _G.dd

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
      {
        "<leader>bd",
        function()
          Snacks.bufdelete()
        end,
        desc = "Delete buffer",
      },
    },
  },
}
