require('smart-splits').setup({
  at_edge = 'stop',  -- don't wrap around edges
})

-- Navigation (Ctrl + hjkl)
vim.keymap.set('n', '<C-h>', require('smart-splits').move_cursor_left, { desc = 'Move to left pane' })
vim.keymap.set('n', '<C-j>', require('smart-splits').move_cursor_down, { desc = 'Move to lower pane' })
vim.keymap.set('n', '<C-k>', require('smart-splits').move_cursor_up, { desc = 'Move to upper pane' })
vim.keymap.set('n', '<C-l>', require('smart-splits').move_cursor_right, { desc = 'Move to right pane' })

-- Resizing (Alt + hjkl)
vim.keymap.set('n', '<M-h>', require('smart-splits').resize_left, { desc = 'Resize left' })
vim.keymap.set('n', '<M-j>', require('smart-splits').resize_down, { desc = 'Resize down' })
vim.keymap.set('n', '<M-k>', require('smart-splits').resize_up, { desc = 'Resize up' })
vim.keymap.set('n', '<M-l>', require('smart-splits').resize_right, { desc = 'Resize right' })

-- Splitting (Alt + s/v)
vim.keymap.set('n', '<M-s>', '<cmd>split<CR>', { desc = 'Split below' })
vim.keymap.set('n', '<M-v>', '<cmd>vsplit<CR>', { desc = 'Split right' })

-- Swap buffers (Alt + Shift + hjkl)
vim.keymap.set('n', '<M-H>', require('smart-splits').swap_buf_left, { desc = 'Swap buffer left' })
vim.keymap.set('n', '<M-J>', require('smart-splits').swap_buf_down, { desc = 'Swap buffer down' })
vim.keymap.set('n', '<M-K>', require('smart-splits').swap_buf_up, { desc = 'Swap buffer up' })
vim.keymap.set('n', '<M-L>', require('smart-splits').swap_buf_right, { desc = 'Swap buffer right' })

-- Close window (Alt + x)
vim.keymap.set('n', '<M-x>', '<cmd>close<CR>', { desc = 'Close window' })
