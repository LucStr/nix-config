-- LSP configuration using vim.lsp.config (nvim 0.11+)

vim.lsp.config.rust_analyzer = {
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = false,
      }
    }
  }
}

vim.lsp.config.pyright = {}
vim.lsp.config.nil_ls = {}
vim.lsp.config.phpactor = {}

vim.lsp.enable({'rust_analyzer', 'pyright', 'nil_ls', 'phpactor'})

require("roslyn").setup({
    config = {},
    exe = {
        "Microsoft.CodeAnalysis.LanguageServer"
    },
    filewatching = true,
})
