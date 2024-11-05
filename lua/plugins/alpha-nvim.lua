local logo = [[
                                                                                  
                     ████ ██████           █████      ██                    
                    ███████████             █████                            
                    █████████ ███████████████████ ███   ███████████  
                   █████████  ███    █████████████ █████ ██████████████  
                  █████████ ██████████ █████████ █████ █████ ████ █████  
                ███████████ ███    ███ █████████ █████ █████ ████ █████ 
               ██████  █████████████████████ ████ █████ █████ ████ ██████
                                                                     


        ██╗  ██╗███████╗███████╗██████╗     ██╗████████╗    ███████╗██╗███╗   ███╗██████╗ ██╗     ███████╗
        ██║ ██╔╝██╔════╝██╔════╝██╔══██╗    ██║╚══██╔══╝    ██╔════╝██║████╗ ████║██╔══██╗██║     ██╔════╝
        █████╔╝ █████╗  █████╗  ██████╔╝    ██║   ██║       ███████╗██║██╔████╔██║██████╔╝██║     █████╗  
        ██╔═██╗ ██╔══╝  ██╔══╝  ██╔═══╝     ██║   ██║       ╚════██║██║██║╚██╔╝██║██╔═══╝ ██║     ██╔══╝  
        ██║  ██╗███████╗███████╗██║         ██║   ██║       ███████║██║██║ ╚═╝ ██║██║     ███████╗███████╗
        ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝         ╚═╝   ╚═╝       ╚══════╝╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝
                                                                                                  
]]

-- Map over the headers, setting a different color for each line.
-- This is done by setting the Highligh to gradientN, where N is the row index.
-- Define gradient1..gradientN to get a nice gradient.
local function header_whith_color()
  local lines = {}
  math.randomseed(os.time())
  math.random()
  local offset = math.random(360)
  for i, text in pairs(vim.split(logo, "\n")) do
    local hi = "gradient" .. math.fmod((i * 12 + offset), 359)
    local line_chars = text
    local line = {
      type = "text",
      val = line_chars,
      opts = {
        hl = hi,
        shrink_margin = false,
        position = "center",
      },
    }
    table.insert(lines, line)
  end

  local output = {
    type = "group",
    val = lines,
    opts = { position = "center" },
  }

  return output
end

local function info()
  local plugins = #vim.tbl_keys(require("lazy").plugins())
  local v = vim.version()
  local datetime = os.date(" %d-%m-%Y")
  local platform = vim.fn.has("win32") == 1 and "" or ""
  return string.format(
    "󰂖 plugins %d, %s nvim %d.%d.%d, date %s",
    plugins,
    platform,
    v.major,
    v.minor,
    v.patch,
    datetime
  )
end

return {
  "goolord/alpha-nvim",
  -- opts = function()
  --   local dashboard = require("alpha.themes.dashboard")
  --
  --   dashboard.section.header.val = nil
  --   dashboard.opts.layout[2] = header_whith_color()
  --
  --   return dashboard
  -- end,
  config = function()
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = nil
    dashboard.opts.layout[2] = header_whith_color()

    local buttons = {
      type = "group",
      position = "center",
      val = {
        { type = "padding", val = 1 },
        {
          type = "text",
          val = info(),
          opts = { hl = "Keyword", position = "center" },
        },
        { type = "padding", val = 1 },
        { type = "padding", val = 1 },
        { type = "padding", val = 1 },
      },
    }

    dashboard.opts.layout[3] = buttons
    dashboard.section.buttons.val = {
      dashboard.button("f", " " .. " Find file", ":Telescope find_files<CR>"),
      dashboard.button("n", " " .. " New file", ":ene <BAR> startinsert <CR>"),
      dashboard.button("s", " " .. " Restore Session", [[<cmd> lua require("persistence").load() <cr>]]),
      dashboard.button("r", " " .. " Recent files", ":Telescope oldfiles<CR>"),
      dashboard.button("l", "󰒲 " .. " Lazy", "<cmd> Lazy <cr>"),
      dashboard.button("q", " " .. " Quit", "<cmd> qa <cr>"),
    }

    require("alpha").setup(dashboard.config)
  end,
}
