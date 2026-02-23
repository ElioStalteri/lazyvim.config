---@type LazyPluginSpec[]
return {
  {
    "saghen/blink.indent",
    --- @module 'blink.indent'
    --- @type blink.indent.Config
    opts = {
      scope = {
        highlights = { "BlinkIndentScope" },
      },
    },
  },
  {
    "saghen/blink.cmp",
    -- optional: provides snippets for the snippet source
    dependencies = {
      -- "rafamadriz/friendly-snippets",
      { "xzbdmw/colorful-menu.nvim", opts = {} },
    },

    -- use a release tag to download pre-built binaries
    version = "*",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      signature = {
        enabled = true,
      },
      cmdline = {
        completion = { menu = { auto_show = true } },
      },
      keymap = {
        preset = "default",
        -- ["<CR>"] = { "accept", "fallback" },
        -- ["<CR>"] = {
        --   function(cmp)
        --     cmp.accept()
        --   end,
        -- },
      },

      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },

      sources = {
        default = {
          "lsp",
          "path",
          -- "snippets",
          "buffer",
        },
        providers = {
          -- snippets = {
          --   opts = {
          --     search_paths = { vim.fn.stdpath("config") .. "/snippets" },
          --   },
          -- },
          markdown = {
            name = "RenderMarkdown",
            module = "render-markdown.integ.blink",
            fallbacks = { "lsp" },
          },
        },
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
        },
        menu = {
          auto_show = true,
          draw = {
            -- We don't need label_description now because label and label_description are already
            -- combined together in label by colorful-menu.nvim.
            -- columns = { { "kind_icon" }, { "label", gap = 1 } },
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" }, { "source_name" } },
            components = {
              label = {
                text = function(ctx)
                  return require("colorful-menu").blink_components_text(ctx)
                end,
                highlight = function(ctx)
                  return require("colorful-menu").blink_components_highlight(ctx)
                end,
              },
            },
          },
        },
      },
    },
    opts_extend = { "sources.default" },
  },
}
