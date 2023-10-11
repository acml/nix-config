local nvim_lsp = require("lspconfig")
local coq = require("coq")

local flags = { debounce_text_changes = 150 }

-- navic
require("nvim-navic").setup({ lsp = { auto_attach = true } })

-- support crates and LSP
local function show_documentation()
  local filetype = vim.bo.filetype
  if vim.tbl_contains({ "vim", "help" }, filetype) then
    vim.cmd("h " .. vim.fn.expand("<cword>"))
  elseif vim.tbl_contains({ "man" }, filetype) then
    vim.cmd("Man " .. vim.fn.expand("<cword>"))
  elseif vim.fn.expand("%:t") == "Cargo.toml" and require("crates").popup_available() then
    require("crates").show_popup()
  else
    vim.lsp.buf.hover()
  end
end
vim.keymap.set("n", "K", show_documentation, { silent = true })

-- bindings
local on_attach = function(_, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
  vim.bo[bufnr].formatexpr = "v:lua.vim.lsp.formatexpr()"
  vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"

  -- Buffer local mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local ts_builtin = require("telescope.builtin")
  local opts = { buffer = bufnr, silent = true }

  vim.keymap.set("n", "ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  vim.keymap.set("n", "gd", ts_builtin.lsp_definitions, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", ts_builtin.lsp_implementations, opts)
  vim.keymap.set("n", "<leader>sh", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
  vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
  vim.keymap.set("n", "<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, opts)
  vim.keymap.set("n", "<leader>ws", ts_builtin.lsp_workspace_symbols, opts)
  vim.keymap.set("n", "<leader>D", ts_builtin.lsp_type_definitions, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "gr", ts_builtin.lsp_references, opts)
  vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, opts)
  vim.keymap.set("n", "[d", vim.lsp.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.lsp.diagnostic.goto_next, opts)

  require("nvim-lightbulb").setup({
    autocmd = { enabled = true },
  })
end

-- Enable the following language servers
local servers = { "clangd", "pyright", "texlab", "ruff_lsp" }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup(coq.lsp_ensure_capabilities({ on_attach = on_attach, flags = flags }))
end

nvim_lsp["ltex"].setup(coq.lsp_ensure_capabilities({
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    require("ltex_extra").setup({
      load_langs = { "en-US" },
      init_check = true,
      path = "./.ltex/", -- string : path to store dictionaries. Relative path uses current working directory
      log_level = "none",
    })
  end,
  flags = flags,
}))

nvim_lsp["lua_ls"].setup(coq.lsp_ensure_capabilities({
  on_attach = on_attach,
  flags = flags,
  cmd = { "lua-language-server" },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = {
        enable = false,
      },
    },
  },
}))

nvim_lsp["nil_ls"].setup(coq.lsp_ensure_capabilities({
  on_attach = on_attach,
  flags = flags,
  settings = {
    ["nil"] = {
      formatting = {
        command = { "nixpkgs-fmt" },
      },
    },
  },
}))

require("rust-tools").setup(coq.lsp_ensure_capabilities({
  server = {
    on_attach = on_attach,
    flags = flags,
  },
}))

-- Map :Format to vim.lsp.buf.formatting()
vim.cmd([[ command! Format execute "lua vim.lsp.buf.format({ async = true })" ]])
