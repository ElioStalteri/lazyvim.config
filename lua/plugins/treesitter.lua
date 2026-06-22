---@type LazyPluginSpec[]
return {
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
    lazy = false,
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = function()
      local languages = {
        "bash",
        "c",
        "diff",
        "dockerfile",
        "git_config",
        "go",
        "html",
        "http",
        "javascript",
        "json",
        "just",
        "lua",
        "luadoc",
        "markdown",
        "markdown_inline",
        "query",
        "sql",
        "svelte",
        "tmux",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      }

      return {
        languages = languages,
        filetypes = {
          "c",
          "diff",
          "dockerfile",
          "gitconfig",
          "go",
          "html",
          "http",
          "javascript",
          "json",
          "jsonc",
          "just",
          "lua",
          "luadoc",
          "markdown",
          "query",
          "sh",
          "sql",
          "svelte",
          "tmux",
          "typescript",
          "vim",
          "vimdoc",
          "yaml",
        },
      }
    end,
    config = function(_, opts)
      vim.env.PATH = "/opt/homebrew/bin:" .. vim.env.PATH

      require("nvim-treesitter").setup()
      vim.treesitter.language.register("json", "jsonc")

      local installed = require("nvim-treesitter").get_installed()
      local missing = vim.tbl_filter(function(language)
        return not vim.tbl_contains(installed, language)
      end, opts.languages)

      if #missing > 0 then
        require("nvim-treesitter").install(missing)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("config-treesitter", { clear = true }),
        pattern = opts.filetypes,
        callback = function()
          vim.treesitter.start()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      max_lines = 3,
    },
  },
}
