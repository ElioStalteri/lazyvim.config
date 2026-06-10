local M = {}

function M.setup()
  vim.api.nvim_set_hl(0, "SearchPanelBg", { fg = "#f8f8f0", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "SearchPanelResultsBg", { fg = "#f8f8f0", bg = "#171712" })
  vim.api.nvim_set_hl(0, "SearchPanelStatus", { fg = "#8f908a", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "SearchPanelHelp", { fg = "#7f837d", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "SearchPanelBorder", { fg = "#4d5154", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "SearchPanelHeader", { fg = "#9ca0a4", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "SearchPanelErrorBorder", { fg = "#6b2c3b", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "SearchPanelErrorHeader", { fg = "#e95678", bg = "#1a1a18" })
  vim.api.nvim_set_hl(0, "SearchPanelErrorText", { fg = "#f3c7d2", bg = "#22171b" })
  vim.api.nvim_set_hl(0, "SearchPanelArrow", { fg = "#8f908a" })
  vim.api.nvim_set_hl(0, "SearchPanelFile", { fg = "#9ca0a4" })
  vim.api.nvim_set_hl(0, "SearchPanelCursorLine", { bg = "#40403a" })
  vim.api.nvim_set_hl(0, "SearchPanelMatch", { fg = "#f8f8f0", bg = "#4a0f23" })
  vim.api.nvim_set_hl(0, "SearchPanelReplace", { fg = "#f8f8f0", bg = "#5c8014" })
  vim.api.nvim_set_hl(0, "SearchPanelPreviewFocus", { fg = "#f8f8f0", bg = "#56791a", nocombine = true })
end

return M
