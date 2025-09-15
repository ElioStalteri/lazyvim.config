---@type LazyPluginSpec[]
return {
  {
    "supermaven-inc/supermaven-nvim",
    lazy = false,
    opts = {
      keymaps = {
        accept_suggestion = "<Tab>",
        clear_suggestion = "<C-]>",
        -- accept_word = "<C-j>",
      },
    },
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
    opts = {
      provider = "gemini",
      providers = {
        gemini = {
          -- @see https://ai.google.dev/gemini-api/docs/models/gemini
          model = "gemini-2.5-flash-lite", -- your desired model (or use gpt-4o, etc.)
          timeout = 30000, -- timeout in milliseconds
          temperature = 0, -- adjust if needed
          max_tokens = 4096,
          extra_request_body = {
            include_thoughts = false,
            thinking_budget = 0,
          },
        },
      },
      behaviour = {
        auto_suggestions = false, -- Experimental stage
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
      },
    },
    build = "make", -- if you want to build from source then do make BUILD_FROM_SOURCE=true
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
    keys = {
      {
        "<leader>aC",
        function()
          local format_lines = {
            "feat: ✨ `:sparkles:`: Introduce new features or functionality.",
            "fix: 🐛 `:bug:`: Fix a bug.",
            "perf: ⚡️ `:zap:`: Improve performance.",
            "refactor: 🔥 `:fire:`: Remove code or files.",
            "docs: 📝 `:memo:`: Add or update documentation.",
            "deploy: 🚀 `:rocket:`: Deploy builds.",
            "init: 🎉 `:tada:`: Initial commit.",
            "style: 🎨 `:art:`: Improve structure/format of the code.",
            "ci: 🚨 `:rotating_light:`: Fix compiler/linter warnings.",
            "test: ✅ `:white_check_mark:`: Add, update, or pass tests.",
            "deps: ⬆️ `:arrow_up:`: Upgrade dependencies.",
            "deps: ⬇️ `:arrow_down:`: Downgrade dependencies.",
            "deps: ➕ `:heavy_plus_sign:`: Add a dependency.",
            "deps: ➖ `:heavy_minus_sign:`: Remove a dependency.",
            "refactor: 🔨 `:hammer:`: Minor changes, such as refactoring or code style.",
            "docker: 🐳 `:whale:`: Docker related changes.",
            "config: ⚙️ `:gear:`: Configuration changes.",
            "wip: 🚧 `:construction:`: Work in progress.",
            "ci: 💚 `:green_heart:`: Fix CI build.",
            "security: 🔒 `:lock:`: Fix security issues.",
            "Analyze this git diff and generate single line commit messages.",
            "USE EXACTLY THIS FORMAT WITHOUT ADDITIONAL EXPLANATION:",
            "<icon> <prefix>: <commit message>",
            vim.fn.system("git diff --no-ext-diff --staged"),
          }

          local prompt = table.concat(format_lines, "\n")

          require("avante.api").ask({ question = prompt, without_selection = true, new_chat = true })
        end,
        desc = "generate commit messages",
      },
    },
  },
}
