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

local roslyn_lightweight_settings = {
    ["csharp|background_analysis"] = {
        dotnet_analyzer_diagnostics_scope = "openFiles",
        dotnet_compiler_diagnostics_scope = "openFiles",
    },
    ["csharp|code_lens"] = {
        dotnet_enable_references_code_lens = false,
        dotnet_enable_tests_code_lens = false,
    },
    ["csharp|symbol_search"] = {
        dotnet_search_reference_assemblies = false,
    },
    ["csharp|completion"] = {
        dotnet_show_completion_items_from_unimported_namespaces = false,
        dotnet_provide_regex_completions = false,
    },
    ["csharp|inlay_hints"] = {
        csharp_enable_inlay_hints_for_types = false,
        dotnet_enable_inlay_hints_for_parameters = false,
    },
    ["csharp|code_style|formatting"] = {
        dotnet_enable_editor_config_support = true,
    },
}

local roslyn_full_settings = {
    ["csharp|background_analysis"] = {
        dotnet_analyzer_diagnostics_scope = "fullSolution",
        dotnet_compiler_diagnostics_scope = "fullSolution",
    },
    ["csharp|code_lens"] = {
        dotnet_enable_references_code_lens = true,
        dotnet_enable_tests_code_lens = true,
    },
    ["csharp|symbol_search"] = {
        dotnet_search_reference_assemblies = true,
    },
    ["csharp|completion"] = {
        dotnet_show_completion_items_from_unimported_namespaces = true,
        dotnet_provide_regex_completions = true,
    },
    ["csharp|inlay_hints"] = {
        csharp_enable_inlay_hints_for_types = true,
        dotnet_enable_inlay_hints_for_parameters = true,
    },
    ["csharp|code_style|formatting"] = {
        dotnet_enable_editor_config_support = true,
    },
}

local function roslyn_notify_settings(settings)
    local clients = vim.lsp.get_clients({ name = "roslyn" })
    if #clients == 0 then
        vim.notify("Roslyn LSP client not found", vim.log.levels.WARN)
        return
    end
    for _, client in ipairs(clients) do
        client:notify("workspace/didChangeConfiguration", { settings = settings })
    end
end

vim.api.nvim_create_user_command("RoslynFullSolution", function()
    roslyn_notify_settings(roslyn_full_settings)
    vim.notify("Roslyn: switched to full solution analysis")
end, {})

vim.api.nvim_create_user_command("RoslynLightweight", function()
    roslyn_notify_settings(roslyn_lightweight_settings)
    vim.notify("Roslyn: switched to open files only")
end, {})

-- LSP-level settings (capabilities, diagnostics scope, code lens, etc.)
vim.lsp.config("roslyn", {
    capabilities = capabilities,
    settings = roslyn_lightweight_settings,
})

-- Plugin-level config only (filewatching, target selection, etc.)
require("roslyn").setup({
    filewatching = "off",
})

