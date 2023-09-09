vim.g.mapleader = ' '

vim.keymap.set('i', 'kj', '<Esc>')  -- rhs can either be a string or a lua function
vim.keymap.set('i', 'jk', '<Esc>')

vim.keymap.set('n', '<leader>rw', vim.cmd.Ex)

-- vim.keymap.set('n', 'vie', 'ggVG')
