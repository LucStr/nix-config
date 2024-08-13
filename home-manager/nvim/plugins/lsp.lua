require'lspconfig'.rust_analyzer.setup{
    settings = {
      ['rust-analyzer'] = {
        diagnostics = {
          enable = false;
        }
      }
    }
  }

require'lspconfig'.pyright.setup{}
