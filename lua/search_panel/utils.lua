local M = {}

function M.shorten(str, max_len)
  if #str <= max_len then
    return str
  end

  return str:sub(1, max_len - 3) .. "..."
end

function M.trim(str)
  return ((str or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

function M.normalize_path(cwd, path)
  if path:sub(1, 1) == "/" then
    return path
  end

  return cwd .. "/" .. path
end

function M.parse_include_globs(include_value)
  local value = M.trim(include_value or "")
  local globs = {}

  if value == "" then
    return globs
  end

  for token in value:gmatch("[^,]+") do
    local part = M.trim(token)
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

return M
