local uv = vim.uv or vim.loop

local M = {}

local state = {
  renderer = nil,
  signal = nil,
  cwd = nil,
  search = "",
  replacement = "",
  include = "",
  files = {},
  focused_node = nil,
  search_seq = 0,
  search_timer = nil,
}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Search Panel" })
end

local function setup_highlights()
  vim.api.nvim_set_hl(0, "SearchPanelBorder", { fg = "#5f6672", default = true })
  vim.api.nvim_set_hl(0, "SearchPanelHeader", { fg = "#aeb6c2", default = true })
  vim.api.nvim_set_hl(0, "SearchPanelFile", { link = "Directory", default = true })
  vim.api.nvim_set_hl(0, "SearchPanelMatch", { link = "DiffDelete", default = true })
  vim.api.nvim_set_hl(0, "SearchPanelReplace", { link = "DiffAdd", default = true })
end

local function normalize_path(path)
  if path:sub(1, 1) == "/" then
    return path
  end

  return state.cwd .. "/" .. path
end

local function shorten(str, max_len)
  if #str <= max_len then
    return str
  end

  return str:sub(1, max_len - 3) .. "..."
end

local function trim(str)
  return (str:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function build_preview_parts(line_text, col, search, replacement)
  local text = (line_text or ""):gsub("\t", "  ")
  local start_col = math.max(1, tonumber(col) or 1)
  local end_col = start_col + math.max(#search, 1) - 1

  if #text == 0 then
    return {
      left = "",
      match = search,
      replacement = replacement,
      right = "",
    }
  end

  if start_col > #text then
    start_col = math.max(1, #text - #search + 1)
    end_col = start_col + math.max(#search, 1) - 1
  end

  local from = math.max(1, start_col - 18)
  local to = math.min(#text, end_col + 22)

  local left = text:sub(from, start_col - 1)
  local match_text = text:sub(start_col, end_col)
  local right = text:sub(end_col + 1, to)

  if from > 1 then
    left = "..." .. left
  end
  if to < #text then
    right = right .. "..."
  end

  return {
    left = shorten(left, 40),
    match = match_text,
    replacement = replacement,
    right = shorten(right, 40),
  }
end

local function parse_rg_output(stdout)
  local files = {}

  for line in (stdout .. "\n"):gmatch("(.-)\n") do
    if line ~= "" then
      local rel_path, lnum, col, text = line:match("^(.-):(%d+):(%d+):(.*)$")
      if rel_path and lnum and col then
        local abs_path = normalize_path(rel_path)
        local match = {
          type = "match",
          rel_path = rel_path,
          path = abs_path,
          lnum = tonumber(lnum),
          col = tonumber(col),
          text = text,
        }

        local preview = build_preview_parts(text, tonumber(col), state.search, state.replacement)
        match.left = preview.left
        match.match_text = preview.match
        match.replacement_text = preview.replacement
        match.right = preview.right

        if not files[abs_path] then
          files[abs_path] = {
            path = abs_path,
            rel_path = rel_path,
            matches = {},
          }
        end

        table.insert(files[abs_path].matches, match)
      end
    end
  end

  return files
end

local function to_tree_nodes(n)
  local nodes = {}
  local paths = {}

  for path in pairs(state.files) do
    table.insert(paths, path)
  end

  table.sort(paths, function(a, b)
    return state.files[a].rel_path < state.files[b].rel_path
  end)

  for _, path in ipairs(paths) do
    local file = state.files[path]
    local children = {}

    for _, match in ipairs(file.matches) do
      table.insert(children, n.node({
        type = "match",
        path = match.path,
        rel_path = match.rel_path,
        lnum = match.lnum,
        col = match.col,
        left = match.left,
        match_text = match.match_text,
        replacement_text = match.replacement_text,
        right = match.right,
      }))
    end

    local first = file.matches[1]
    local file_node = n.node({
      type = "file",
      path = file.path,
      rel_path = file.rel_path,
      lnum = first and first.lnum or 1,
      col = first and first.col or 1,
      text = string.format("%s (%d)", file.rel_path, #file.matches),
    }, children)
    file_node:expand()
    table.insert(nodes, file_node)
  end

  return nodes
end

local function set_results(n, files, elapsed)
  state.files = files

  local file_count = 0
  local match_count = 0
  for _, file in pairs(files) do
    file_count = file_count + 1
    match_count = match_count + #file.matches
  end

  local nodes = to_tree_nodes(n)
  state.signal.nodes = nodes

  local match_word = match_count == 1 and "match" or "matches"
  local seconds = elapsed or 0
  state.signal.status = string.format("Total: %d %s in %d files, time: %.4fs", match_count, match_word, file_count, seconds)
end

local function parse_include_globs()
  local value = trim(state.include or "")
  local globs = {}

  if value == "" then
    return globs
  end

  for token in value:gmatch("[^,]+") do
    local part = trim(token)
    if part ~= "" then
      local has_wildcard = part:find("[%*%?%{%}]") ~= nil
      local is_file = part:match("%.[^/]+$") ~= nil

      if has_wildcard or is_file then
        table.insert(globs, part)
      elseif part:sub(-1) == "/" then
        table.insert(globs, part .. "**")
      else
        table.insert(globs, part .. "/**")
      end
    end
  end

  return globs
end

local function run_search(n)
  local search = state.search
  local started = uv.hrtime()

  state.search_seq = state.search_seq + 1
  local seq = state.search_seq

  if search == "" then
    state.files = {}
    state.signal.nodes = {}
    state.signal.status = "Type to search"
    return
  end

  state.signal.status = "Searching..."

  local args = {
    "rg",
    "--vimgrep",
    "--fixed-strings",
    "--hidden",
    "--glob",
    "!.git",
    "--glob",
    "!node_modules",
    "--glob",
    "!.venv",
    search,
  }

  local include_globs = parse_include_globs()
  for _, glob in ipairs(include_globs) do
    table.insert(args, "--glob")
    table.insert(args, glob)
  end

  vim.system(args, { text = true, cwd = state.cwd }, function(obj)
    vim.schedule(function()
      if not state.signal or seq ~= state.search_seq then
        return
      end

      if obj.code > 1 then
        state.signal.status = "Search failed"
        notify(obj.stderr ~= "" and obj.stderr or "rg failed", vim.log.levels.ERROR)
        return
      end

      local files = parse_rg_output(obj.stdout or "")
      local elapsed = (uv.hrtime() - started) / 1000000000
      set_results(n, files, elapsed)
    end)
  end)
end

local function schedule_search(n)
  if state.search_timer then
    state.search_timer:stop()
    state.search_timer:close()
    state.search_timer = nil
  end

  state.search_timer = uv.new_timer()
  state.search_timer:start(120, 0, function()
    vim.schedule(function()
      run_search(n)
    end)
  end)
end

local function jump_to(node)
  if not node or not node.path then
    return
  end

  local origin_win = state.renderer and state.renderer:get_origin_winid() or nil
  if origin_win and vim.api.nvim_win_is_valid(origin_win) then
    vim.api.nvim_set_current_win(origin_win)
  end

  vim.cmd("edit " .. vim.fn.fnameescape(node.path))
  pcall(vim.api.nvim_win_set_cursor, 0, { node.lnum or 1, math.max((node.col or 1) - 1, 0) })
end

local function read_file(path)
  local fd, open_err = uv.fs_open(path, "r", 438)
  if not fd then
    return nil, open_err
  end

  local stat, stat_err = uv.fs_fstat(fd)
  if not stat then
    uv.fs_close(fd)
    return nil, stat_err
  end

  local data, read_err = uv.fs_read(fd, stat.size, 0)
  uv.fs_close(fd)

  if not data then
    return nil, read_err
  end

  return data
end

local function write_file(path, content)
  local mode = 420
  local fd, open_err = uv.fs_open(path, "w", mode)
  if not fd then
    return false, open_err
  end

  local ok, write_err = uv.fs_write(fd, content, 0)
  uv.fs_close(fd)

  if not ok then
    return false, write_err
  end

  return true
end

local function replace_literal(content, search, replacement)
  if search == "" then
    return content, 0
  end

  local parts = {}
  local idx = 1
  local count = 0

  while true do
    local start_pos, end_pos = content:find(search, idx, true)
    if not start_pos then
      table.insert(parts, content:sub(idx))
      break
    end

    table.insert(parts, content:sub(idx, start_pos - 1))
    table.insert(parts, replacement)
    idx = end_pos + 1
    count = count + 1
  end

  return table.concat(parts), count
end

local function reload_buffer_if_loaded(path)
  local bufnr = vim.fn.bufnr(path)
  if bufnr == -1 or not vim.api.nvim_buf_is_loaded(bufnr) then
    return true
  end

  if vim.bo[bufnr].modified then
    return false
  end

  vim.api.nvim_buf_call(bufnr, function()
    vim.cmd("silent checktime")
  end)

  return true
end

local function apply_paths(paths, n)
  if state.search == "" then
    notify("Search value is empty", vim.log.levels.WARN)
    return
  end

  local changed_files = 0
  local replaced_total = 0
  local skipped_modified = 0

  for _, path in ipairs(paths) do
    local bufnr = vim.fn.bufnr(path)
    if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].modified then
      skipped_modified = skipped_modified + 1
      goto continue
    end

    local original, read_err = read_file(path)
    if not original then
      notify(string.format("Cannot read %s: %s", path, read_err or "unknown error"), vim.log.levels.ERROR)
      goto continue
    end

    local updated, count = replace_literal(original, state.search, state.replacement)
    if count > 0 and updated ~= original then
      local ok, write_err = write_file(path, updated)
      if not ok then
        notify(string.format("Cannot write %s: %s", path, write_err or "unknown error"), vim.log.levels.ERROR)
        goto continue
      end

      changed_files = changed_files + 1
      replaced_total = replaced_total + count
      reload_buffer_if_loaded(path)
    end

    ::continue::
  end

  local msg = string.format("Applied %d replacements in %d files", replaced_total, changed_files)
  if skipped_modified > 0 then
    msg = msg .. string.format(" (%d modified buffers skipped)", skipped_modified)
  end
  notify(msg)

  run_search(n)
end

local function apply_current_file(n)
  local node = state.focused_node
  if not node then
    notify("No file selected", vim.log.levels.WARN)
    return
  end

  local path = node.path
  if node.type ~= "file" and node.type ~= "match" then
    notify("No file selected", vim.log.levels.WARN)
    return
  end

  apply_paths({ path }, n)
end

local function apply_all_files(n)
  local paths = {}
  for path in pairs(state.files) do
    table.insert(paths, path)
  end

  table.sort(paths)
  if #paths == 0 then
    notify("No files to apply", vim.log.levels.WARN)
    return
  end

  apply_paths(paths, n)
end

function M.open(opts)
  if state.renderer then
    state.renderer:focus()
    return
  end

  local n = require("nui-components")
  setup_highlights()
  state.cwd = (opts and opts.cwd) or vim.fn.getcwd()

  local width = math.max(44, math.floor(vim.o.columns * 0.34))
  local height = math.max(14, vim.o.lines - 2)
  local col = math.max(vim.o.columns - width, 0)

  local renderer = n.create_renderer({
    width = width,
    height = height,
    relative = "editor",
    position = { row = 1, col = col },
  })

  state.renderer = renderer
  state.signal = n.create_signal({
    search = "",
    replacement = "",
    include = "",
    nodes = {},
    status = "Type to search",
  })

  local function body()
    return n.rows(
      n.text_input({
        id = "search-input",
        border_label = "Search (literal)",
        max_lines = 1,
        autofocus = true,
        window = {
          highlight = {
            FloatBorder = "SearchPanelBorder",
            FloatTitle = "SearchPanelHeader",
          },
        },
        value = state.signal.search,
        on_change = function(value)
          state.search = value
          state.signal.search = value
          schedule_search(n)
        end,
      }),
      n.text_input({
        id = "replace-input",
        border_label = "Replace",
        max_lines = 1,
        window = {
          highlight = {
            FloatBorder = "SearchPanelBorder",
            FloatTitle = "SearchPanelHeader",
          },
        },
        value = state.signal.replacement,
        on_change = function(value)
          state.replacement = value
          state.signal.replacement = value
          schedule_search(n)
        end,
      }),
      n.text_input({
        id = "include-input",
        border_label = "Files to include",
        max_lines = 1,
        window = {
          highlight = {
            FloatBorder = "SearchPanelBorder",
            FloatTitle = "SearchPanelHeader",
          },
        },
        value = state.signal.include,
        placeholder = "lua/**/*.lua,lua/config/**",
        on_change = function(value)
          state.include = value
          state.signal.include = value
          schedule_search(n)
        end,
      }),
      n.tree({
        id = "result-tree",
        flex = 1,
        border_label = "Results",
        window = {
          highlight = {
            FloatBorder = "SearchPanelBorder",
            FloatTitle = "SearchPanelHeader",
          },
        },
        data = state.signal.nodes,
        on_change = function(node)
          state.focused_node = node
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

          jump_to(node)
        end,
        prepare_node = function(node, line)
          if node.type == "file" then
            local marker = node:is_expanded() and "▾ " or "▸ "
            line:append(marker, "Comment")
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
      n.paragraph({
        lines = state.signal.status,
        is_focusable = false,
      })
    )
  end

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
      key = "a",
      handler = function()
        apply_current_file(n)
      end,
    },
    {
      mode = "n",
      key = "A",
      handler = function()
        apply_all_files(n)
      end,
    },
    {
      mode = "n",
      key = "r",
      handler = function()
        run_search(n)
      end,
    },
  })

  renderer:on_unmount(function()
    state.renderer = nil
    state.signal = nil
    state.files = {}
    state.focused_node = nil
    state.search = ""
    state.replacement = ""
    state.include = ""
    if state.search_timer then
      state.search_timer:stop()
      state.search_timer:close()
      state.search_timer = nil
    end
  end)

  renderer:render(body)
end

function M.setup()
  vim.api.nvim_create_user_command("SearchPanel", function(command_opts)
    M.open({ cwd = command_opts.args ~= "" and command_opts.args or vim.fn.getcwd() })
  end, {
    nargs = "?",
    complete = "dir",
    desc = "Open literal search/replace panel",
  })
end

return M
