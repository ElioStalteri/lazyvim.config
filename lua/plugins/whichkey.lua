---@type LazyPluginSpec[]
return {
  { -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    event = "VimEnter", -- Sets the loading event to 'VimEnter'
    opts = {
      preset = "helix",
      icons = {
        -- set icon mappings to true if you have a Nerd Font
        mappings = vim.g.have_nerd_font,
        -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
        -- default whick-key.nvim defined Nerd Font icons, otherwise define a string table
        keys = vim.g.have_nerd_font and {} or {
          Up = "<Up> ",
          Down = "<Down> ",
          Left = "<Left> ",
          Right = "<Right> ",
          C = "<C-…> ",
          M = "<M-…> ",
          D = "<D-…> ",
          S = "<S-…> ",
          CR = "<CR> ",
          Esc = "<Esc> ",
          ScrollWheelDown = "<ScrollWheelDown> ",
          ScrollWheelUp = "<ScrollWheelUp> ",
          NL = "<NL> ",
          BS = "<BS> ",
          Space = "<Space> ",
          Tab = "<Tab> ",
          F1 = "<F1>",
          F2 = "<F2>",
          F3 = "<F3>",
          F4 = "<F4>",
          F5 = "<F5>",
          F6 = "<F6>",
          F7 = "<F7>",
          F8 = "<F8>",
          F9 = "<F9>",
          F10 = "<F10>",
          F11 = "<F11>",
          F12 = "<F12>",
        },
      },

      -- Document existing key chains
      spec = {
        {
          mode = { "n", "v" },
          { "<leader>c", group = "Code", icon = { icon = " ", color = "orange" } },
          { "<leader>cs", group = "Snippets", icon = { icon = " ", color = "orange" } },
          { "<leader>g", group = "Git", icon = { icon = " ", color = "red" } },
          { "<leader>t", group = "Toggle", icon = { icon = "󰞏 ", color = "yellow" } },
          { "<leader>C", group = "Conflicts", icon = { icon = "📛 ", color = "red" } },
          { "<leader>n", group = "Notifications", icon = { icon = "📥 ", color = "yellow" } },
          { "<leader>f", group = "Quickfix", icon = { icon = "📄 ", color = "yellow" } },
          { "<leader>s", group = "Search", icon = { icon = " ", color = "blue" } },
          { "<leader>a", group = "AI", icon = { icon = "🧠 ", color = "blue" } },
          { "<leader>w", group = "window", icon = { icon = " ", color = "blue" } },
          { "<leader>b", group = "Buffer", icon = { icon = "󰌒 ", color = "white" } },
          { "<leader>x", group = "Exec", icon = { icon = " ", color = "orange" } },
          { "<leader>u", group = "Ui", icon = { icon = " ", color = "orange" } },
          { "<leader>q", group = "Close All", icon = { icon = "󱎘 ", color = "red" } },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "gs", group = "surround" },
          { "z", group = "fold" },
        },
      },
    },
  },
}
