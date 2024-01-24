return {
	'tpope/vim-commentary',
	config = function()
		vim.keymap.set('n', '<leader>d', '<Plug>CommentaryLine')
		vim.keymap.set('x', '<leader>d', '<Plug>Commentary')
	end
}
