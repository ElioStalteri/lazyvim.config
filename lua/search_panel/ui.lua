local state = require("search_panel.state")

local M = {}

local function register_results_which_key(bufnr)
  local ok, wk = pcall(require, "which-key")
  if not ok then
    return
  end

  wk.add({
    { "a", desc = "Apply current diff", mode = "n", buffer = bufnr },
    { "A", desc = "Apply current file", mode = "n", buffer = bufnr },
  })
end

local function error_panel(n, lines_signal, hidden_signal)
  return n.paragraph({
    lines = lines_signal,
    hidden = hidden_signal,
    is_focusable = false,
    border_style = "rounded",
    border_label = "Error",
    truncate = true,
    max_lines = 2,
    window = {
      highlight = {
        FloatBorder = "SearchPanelErrorBorder",
        FloatTitle = "SearchPanelErrorHeader",
        Normal = "SearchPanelErrorText",
        NormalFloat = "SearchPanelErrorText",
      },
    },
  })
end

function M.create_body(n, callbacks)
  return function()
    return n.rows(
      n.paragraph({
        lines = state.signal.mode_help,
        is_focusable = false,
        window = {
          highlight = {
            Normal = "SearchPanelHelp",
            NormalFloat = "SearchPanelHelp",
          },
        },
      }),
      n.text_input({
        id = "search-input",
        border_label = state.signal.search_label,
        max_lines = 1,
        autofocus = true,
        on_mount = function(component)
          state.search_input_component = component
          callbacks.sync_search_border_label()
        end,
        on_unmount = function(component)
          if state.search_input_component == component then
            state.search_input_component = nil
          end
        end,
        on_blur = callbacks.clear_preview_if_panel_unfocused,
        window = {
          highlight = {
            FloatBorder = "SearchPanelBorder",
            FloatTitle = "SearchPanelHeader",
            Normal = "SearchPanelBg",
            NormalFloat = "SearchPanelBg",
          },
        },
        value = state.signal.search,
        on_change = function(value)
          state.search = value
          callbacks.queue_signal_value("search", value)
          state.reset_results_to_top_on_next_results = true
          state.sd_preview_cache = {}
          callbacks.clear_section_error("search")
          callbacks.schedule_search(n, "search")
        end,
      }),
      error_panel(n, state.signal.search_error, state.signal.search_error_hidden),
      n.text_input({
        id = "replace-input",
        border_label = "Replace",
        max_lines = 1,
        on_blur = callbacks.clear_preview_if_panel_unfocused,
        window = {
          highlight = {
            FloatBorder = "SearchPanelBorder",
            FloatTitle = "SearchPanelHeader",
            Normal = "SearchPanelBg",
            NormalFloat = "SearchPanelBg",
          },
        },
        value = state.signal.replacement,
        on_change = function(value)
          state.replacement = value
          callbacks.queue_signal_value("replacement", value)
          state.sd_preview_cache = {}
          callbacks.clear_section_error("replace")
          callbacks.schedule_preview_compute(n, 300)
        end,
      }),
      error_panel(n, state.signal.replace_error, state.signal.replace_error_hidden),
      n.text_input({
        id = "include-input",
        border_label = "Files to include",
        max_lines = 1,
        on_blur = callbacks.clear_preview_if_panel_unfocused,
        window = {
          highlight = {
            FloatBorder = "SearchPanelBorder",
            FloatTitle = "SearchPanelHeader",
            Normal = "SearchPanelBg",
            NormalFloat = "SearchPanelBg",
          },
        },
        value = state.signal.include,
        placeholder = "lua/**/*.lua,lua/config/**",
        on_change = function(value)
          state.include = value
          callbacks.queue_signal_value("include", value)
          state.sd_preview_cache = {}
          callbacks.clear_section_error("include")
          callbacks.schedule_search(n, "include")
        end,
      }),
      error_panel(n, state.signal.include_error, state.signal.include_error_hidden),
      n.tree({
        id = "result-tree",
        flex = 1,
        border_label = "Results",
        on_blur = callbacks.clear_preview_if_panel_unfocused,
        mappings = function()
          return {
            {
              mode = "n",
              key = "a",
              handler = function()
                callbacks.apply_current_match(n)
              end,
            },
            {
              mode = "n",
              key = "A",
              handler = function()
                callbacks.apply_current_file(n)
              end,
            },
          }
        end,
        on_mount = function(component)
          state.results_component = component
          register_results_which_key(component.bufnr)
        end,
        on_unmount = function(component)
          if state.results_component == component then
            state.results_component = nil
          end
        end,
        window = {
          highlight = {
            FloatBorder = "SearchPanelBorder",
            FloatTitle = "SearchPanelHeader",
            Normal = "SearchPanelResultsBg",
            NormalFloat = "SearchPanelResultsBg",
            CursorLine = "SearchPanelCursorLine",
          },
        },
        data = state.signal.nodes,
        on_change = function(node)
          state.focused_node = node
          callbacks.schedule_preview(node)
        end,
        on_select = function(node, component)
          if not node then
            return
          end

          state.focused_node = node

          if node.type == "file" then
            local tree = component:get_tree()
            if node:is_expanded() then
              node:collapse()
            else
              node:expand()
            end
            tree:render()
            component:set_focused_node(node)
            return
          end

          callbacks.jump_to(node)
        end,
        prepare_node = function(node, line)
          if node.type == "file" then
            local marker = node:is_expanded() and " " or " "
            line:append(marker, "SearchPanelArrow")
            line:append((node.icon or "*") .. " ", node.icon_hl or "SearchPanelFile")
            line:append(node.text, "SearchPanelFile")
          else
            line:append("  ")
            line:append(string.format("%d:%d ", node.lnum, node.col), "Comment")
            line:append(node.left or "")
            line:append(node.match_text or "", "SearchPanelMatch")
            local replacement_text = node.replacement_text
            if replacement_text == "" then
              replacement_text = "<empty>"
            end
            line:append(replacement_text, "SearchPanelReplace")
            line:append(node.right or "")
          end
          return line
        end,
      }),
      error_panel(n, state.signal.results_error, state.signal.results_error_hidden),
      n.paragraph({
        lines = "Results panel only: a apply focused diff, A apply focused file\n"
          .. "Any panel section: m toggle literal/regex, R apply all (confirm)",
        is_focusable = false,
        window = {
          highlight = {
            Normal = "SearchPanelHelp",
            NormalFloat = "SearchPanelHelp",
          },
        },
      }),
      n.paragraph({
        lines = state.signal.status,
        is_focusable = false,
        window = {
          highlight = {
            Normal = "SearchPanelStatus",
            NormalFloat = "SearchPanelStatus",
          },
        },
      })
    )
  end
end

function M.add_renderer_mappings(renderer, n, callbacks)
  renderer:add_mappings({
    {
      mode = "n",
      key = "q",
      handler = function()
        renderer:close()
      end,
    },
    {
      mode = "n",
      key = "r",
      handler = function()
        callbacks.schedule_search(n, "manual", { force = true })
      end,
    },
    {
      mode = "n",
      key = "m",
      handler = function()
        callbacks.toggle_mode(n)
      end,
    },
    {
      mode = "n",
      key = "R",
      handler = function()
        callbacks.confirm_apply_all_files(n)
      end,
    },
  })
end

return M
