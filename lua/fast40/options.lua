vim.g.mapleader = ' '

vim.keymap.set('i', 'kj', '<Esc>')  -- rhs can either be a string or a lua function
vim.keymap.set('i', 'jk', '<Esc>')

vim.keymap.set('n', '<leader>rw', vim.cmd.Ex)

vim.o.mouse = ''
vim.o.number = true  -- somehow this also works with vim.wo (w for window)
vim.o.relativenumber = true  -- this too
vim.o.cursorline = true

vim.opt.tabstop = 8
vim.opt.list = false  -- can be toggled later
-- vim.cmd[[
--     augroup EnableListInInsertMode
--         autocmd!
--         autocmd InsertEnter * set list
--         autocmd InsertLeave * set nolist
--     augroup END
-- ]]
vim.opt.listchars = {
	space = '·',
	tab = '→ ',
	eol = '↲'
}

-- vim.opt.guicursor = ''  -- make the cursor always a block

vim.keymap.set('n', 'vie', 'ggVG')
vim.keymap.set('n', 'die', 'ggVGd')

function insert_date()
	-- vim.fn.setline('.', vim.fn.getline('.') .. 'test')
	vim.api.nvim_feedkeys('o' .. os.date("%Y-%m-%d"), 'n', true)  -- third parameter is bool whether or not to escape_csi (e.g. convert <Esc> into escape key)
end

function toggle_whitespace_rendering()
	vim.opt.list = not vim.opt.list:get()
end

function toggle_line_numbers()
	vim.o.number = not vim.o.number
	vim.o.relativenumber = not vim.o.relativenumber
end

vim.keymap.set('n', '<leader>j', insert_date)
vim.keymap.set('n', '<leader>w', toggle_whitespace_rendering)
vim.keymap.set('n', '<leader>n', toggle_line_numbers)

