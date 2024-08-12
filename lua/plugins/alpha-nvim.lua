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
  local offset = math.random(360) + 1
  for i, text in pairs(vim.split(logo, "\n")) do
    local hi = "gradient" .. math.fmod((i * 12 + offset), 359)
    local line_chars = text
    local line = {
      type = "text",
      val = line_chars,
      opts = {
        hl = hi,
        -- shrink_margin = false,
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

return {
  "goolord/alpha-nvim",
  opts = function()
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = nil
    dashboard.opts.layout[2] = header_whith_color()

    return dashboard
  end,
  -- config = function()
  --   require("alpha").setup(configure())
  -- end,
}
