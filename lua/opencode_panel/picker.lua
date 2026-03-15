local config = require("opencode_panel.config")

local M = {
  renderer = nil,
}

local function setup_highlights()
  vim.api.nvim_set_hl(0, "OpencodePanelPickerBg", { fg = "#f8f8f0", bg = "#141412" })
  vim.api.nvim_set_hl(0, "OpencodePanelPickerBorder", { fg = "#4d5154", bg = "#141412" })
  vim.api.nvim_set_hl(0, "OpencodePanelPickerHeader", { fg = "#9ca0a4", bg = "#141412" })
  vim.api.nvim_set_hl(0, "OpencodePanelPickerHelp", { fg = "#7f837d", bg = "#141412" })
  vim.api.nvim_set_hl(0, "OpencodePanelPickerStatus", { fg = "#8f908a", bg = "#141412" })
  vim.api.nvim_set_hl(0, "OpencodePanelPickerCursor", { bg = "#3a3933" })
  vim.api.nvim_set_hl(0, "OpencodePanelPickerPrimary", { fg = "#f8f8f0" })
  vim.api.nvim_set_hl(0, "OpencodePanelPickerSecondary", { fg = "#8f908a" })
  vim.api.nvim_set_hl(0, "OpencodePanelPickerAccent", { fg = "#d4b483" })
  vim.api.nvim_set_hl(0, "OpencodePanelPickerDanger", { fg = "#e95678" })
end

local function normalize_items(items)
  local n = require("nui-components")
  local nodes = {}
  for index, item in ipairs(items or {}) do
    nodes[index] = n.node({
      id = item.id or tostring(index),
      label = item.label or tostring(item),
      detail = item.detail,
      highlight = item.highlight,
      value = item.value ~= nil and item.value or item,
      raw = item,
      type = "item",
    })
  end
  return nodes
end

function M.close()
  if M.renderer then
    M.renderer:close()
    M.renderer = nil
  end
end

function M.open(opts)
  opts = opts or {}
  M.close()
  setup_highlights()

  local n = require("nui-components")
  local width = opts.width or math.max(44, math.floor(vim.o.columns * math.min(config.ui.width_ratio, 0.38)))
  local height = opts.height or math.max(12, math.floor(vim.o.lines * 0.42))
  local row = math.max(math.floor((vim.o.lines - height) / 2) - 1, 0)
  local col = math.max(math.floor((vim.o.columns - width) / 2), 0)
  local nodes = normalize_items(opts.items)

  local renderer = n.create_renderer({
    width = width,
    height = height,
    relative = "editor",
    position = { row = row, col = col },
  })

  local signal = n.create_signal({
    nodes = nodes,
    help = opts.help or "Enter select | q close",
    status = opts.status or string.format("%d item%s", #nodes, #nodes == 1 and "" or "s"),
  })

  local function close_picker()
    renderer:close()
  end

  local function select_node(node)
    if not node then
      return
    end

    close_picker()
    if opts.on_select then
      opts.on_select(node.value, node.raw)
    end
  end

  local function body()
    return n.rows(
      n.paragraph({
        lines = opts.description or (opts.title or "Picker"),
        is_focusable = false,
        window = {
          highlight = {
            Normal = "OpencodePanelPickerHelp",
            NormalFloat = "OpencodePanelPickerHelp",
          },
        },
      }),
      n.tree({
        id = "picker-tree",
        flex = 1,
        autofocus = true,
        border_label = opts.title or "Picker",
        data = signal.nodes,
        window = {
          highlight = {
            FloatBorder = "OpencodePanelPickerBorder",
            FloatTitle = "OpencodePanelPickerHeader",
            Normal = "OpencodePanelPickerBg",
            NormalFloat = "OpencodePanelPickerBg",
            CursorLine = "OpencodePanelPickerCursor",
          },
        },
        on_change = function(node)
          if not node then
            signal.status = string.format("%d item%s", #nodes, #nodes == 1 and "" or "s")
            return
          end

          signal.status = node.detail or node.label
        end,
        on_select = function(node)
          select_node(node)
        end,
        prepare_node = function(node, line)
          line:append(node.label, node.highlight or "OpencodePanelPickerPrimary")
          if node.detail and node.detail ~= "" then
            line:append("  " .. node.detail, "OpencodePanelPickerSecondary")
          end
          return line
        end,
      }),
      n.paragraph({
        lines = signal.help,
        is_focusable = false,
        window = {
          highlight = {
            Normal = "OpencodePanelPickerHelp",
            NormalFloat = "OpencodePanelPickerHelp",
          },
        },
      }),
      n.paragraph({
        lines = signal.status,
        is_focusable = false,
        window = {
          highlight = {
            Normal = "OpencodePanelPickerStatus",
            NormalFloat = "OpencodePanelPickerStatus",
          },
        },
      })
    )
  end

  renderer:add_mappings({
    {
      mode = "n",
      key = "q",
      handler = close_picker,
    },
    {
      mode = "n",
      key = "<Esc>",
      handler = close_picker,
    },
  })

  renderer:on_unmount(function()
    if M.renderer == renderer then
      M.renderer = nil
    end
    if opts.on_close then
      opts.on_close()
    end
  end)

  M.renderer = renderer
  renderer:render(body)
end

return M
