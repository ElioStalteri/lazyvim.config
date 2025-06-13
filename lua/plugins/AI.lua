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
          model = "gemini-2.5-flash-preview-05-20", -- your desired model (or use gpt-4o, etc.)
          timeout = 30000, -- timeout in milliseconds
          temperature = 0, -- adjust if needed
          max_tokens = 4096,
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
      -- {
      --   -- support for image pasting
      --   "HakonHarnes/img-clip.nvim",
      --   event = "VeryLazy",
      --   opts = {
      --     -- recommended settings
      --     default = {
      --       embed_image_as_base64 = false,
      --       prompt_for_file_name = false,
      --       drag_and_drop = {
      --         insert_mode = true,
      --       },
      --       -- required for Windows users
      --       use_absolute_path = true,
      --     },
      --   },
      -- },
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
--   {
--     "olimorris/codecompanion.nvim",
--     dependencies = {
--       "nvim-lua/plenary.nvim",
--       "nvim-treesitter/nvim-treesitter",
--     },
--     config = function()
--       require("codecompanion").setup({
--         display = { chat = { window = { layout = "float", height = 0.9, width = 0.9 } } },
--         strategies = {
--           chat = {
--             adapter = "gemini",
--           },
--           inline = {
--             adapter = "gemini",
--           },
--           workflow = {
--             adapter = "gemini",
--           },
--         },
--         adapters = {
--           gemini = function()
--             return require("codecompanion.adapters").extend("gemini", {
--               env = {
--                 api_key = os.getenv("AI_API_KEY"),
--                 model = "gemini-2.5-flash-preview-05-20", --"gemini-2.0-flash", -- "gemini-2.5-pro-exp-03-25"
--               },
--             })
--           end,
--         },
--         prompt_library = {
--           ["Implement the file"] = {
--             strategy = "chat",
--             description = "implement the file",
--             opts = {
--               index = 10,
--               is_default = true,
--               is_slash_cmd = true,
--               short_name = "implement",
--               auto_submit = true,
--             },
--             prompts = {
--               {
--                 role = "user",
--                 opts = {
--                   contains_code = true,
--                 },
--                 content = function()
--                   return [[ ### Steps to Follow
--
-- You are required to write code following the instructions provided below. Follow these steps exactly:
--
-- 0. wait for the files to be given to you, that you will use a reference to implement the file
-- 1. Update the code in #buffer{watch} using the @editor tool
-- 2. implement the code into the buffer making sure to follow the information contained in the files provided
--                   ]]
--                 end,
--               },
--             },
--           },
--           ["Generate a Commit Message"] = {
--             strategy = "chat",
--             description = "auto-generate a commit message",
--             opts = {
--               index = 10,
--               is_default = true,
--               is_slash_cmd = true,
--               short_name = "commit",
--               auto_submit = true,
--             },
--             prompts = {
--               {
--                 role = "user",
--                 content = function()
--                   local git_conventions = {
--                     { icon = "🎨", prefix = "style", type = "Improve structure / format of the code." },
--                     { icon = "⚡️", prefix = "enhance", type = "Improve performance." },
--                     { icon = "🔥", prefix = "chore", type = "Remove code or files." },
--                     { icon = "🐛", prefix = "fix", type = "Fix a bug." },
--                     { icon = "🚑️", prefix = "fix", type = "Critical hotfix." },
--                     { icon = "✨", prefix = "feat", type = "Introduce new features." },
--                     { icon = "📝", prefix = "docs", type = "Add or update documentation." },
--                     { icon = "🚀", prefix = "chore", type = "Deploy stuff." },
--                     { icon = "💄", prefix = "style", type = "Add or update the UI and style files." },
--                     { icon = "🎉", prefix = "feat", type = "Begin a project." },
--                     { icon = "✅", prefix = "test", type = "Add, update, or pass tests." },
--                     { icon = "🔒️", prefix = "fix", type = "Fix security or privacy issues." },
--                     { icon = "🔐", prefix = "chore", type = "Add or update secrets." },
--                     { icon = "🔖", prefix = "chore", type = "Release / Version tags." },
--                     { icon = "🚨", prefix = "fix", type = "Fix compiler / linter warnings." },
--                     { icon = "🚧", prefix = "chore", type = "Work in progress." },
--                     { icon = "💚", prefix = "fix", type = "Fix CI Build." },
--                     { icon = "⬇️", prefix = "chore", type = "Downgrade dependencies." },
--                     { icon = "⬆️", prefix = "chore", type = "Upgrade dependencies." },
--                     { icon = "📌", prefix = "chore", type = "Pin dependencies to specific versions." },
--                     { icon = "👷", prefix = "chore", type = "Add or update CI build system." },
--                     { icon = "📈", prefix = "enhance", type = "Add or update analytics or track code." },
--                     { icon = "♻️", prefix = "refactor", type = "Refactor code." },
--                     { icon = "➕", prefix = "chore", type = "Add a dependency." },
--                     { icon = "➖", prefix = "chore", type = "Remove a dependency." },
--                     { icon = "🔧", prefix = "chore", type = "Add or update configuration files." },
--                     { icon = "🔨", prefix = "chore", type = "Add or update development scripts." },
--                     { icon = "🌐", prefix = "feat", type = "Internationalization and localization." },
--                     { icon = "✏️", prefix = "fix", type = "Fix typos." },
--                     { icon = "💩", prefix = "chore", type = "Write bad code that needs to be improved." },
--                     { icon = "⏪️", prefix = "chore", type = "Revert changes." },
--                     { icon = "🔀", prefix = "chore", type = "Merge branches." },
--                     { icon = "📦️", prefix = "chore", type = "Add or update compiled files or packages." },
--                     { icon = "👽️", prefix = "refactor", type = "Update code due to external API changes." },
--                     {
--                       icon = "🚚",
--                       prefix = "refactor",
--                       type = "Move or rename resources (e.g.: files, paths, routes).",
--                     },
--                     { icon = "📄", prefix = "docs", type = "Add or update license." },
--                     { icon = "💥", prefix = "feat", type = "Introduce breaking changes." },
--                     { icon = "🍱", prefix = "style", type = "Add or update assets." },
--                     { icon = "♿️", prefix = "enhance", type = "Improve accessibility." },
--                     { icon = "💡", prefix = "docs", type = "Add or update comments in source code." },
--                     { icon = "🍻", prefix = "chore", type = "Write code drunkenly." },
--                     { icon = "💬", prefix = "docs", type = "Add or update text and literals." },
--                     { icon = "🗃️", prefix = "chore", type = "Perform database related changes." },
--                     { icon = "🔊", prefix = "docs", type = "Add or update logs." },
--                     { icon = "🔇", prefix = "chore", type = "Remove logs." },
--                     { icon = "👥", prefix = "chore", type = "Add or update contributor(s)." },
--                     { icon = "🚸", prefix = "enhance", type = "Improve user experience / usability." },
--                     { icon = "🏗️", prefix = "chore", type = "Make architectural changes." },
--                     { icon = "📱", prefix = "style", type = "Work on responsive design." },
--                     { icon = "🤡", prefix = "test", type = "Mock things." },
--                     { icon = "🥚", prefix = "feat", type = "Add or update an easter egg." },
--                     { icon = "🙈", prefix = "chore", type = "Add or update a .gitignore file." },
--                     { icon = "📸", prefix = "test", type = "Add or update snapshots." },
--                     { icon = "⚗️", prefix = "chore", type = "Perform experiments." },
--                     { icon = "🔍️", prefix = "enhance", type = "Improve SEO." },
--                     { icon = "🏷️", prefix = "docs", type = "Add or update types." },
--                     { icon = "🌱", prefix = "chore", type = "Add or update seed files." },
--                     { icon = "🚩", prefix = "feat", type = "Add, update, or remove feature flags." },
--                     { icon = "🥅", prefix = "fix", type = "Catch errors." },
--                     { icon = "💫", prefix = "enhance", type = "Add or update animations and transitions." },
--                     { icon = "🗑️", prefix = "chore", type = "Deprecate code that needs to be cleaned up." },
--                     {
--                       icon = "🛂",
--                       prefix = "chore",
--                       type = "Work on code related to authorization, roles and permissions.",
--                     },
--                     { icon = "🩹", prefix = "fix", type = "Simple fix for a non-critical issue." },
--                     { icon = "🧐", prefix = "chore", type = "Data exploration/inspection." },
--                     { icon = "⚰️", prefix = "chore", type = "Remove dead code." },
--                     { icon = "🧪", prefix = "test", type = "Add a failing test." },
--                     { icon = "👔", prefix = "feat", type = "Add or update business logic." },
--                     { icon = "🩺", prefix = "chore", type = "Add or update healthcheck." },
--                     { icon = "🧱", prefix = "chore", type = "Infrastructure related changes." },
--                     { icon = "💻", prefix = "enhance", type = "Improve developer experience." },
--                     { icon = "💸", prefix = "chore", type = "Add sponsorships or money related infrastructure." },
--                     {
--                       icon = "🧵",
--                       prefix = "feat",
--                       type = "Add or update code related to multithreading or concurrency.",
--                     },
--                     { icon = "🦺", prefix = "feat", type = "Add or update code related to validation." },
--                     { icon = "✈️", prefix = "enhance", type = "Improve offline support." },
--                   }
--                   local format_lines = {}
--                   for _, convention in pairs(git_conventions) do
--                     table.insert(
--                       format_lines,
--                       string.format("%s %s: %s", convention.icon, convention.prefix, convention.type)
--                     )
--                   end
--
--                   local prompt = string.format(
--                     "Analyze this git diff and generate single line commit messages and a commit descrition in plain text.\n"
--                       .. "USE EXACTLY THIS FORMAT WITHOUT ADDITIONAL EXPLANATION:\n\n"
--                       .. "<icon> <prefix>: <commit message>\n\n"
--                       .. "Options:\n%s\n\nGit diff:\n\n```diff\n\n%s\n\n```",
--                     table.concat(format_lines, "\n"),
--                     vim.fn.system("git diff --no-ext-diff --staged")
--                   )
--                   return prompt
--                 end,
--                 opts = {
--                   contains_code = true,
--                 },
--               },
--             },
--           },
--         },
--       })
--     end,
--     keys = {
--       { "<leader>at", "<cmd>CodeCompanionChat toggle<cr>", desc = "toggle chat" },
--       { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "actions" },
--       { "<leader>ap", "<cmd>CodeCompanion<cr>#buffer ", desc = "prompt", mode = { "n" } },
--       { "<leader>ap", ":'<,'>CodeCompanion<cr>#buffer ", desc = "prompt", mode = { "v" } },
--     },
--   },
