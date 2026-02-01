vim.g.mapleader=";"

-- bind to exit the terminal
vim.keymap.set('t', '<ESC>',  '<C-\\><C-n>',  {noremap = true})

-- bind telescope hotspots
vim.keymap.set('n', '<C-t>', '<CMD>lua require("telescope.builtin").lsp_dynamic_workspace_symbols()<CR>', { desc = 'Find symbols in workspace'})

vim.keymap.set({"n", "i", "v"}, "<F2>", '<cmd>lua require("renamer").rename()<cr>', { desc = 'Renames a symbol through the LSP'})

vim.keymap.set({"i", "n"}, "<M-CR>", '<cmd>lua require("actions-preview").code_actions()<CR>', { desc = 'Get code action suggestions' })
vim.keymap.set({"i", "n"}, "<F12>", '<cmd>lua vim.lsp.buf.definition()<CR>', { desc = 'Go to the defintion' })
vim.keymap.set({"i", "n"}, "<C-F12>", '<cmd>lua vim.lsp.buf.implementation()<CR>', { desc = 'Go to the implementation' })

vim.keymap.set("n", "sd", '<cmd>:Telescope lsp_document_symbols<CR>', { desc = 'Search all symbols in the document' })
vim.keymap.set("n", "sf", '<cmd>:Telescope live_grep<CR>', { desc = 'Search all files' })
vim.keymap.set("n", "sr", '<cmd>:Telescope lsp_references<CR>', { desc = 'Search all references' })

vim.keymap.set("n", "ff", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, { desc = 'Format buffer' })

-- Diagnostics
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = 'Show diagnostic message' })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })

-- Trouble (tree view for quickfix/diagnostics)
vim.keymap.set("n", "sq", '<cmd>Trouble qflist toggle<CR>', { desc = 'Quickfix in tree view' })
vim.keymap.set("n", "se", '<cmd>Trouble diagnostics toggle<CR>', { desc = 'Diagnostics in tree view' })
