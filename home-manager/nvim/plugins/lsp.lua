-- LSP configuration using vim.lsp.config (nvim 0.11+)

vim.diagnostic.config({
  virtual_text = true,
  float = { border = "rounded" },
})

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

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("roslyn").setup({
    exe = { "Microsoft.CodeAnalysis.LanguageServer" },
    filewatching = "off",  -- Disabled due to inotify limits on large solutions
    broad_search = true,
    lock_target = true,
    config = {
        capabilities = capabilities,
        settings = {
            ["csharp|background_analysis"] = {
                dotnet_analyzer_diagnostics_scope = "fullSolution",
                dotnet_compiler_diagnostics_scope = "fullSolution",
            },
            ["csharp|code_style|formatting"] = {
                dotnet_enable_editor_config_support = true,
            },
        },
    },
})

