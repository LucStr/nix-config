require("conform").setup({
    formatters_by_ft = {
        cs = { "csharpier_server" },
    },
    format_on_save = {
        timeout_ms = 3000,
        lsp_fallback = true,
    },
    formatters = {
        csharpier_server = {
            command = "csharpier-server-format",
            args = { "$FILENAME" },
            stdin = true,
        },
    },
})
