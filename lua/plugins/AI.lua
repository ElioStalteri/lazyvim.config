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
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        display = { chat = { window = { layout = "float", height = 0.9, width = 0.9 } } },
        strategies = {
          chat = {
            adapter = "gemini",
          },
          inline = {
            adapter = "gemini",
          },
          workflow = {
            adapter = "gemini",
          },
        },
        adapters = {
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              env = {
                api_key = os.getenv("AI_API_KEY"),
                model = "gemini-2.0-flash", -- "gemini-2.5-pro-exp-03-25"
              },
            })
          end,
        },
        prompt_library = {
          ["Generate a Commit Message"] = {
            strategy = "chat",
            description = "auto-generate a commit message",
            opts = {
              index = 10,
              is_default = true,
              is_slash_cmd = true,
              short_name = "commit",
              auto_submit = true,
            },
            prompts = {
              {
                role = "user",
                content = function()
                  local git_conventions = {
                    docs = { icon = "📖", prefix = "docs", type = "Documentation changes" },
                    fix = { icon = "🐛", prefix = "fix", type = "Bug fix" },
                    feat = { icon = "✨", prefix = "feat", type = "New feature" },
                    enhance = { icon = "⚡", prefix = "enhance", type = "Enhancement" },
                    chore = { icon = "🧹", prefix = "chore", type = "Chore" },
                    refactor = { icon = "⚠️", prefix = "refactor", type = "Breaking change" },
                  }
                  local format_lines = {}
                  for _, convention in pairs(git_conventions) do
                    table.insert(
                      format_lines,
                      string.format("%s %s: %s", convention.icon, convention.prefix, convention.type)
                    )
                  end

                  local prompt = string.format(
                    "Analyze this git diff and generate single line commit messages and a commit descrition in plain text.\n"
                      .. "USE EXACTLY THIS FORMAT WITHOUT ADDITIONAL EXPLANATION:\n\n"
                      .. "<icon> <prefix>: <commit message>\n\n"
                      .. "Options:\n%s\n\nGit diff:\n\n```diff\n\n%s\n\n```",
                    table.concat(format_lines, "\n"),
                    vim.fn.system("git diff --no-ext-diff --staged")
                  )
                  return prompt
                end,
                opts = {
                  contains_code = true,
                },
              },
            },
          },
        },
      })
    end,
    keys = {
      { "<leader>at", "<cmd>CodeCompanionChat toggle<cr>", desc = "toggle chat" },
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "actions" },
      { "<leader>ap", "<cmd>CodeCompanion<cr>", desc = "prompt", mode = { "n" } },
      { "<leader>ap", ":'<,'>CodeCompanion<cr>", desc = "prompt", mode = { "v" } },
    },
  },
}
