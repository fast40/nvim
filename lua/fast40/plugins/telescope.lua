return {
	'nvim-telescope/telescope.nvim', tag = '0.1.2',
	-- or                                  , branch = '0.1.x',
	dependencies = {
		'nvim-lua/plenary.nvim'
	},
	config = function()
		require('telescope').setup {
			defaults = {
				file_ignore_patterns = {'venv'}
			},
			pickers = {  -- add customization for specific pickers (telescope's name for main ui windows I think)
				find_files = {  -- customize the find_files picker (there are other pickers; see :h telescope.builtin)
					mappings = {  -- add the following mappings under the find_files picker
						i = {  -- specify the mode for which the mappings apply
							["kl"] = "close",
							["lk"] = "close",
						},
						n = {
							["kl"] = "close",
							["lk"] = "close",
						},
					}
				}
			}
		}

		local builtin = require('telescope.builtin')

		vim.keymap.set('n', '<leader>ts', builtin.find_files, {})
	end
}
