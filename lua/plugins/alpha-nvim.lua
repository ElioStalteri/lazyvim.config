function hslToRgb(h, s, l)
  h = h / 360
  s = s / 100
  l = l / 100

  local r, g, b

  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    local function hue2rgb(p, q, t)
      if t < 0 then
        t = t + 1
      end
      if t > 1 then
        t = t - 1
      end
      if t < 1 / 6 then
        return p + (q - p) * 6 * t
      end
      if t < 1 / 2 then
        return q
      end
      if t < 2 / 3 then
        return p + (q - p) * (2 / 3 - t) * 6
      end
      return p
    end

    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = hue2rgb(p, q, h + 1 / 3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1 / 3)
  end

  if not a then
    a = 1
  end
  return r * 255, g * 255, b * 255, a * 255
end

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

local function get_color_number(i, rand) end

-- Map over the headers, setting a different color for each line.
-- This is done by setting the Highligh to gradientN, where N is the row index.
-- Define gradient1..gradientN to get a nice gradient.
local function header_whith_color()
  local lines = {}
  math.randomseed(os.time())
  math.random()
  local offset = math.random(360)
  for i, text in pairs(vim.split(logo, "\n")) do
    local hi = "gradient" .. math.fmod((i * 12 + offset), 361)
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
