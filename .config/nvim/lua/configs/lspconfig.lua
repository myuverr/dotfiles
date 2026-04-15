require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "ts_ls",
  "lua_ls",
  "pyright",
  "jsonls",
  "yamlls",
  "bashls",
  "gopls",
  "rust_analyzer",
  "texlab",
  "fish_lsp",
}

-- enable servers with default config
vim.lsp.enable(servers)

-- custom clangd config
local configs = vim.lsp.config
if not configs.clangd then
  configs.clangd = {}
end

configs.clangd.cmd = {
  "clangd",
  "--background-index",
  "--clang-tidy",
  "--header-insertion=iwyu",
  "--completion-style=detailed",
  "--function-arg-placeholders",
  "--fallback-style=Google",
}
configs.clangd.init_options = {
  usePlaceholders = true,
  completeUnimported = true,
  clangdFileStatus = true,
}

vim.lsp.enable("clangd")
