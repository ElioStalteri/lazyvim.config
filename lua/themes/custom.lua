-- HSV to RGB
local min = math.min
local max = math.max
local abs = math.abs

local function HSV2RGB(h, s, v)
  local k1 = v * (1 - s)
  local k2 = v - k1
  local r = min(max(3 * abs((h / 180) % 2 - 1) - 1, 0), 1)
  local g = min(max(3 * abs(((h - 120) / 180) % 2 - 1) - 1, 0), 1)
  local b = min(max(3 * abs(((h + 120) / 180) % 2 - 1) - 1, 0), 1)
  local ex_r = string.format("%02x", k1 + k2 * r * 255)
  local ex_g = string.format("%02x", k1 + k2 * g * 255)
  local ex_b = string.format("%02x", k1 + k2 * b * 255)
  return "#" .. ex_r .. ex_g .. ex_b
end

local function add_missing(dst, src)
  for k, v in pairs(src) do
    if dst[k] == nil then
      dst[k] = v
    end
  end
  return dst -- for convenience (chaining)
end

local M = {}

M.scheme = {
  -- Main backgrounds
  background = "#282923",
  secondary_background = "#1d2026",
  ui_bg = "#1a1a18", -- background for ui (floating windows)
  sidebar_bg = "#1a1a18", -- background for file tree and other sidebars. same as ui_bg
  telescope_bg = "#181816", -- Slightly darker than ui_bg
  winbar_bg = "#27271e",
  ui_title_fg = "#e6db74", -- same as `yellow`
  -- Base colors
  white = "#f8f8f0",
  grey = "#8F908A",
  dark_grey = "#8a8b85",
  black = "#000000",
  green = "#9eda26",
  aqua = "#66d9ef",
  dimmed_aqua = "#4a7d87",
  yellow = "#e6db74",
  orange = "#fd971f",
  purple = "#ae81ff",
  red = "#e95678",
  light_red = "#f92672",
  dark_pink = "#e878d2",
  teal = "#3ae0b4",
  dark_yellow = "#ffd121",
  dark_teal = "#26cca0",
  -- Specific colors
  whitespace_fg = "#4d5154",
  non_text_fg = "#4d5154",
  comment_fg = "#9ca0a4",
  unnecessary_fg = "#a0a0a0",
  highlighted_word_bg = "#343942",
  tab_visible_fg = "#b3ab60",
  line_fg = "#f8f8f0",
  cursor_line_bg = "#333227",
  cursor_linenr_fg = "#e6db74",
  mid_orange = "#de933c",
  lightorange = "#dea255",
  telescope_prompt = "#1d1d1a",
  diff_add = "#3d5213",
  diff_remove = "#4a0f23",
  diff_change = "#27406b",
  diff_text = "#23324d",
  visual_bg = "#46453a",
  search_bg = "#424137",
  inc_search_fg = "#1f1f19", -- same as background
  inc_search_bg = "#fd971f", -- same as orange
  pmenu_bg = "#2c2c26",
  pmenu_sel_bg = "#40403a",
  pmenu_thumb_bg = "#47473b",
  vert_split_fg = "#75724b",
  vert_split_fg_active = "#948f5a", -- TODO: add nvim-zh/colorful-winsep.nvim support
  tabline_fg = "#f20aee",
  tabline_sel_fg = "#78b6e8",
  -- Plugins colors
  nvim_cmp_fuzzy_fg = "#34d8f7",
  git_signs_add = "#6a921a",
  git_signs_change = "#e6db74",

  status_line = {
    a_fg = "#434343",
    b_bg = "#45453b",
    c_bg = "#33332a",

    normal = "#de933c",
    insert = "#a0bfdf",
    visual = "#feacd0",
    replace = "#ffa0a0",
    command = "#88cf88",

    inactive = "#202020",
  },

  buffer_line = {
    bg = "#171712",
    fg = "#9ca0a4",
    selected_bg = "#1f1f19",
    selected_fg = "#f8f8f0",
    visible_fg = "#b3ab60",
    visible_bg = "#171712", -- same as bg
  },
}

local gradient = {}

for i = 1, 360, 1 do
  gradient["gradient" .. i] = {
    fg = HSV2RGB(i, 1, 1),
  }
end

-- t(gradient)

M.hl_groups = function(scheme)
  return add_missing({
    ["@lsp.type.parameter"] = {
      fg = scheme.orange,
      italic = true,
    },
    ["@function"] = {
      fg = scheme.green,
      italic = true,
    },
    ["@keyword.function"] = {
      fg = scheme.aqua,
      italic = true,
    },
    ["@keyword.typescript"] = {
      fg = scheme.aqua,
      italic = true,
    },
    ["@keyword.operator"] = {
      fg = scheme.red,
      italic = true,
    },
    ["@tag.builtin.tsx"] = {
      fg = scheme.red,
      italic = true,
    },
    ["Constant"] = {
      fg = scheme.white,
      italic = true,
    },
    ["StorageClass"] = {
      fg = scheme.green,
      italic = true,
    },
    ["@punctuation.bracket"] = {
      fg = scheme.white,
    },
    ["@lsp.type.class.svelte"] = {
      fg = scheme.aqua,
    },
    ["NonText"] = {
      fg = scheme.grey,
    },

    -- FlashBackdrop
    -- FlashMatch
    -- FlashCurrent
    -- FlashLabel
    -- FlashPrompt
    -- FlashPromptIcon
    -- FlashCursor
    ["FlashBackdrop"] = {},
    ["FlashMatch"] = {
      fg = scheme.black,
      bg = scheme.yellow,
      bold = true,
    },
    ["FlashLabel"] = {
      fg = scheme.black,
      bg = scheme.yellow,
      bold = true,
    },
  }, gradient)
end

return M
