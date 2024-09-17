vim.g.mapleader=";"

-- binds to switch windows
vim.keymap.set('n', '<C-h>', '<cmd>:TmuxNavigateLeft<cr>', { desc = 'Move focus to the left window or tmux pane' })
vim.keymap.set('n', '<C-j>', '<cmd>:TmuxNavigateDown<cr>', { desc = 'Move focus to the lower window or tmux pane' })
vim.keymap.set('n', '<C-k>', '<cmd>:TmuxNavigateUp<cr>', { desc = 'Move focus to the upper window or tmux pane' })
vim.keymap.set('n', '<C-l>', '<cmd>:TmuxNavigateRight<cr>', { desc = 'Move focus to the right window or tmux pane' })
vim.keymap.set('n', '<C-\\>', '<cmd>:TmuxNavigatePrevious<cr>', { desc = 'Move focus to the previously used tmux pane' })

-- bind to exit the terminal
vim.keymap.set('t', '<ESC>',  '<C-\\><C-n>',  {noremap = true})

-- bind telescope hotspots
vim.keymap.set('n', '<C-t>', '<CMD>lua require("telescope.builtin").lsp_dynamic_workspace_symbols({ symbols = { "Function", "Class" } })<CR>', { desc = 'Find functions and classes in current workspace'})

vim.keymap.set({"n", "i", "v"}, "<F2>", '<cmd>lua require("renamer").rename()<cr>', { desc = 'Renames a symbol through the LSP'})

vim.keymap.set({"i", "n"}, "<M-CR>", '<cmd>lua require("actions-preview").code_actions()<CR>', { desc = 'Get code action suggestions' })
vim.keymap.set({"i", "n"}, "<F12>", '<cmd>lua vim.lsp.buf.definition()<CR>', { desc = 'Go to the defintion' })
vim.keymap.set({"i", "n"}, "<C-F12>", '<cmd>lua vim.lsp.buf.implementation()<CR>', { desc = 'Go to the implementation' })

vim.keymap.set("n", "sd", '<cmd>:Telescope lsp_document_symbols<CR>', { desc = 'Search all symbols in the document' })
vim.keymap.set("n", "sf", '<cmd>:Telescope live_grep<CR>', { desc = 'Search all files' })
vim.keymap.set("n", "sr", '<cmd>:Telescope lsp_references<CR>', { desc = 'Search all references' })

vim.keymap.set("n", "ff", '<cmd>:lua vim.lsp.buf.format({})<CR>', { desc = 'Search all references' })

