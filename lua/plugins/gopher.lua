---@type LazyPluginSpec[]
return {
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    -- branch = "develop", -- if you want develop branch
    -- keep in mind, it might break everything
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- "mfussenegger/nvim-dap", -- (optional) only if you use `gopher.dap`
    },
    -- (optional) will update plugin's deps on every update
    build = function()
      vim.cmd.GoInstallDeps()
    end,
    cmd = {
      "GoInstallDeps",
      "GoTagAdd",
      "GoTagRm",
      "GoTestAdd",
      "GoTestsAll",
      "GoTestsExp",
      "GoGet",
      "GoMod",
      "GoWork",
      "GoImpl",
      "GoCmt",
      "GoIfErr",
    },
    ---@type gopher.Config
    opts = {
      commands = {
        go = "go",
        gomodifytags = "gomodifytags",
        gotests = "gotests",
        impl = "impl",
        iferr = "iferr",
        dlv = "dlv",
      },
      gotests = {
        -- gotests doesn't have template named "default" so this plugin uses "default" to set the default template
        template = "default",
        -- path to a directory containing custom test code templates
        template_dir = nil,
        -- switch table tests from using slice to map (with test name for the key)
        -- works only with gotests installed from develop branch
        named = false,
      },
      gotag = {
        transform = "snakecase",
      },
    },
    ---@type LazyKeysSpec[]
    keys = {
      -- { "n", ft = "go", "<leader>xge", "<cmd>GoIfErr<cr>", desc = "generate go if err" },
    },
  },
}
