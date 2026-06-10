local utils = require("search_panel.utils")

local M = {}

function M.get_file_icon(path)
  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return "*", "SearchPanelFile"
  end

  local file = vim.fs.basename(path)
  local ext = file:match("%.([^.]+)$")
  local icon, icon_hl = devicons.get_icon(file, ext, { default = true })

  return icon or "*", icon_hl or "SearchPanelFile"
end

function M.build_preview_parts(line_text, start_col0, end_col0, match_text, replacement)
  local text = line_text or ""
  local start_col = math.max((start_col0 or 0) + 1, 1)
  local raw_len = math.max((end_col0 or start_col0 or 0) - (start_col0 or 0), 0)
  local visual_len = math.max(raw_len, 1)
  local end_col = start_col + visual_len - 1

  if #text == 0 then
    return {
      left = "",
      match = match_text,
      replacement = replacement,
      right = "",
    }
  end

  if start_col > #text then
    start_col = #text
    end_col = #text
  end

  local from = math.max(1, start_col - 18)
  local to = math.min(#text, end_col + 22)

  local left = text:sub(from, start_col - 1)
  local shown_match = match_text ~= "" and match_text or text:sub(start_col, end_col)
  local right = text:sub(end_col + 1, to)

  if from > 1 then
    left = "..." .. left
  end
  if to < #text then
    right = right .. "..."
  end

  return {
    left = utils.shorten(left, 40),
    match = utils.shorten(shown_match, 30),
    replacement = replacement,
    right = utils.shorten(right, 40),
  }
end

function M.parse_rg_output(stdout, cwd, replacement)
  local files = {}

  for line in (stdout .. "\n"):gmatch("(.-)\n") do
    if line ~= "" then
      local ok, event = pcall(vim.json.decode, line)
      if ok and event and event.type == "match" and event.data then
        local data = event.data
        local rel_path = data.path and data.path.text or nil
        local line_text = data.lines and data.lines.text or ""
        line_text = line_text:gsub("\r?\n$", "")
        local lnum = tonumber(data.line_number) or 1

        if rel_path and data.submatches then
          local abs_path = utils.normalize_path(cwd, rel_path)

          if not files[abs_path] then
            files[abs_path] = {
              path = abs_path,
              rel_path = rel_path,
              matches = {},
            }
          end

          for _, submatch in ipairs(data.submatches) do
            local start_col0 = tonumber(submatch.start) or 0
            local end_col0 = tonumber(submatch["end"]) or start_col0
            local raw_match_text = (submatch.match and submatch.match.text) or ""
            local preview = M.build_preview_parts(line_text, start_col0, end_col0, raw_match_text, replacement)
            table.insert(files[abs_path].matches, {
              type = "match",
              rel_path = rel_path,
              path = abs_path,
              lnum = lnum,
              col = start_col0 + 1,
              start_col0 = start_col0,
              end_col0 = end_col0,
              text = line_text,
              raw_match_text = raw_match_text,
              left = preview.left,
              match_text = preview.match,
              replacement_text = preview.replacement,
              right = preview.right,
            })
          end
        end
      end
    end
  end

  return files
end

function M.apply_preview_parts_to_files(files, replacement_map, fallback_replacement)
  for _, file in pairs(files) do
    for _, match in ipairs(file.matches) do
      local replacement_text = replacement_map and replacement_map[match.raw_match_text]
      if replacement_text == nil then
        replacement_text = fallback_replacement
      end
      local preview = M.build_preview_parts(
        match.text,
        match.start_col0,
        match.end_col0,
        match.raw_match_text,
        replacement_text
      )
      match.left = preview.left
      match.match_text = preview.match
      match.replacement_text = preview.replacement
      match.right = preview.right
    end
  end
end

function M.to_tree_nodes(files, n)
  local nodes = {}
  local paths = {}

  for path in pairs(files) do
    table.insert(paths, path)
  end

  table.sort(paths, function(a, b)
    return files[a].rel_path < files[b].rel_path
  end)

  for _, path in ipairs(paths) do
    local file = files[path]
    local children = {}

    for _, match in ipairs(file.matches) do
      table.insert(children, n.node({
        type = "match",
        path = match.path,
        rel_path = match.rel_path,
        lnum = match.lnum,
        col = match.col,
        start_col0 = match.start_col0,
        end_col0 = match.end_col0,
        raw_match_text = match.raw_match_text,
        left = match.left,
        match_text = match.match_text,
        replacement_text = match.replacement_text,
        right = match.right,
      }))
    end

    local first = file.matches[1]
    local icon, icon_hl = M.get_file_icon(file.rel_path)
    local file_node = n.node({
      type = "file",
      path = file.path,
      rel_path = file.rel_path,
      lnum = first and first.lnum or 1,
      col = first and first.col or 1,
      icon = icon,
      icon_hl = icon_hl,
      text = string.format("%s (%d)", file.rel_path, #file.matches),
    }, children)
    file_node:expand()
    table.insert(nodes, file_node)
  end

  return nodes
end

return M
