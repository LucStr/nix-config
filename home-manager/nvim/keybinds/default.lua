vim.g.mapleader=";"

-- binds to switch windows

-- Disable default mappings from vim-tmux-navigator
--vim.g.tmux_navigator_no_mappings = 1
-- Custom mappings for tmux navigation
vim.keymap.set('n', 'af', '<cmd>TmuxNavigateLeft<CR>', { silent = true, desc = 'Move focus to the left tmux pane' })
--vim.keymap.set('n', '<C-h>', '<cmd>TmuxNavigateLeft<CR>', { silent = true, desc = 'Move focus to the left tmux pane' })
--vim.keymap.set('n', '<C-j>', '<cmd>TmuxNavigateDown<CR>', { silent = true, desc = 'Move focus to the lower tmux pane' })
--vim.keymap.set('n', '<C-k>', '<cmd>TmuxNavigateUp<CR>', { silent = true, desc = 'Move focus to the upper tmux pane' })
--vim.keymap.set('n', '<C-l>', '<cmd>TmuxNavigateRight<CR>', { silent = true, desc = 'Move focus to the right tmux pane' })
--vim.keymap.set('n', '<C-\\>', '<cmd>TmuxNavigatePrevious<CR>', { silent = true, desc = 'Move focus to the previously used tmux pane' })

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

