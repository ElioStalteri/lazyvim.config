---@type LazyPluginSpec[]
return {
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
  {
    "athar-qadri/weather.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for HTTP requests
      "rcarriga/nvim-notify", -- Optional, for notifications
    },
    config = function()
      local weather = require("weather")
      weather:setup({
        settings = {
          update_interval = 60 * 10 * 1000, -- 10 minutes
          minimum_magnitude = 5,
          location = { lat = 34.0787, lon = 74.7659 },
          temperature_unit = "celsius",
        },
      })
      require("weather.notify").start() -- Start notifications
    end,
  },
  {
    "KoolieAid/pastevim.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("pastevim").setup({
        api_key = "YOUR KEY HERE",
        public = 1,
        include_filename = true,
        code_only = false,
        expiry = "N",
      })
    end,
  },

  ------------------------------------------------------------------------------

  {
    "axkirillov/unified.nvim",
    opts = {
      -- your configuration comes here
    },
  },

  { -- TODO: try this terminal it looks nicer
    "waiting-for-dev/ergoterm.nvim",
    config = function()
      require("ergoterm").setup()
    end,
  },

  {
    "WilliamHsieh/overlook.nvim",
    opts = {},

    -- Optional: set up common keybindings
    keys = {
      {
        "<leader>pd",
        function()
          require("overlook.api").peek_definition()
        end,
        desc = "Overlook: Peek definition",
      },
      {
        "<leader>pc",
        function()
          require("overlook.api").close_all()
        end,
        desc = "Overlook: Close all popup",
      },
      {
        "<leader>pu",
        function()
          require("overlook.api").restore_popup()
        end,
        desc = "Overlook: Restore popup",
      },
    },
  },
}
