---@type LazyPluginSpec[]
return {
  {
    "ibhagwan/fzf-lua",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      files = {
        hidden = true,
        fd_opts = "--color=never --hidden --type f --type l --exclude .git --exclude node_modules --exclude .venv",
      },
      grep = {
        hidden = true,
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden --glob '!.git' --glob '!node_modules' --glob '!.venv' -e",
      },
    },
    config = function(_, opts)
      local fzf = require("fzf-lua")
      fzf.setup(opts)

      if fzf.register_ui_select then
        fzf.register_ui_select()
      end

      vim.keymap.set("n", "<leader>sh", fzf.helptags, { desc = "Search Help" })
      vim.keymap.set("n", "<leader>sk", fzf.keymaps, { desc = "Search Keymaps" })
      vim.keymap.set("n", "<leader>sf", fzf.files, { desc = "Search Files" })
      vim.keymap.set("n", "<leader>sw", fzf.grep_cword, { desc = "Search current Word" })
      vim.keymap.set("n", "<leader>sg", fzf.live_grep, { desc = "Search by Grep" })
      vim.keymap.set("n", "<leader>/", fzf.live_grep, { desc = "Search by Grep" })
      vim.keymap.set("n", "<leader>sd", fzf.diagnostics_workspace, { desc = "Search Diagnostics" })
      vim.keymap.set("n", "<leader>sc", fzf.commands, { desc = "Search commands" })
      vim.keymap.set("n", "<leader>sC", fzf.command_history, { desc = "Search commands history" })
      vim.keymap.set("n", "<leader>s.", fzf.oldfiles, { desc = 'Search Recent Files ("." for repeat)' })
      vim.keymap.set("n", "<leader>bl", fzf.buffers, { desc = "Find existing buffers" })
      vim.keymap.set("n", "<leader>s/", fzf.lgrep_curbuf, { desc = "Search / in Current Buffer" })

      vim.keymap.set("n", "<leader>sn", function()
        fzf.files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "Search Neovim files" })
    end,
  },
}
