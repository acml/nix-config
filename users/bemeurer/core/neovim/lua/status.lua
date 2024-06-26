local lualine = require("lualine")
local lsp_progress = require("lsp-progress")

local sections = {
  diagnostics = {
    "diagnostics",
    sources = { "nvim_lsp" },
    symbols = { error = " ", warn = " ", info = " ", hint = " " },
  },
  diff = {
    "diff",
    symbols = { added = " ", modified = "柳 ", removed = " " },
  },
  filename = {
    "filename",
    symbols = {
      modified = "●",
      readonly = "🔒",
      unnamed = "[No Name]",
      newfile = "[New]",
    },
  },
  filetype = {
    "filetype",
    icon_only = true,
  },
}

lsp_progress.setup({})
lualine.setup({
  options = {
    theme = "ayu_dark",
    section_separators = "",
    component_separators = "",
  },
  extensions = {
    "quickfix",
    "trouble",
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { sections.filetype, sections.filename, "navic" },
    lualine_c = { sections.diagnostics, lsp_progress.progress },
    lualine_x = { "searchcount", sections.diff, "branch" },
    lualine_y = { "encoding", "fileformat" },
    lualine_z = { "location", "progress" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { sections.filetype, sections.filename },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
})

-- listen lsp-progress event and refresh lualine
vim.api.nvim_create_augroup("lualine_augroup", { clear = true })
vim.api.nvim_create_autocmd("User", {
  group = "lualine_augroup",
  pattern = "LspProgressStatusUpdated",
  callback = require("lualine").refresh,
})
