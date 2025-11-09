---@type LazyPluginSpec[]
return {
  {
    "ahkohd/difft.nvim",
    keys = {
      {
        "<leader>gd",
        function()
          if Difft.is_visible() then
            Difft.hide()
          else
            Difft.diff()
          end
        end,
        desc = "Toggle diff",
      },
      {
        "<leader>gD",
        function()
          if Difft.is_visible() then
            Difft.hide()
          else
            Difft.diff({ cmd = "GIT_EXTERNAL_DIFF='difft --color=always' git diff HEAD^ HEAD" })
          end
        end,
        desc = "Toggle diff last commit",
      },
      {
        "<leader>gf",
        function()
          -- Get all buffer handles
          local buffers = vim.api.nvim_list_bufs()

          -- Collect the names of listed (open) buffers
          local open_files = {}
          for _, buf in ipairs(buffers) do
            if vim.api.nvim_buf_get_option(buf, "buflisted") then
              local name = vim.api.nvim_buf_get_name(buf)
              table.insert(open_files, name)
            end
          end

          -- check number of files
          if #open_files ~= 2 then
            local msg = "Expected exactly 2 files, but got " .. #open_files
            vim.notify(msg, vim.log.levels.WARN)
            return
          end

          -- Print the list
          if Difft.is_visible() then
            Difft.hide()
          else
            Difft.diff({ cmd = "difft --color=always " .. table.concat(open_files, " ") })
          end
        end,
        desc = "Toggle diff last commit",
      },
    },
    config = function()
      require("difft").setup({
        command = "GIT_EXTERNAL_DIFF='difft --color=always' git diff", -- or "jj diff --no-pager"
        layout = "ivy_taller", -- nil (buffer), "float", or "ivy_taller"
      })
    end,
  },
  {
    "FabijanZulj/blame.nvim",
    lazy = false,
    opts = {
      blame_options = { "-w" },
    },
    keys = {
      { "<leader>gb", "<cmd>BlameToggle<cr>", desc = "Toggle blame" },
    },
  },
}
