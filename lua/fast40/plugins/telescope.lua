return {
	'nvim-telescope/telescope.nvim', tag = '0.1.2',
-- or                                  , branch = '0.1.x',
	dependencies = {
		'nvim-lua/plenary.nvim'
	},
	config = function()
		local builtin = require('telescope.builtin')

		vim.keymap.set('n', '<leader>ts', builtin.find_files, {})
	end
}
