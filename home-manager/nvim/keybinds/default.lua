-- binds to switch windows
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', { desc = 'Move focus to the upper window' })

-- bind to exit the terminal
vim.keymap.set('t', '<ESC>',  '<C-\\><C-n>',  {noremap = true})

-- bind telescope hotspots
vim.keymap.set('n', '<C-t>', ':Telescope find_files<CR>', { desc = 'Find files in current location'})

vim.keymap.set({"n", "i", "v"}, "<F2>", '<cmd>lua require("renamer").rename()<cr>', { desc = 'Renames a symbol through the LSP'})
