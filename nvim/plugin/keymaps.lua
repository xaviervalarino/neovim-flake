local map = vim.keymap.set
-- local opts = { noremap = true, silent = true }

map('n', '[d', vim.diagnostic.goto_prev, { desc = 'go to previous [d]iagnostic message' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'go to next [d]iagnostic message' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'show diagnostic [e]rror messages' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'open diagnostic [q]uickfix list' })
