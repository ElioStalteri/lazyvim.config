---@type LazyPluginSpec[]
return {
  { -- https://github.com/mhanberg/output-panel.nvim
    "mhanberg/output-panel.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("output_panel").setup({
        max_buffer_size = 5000, -- default
      })
    end,
    cmd = { "OutputPanel" },
    keys = {
      {
        "<leader>cl",
        vim.cmd.OutputPanel,
        mode = "n",
        desc = "Toggle LSP logs",
      },
    },
  },
  { -- https://github.com/topaxi/pipeline.nvim
    "topaxi/pipeline.nvim",
    keys = {
      { "<leader>p", "<cmd>Pipeline Toggle<cr>", desc = "Toggle CI/CD Actions" },
    },
    -- optional, you can also install and use `yq` instead.
    build = "make",
    ---@type pipeline.Config
    opts = {},
  },
  { -- https://github.com/tlj/api-browser.nvim?tab=readme-ov-file
    "tlj/api-browser.nvim",
    dependencies = {
      "kkharji/sqlite.lua",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("api-browser").setup()
    end,
    keys = {
      { "<leader>xa", "<cmd>ApiBrowser open<cr>", desc = "Select an API." },
      -- { "<leader>sd", "<cmd>ApiBrowser select_local_server<cr>", desc = "Select environment." },
      -- { "<leader>sx", "<cmd>ApiBrowser select_remote_server<cr>", desc = "Select remote environment." },
      -- { "<leader>se", "<cmd>ApiBrowser endpoints<cr>", desc = "Open list of endpoints for current API." },
    },
  },
  { -- https://github.com/livinglogic-nl/relay.nvim
    "livinglogic-nl/relay.nvim",
    opts = {
      layouts = {
        { "pnpm.dev", "party" },
      },
      sources = {
        {
          name = "party",
          app = require("relay.apps.shell").create({ "cowsay", "its party time" }),
          icon = "🎉",
        },
        {
          name = "pnpm.dev",
          app = require("relay.apps.shell").create({ "pnpm", "run", "dev" }),
          icon = "🟢",
        },
      },
    },
    keys = {
      { "<leader>xt", "<cmd>lua require('relay').action()<cr>", desc = "select task" },
      { "<leader>tt", "<cmd>lua require('relay').toggle()<cr>", desc = "toggle task view" },
    },
  },
  { -- https://github.com/fredrikaverpil/pr.nvim
    "fredrikaverpil/pr.nvim",
    lazy = true,
    version = "*",
    ---@type PR.Config
    opts = {},
    keys = {
      {
        "<leader>gv",
        function()
          require("pr").view()
        end,
        desc = "View PR in browser",
      },
    },
    cmd = { "PRView" },
  },
  {
    "m4xshen/hardtime.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },
}
