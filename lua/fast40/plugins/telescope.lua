return {
	'nvim-telescope/telescope.nvim', tag = '0.1.2',
	-- or                                  , branch = '0.1.x',
	dependencies = {
		'nvim-lua/plenary.nvim'
	},
	config = function()
		require('telescope').setup {
			defaults = {
                                sorting_strategy = "ascending",  -- this is to try to fix annoying telescope issue where it works but doesn't display the current selection often, especially when the current selection is the only available option

                                -- note: it (value of "descending") doesn't seem to work
                                -- I'm switching it to ascending which supposedly works
                                -- this is the issue I'm trying to fix: https://github.com/nvim-telescope/telescope.nvim/issues/2667
				file_ignore_patterns = {'venv'},
                                mappings = {  -- add the following mappings under the find_files picker
                                        i = {  -- specify the mode for which the mappings apply
                                                ["kl"] = "close",
                                                ["lk"] = "close",
                                        },
                                        n = {
                                                ["kl"] = "close",
                                                ["lk"] = "close",
                                        },
                                },
			},
		-- 	pickers = {  -- add customization for specific pickers (telescope's name for main ui windows I think)
		-- 		find_files = {  -- customize the find_files picker (there are other pickers; see :h telescope.builtin)
		-- 			mappings = {  -- add the following mappings under the find_files picker
		-- 				i = {  -- specify the mode for which the mappings apply
		-- 					["kl"] = "close",
		-- 					["lk"] = "close",
		-- 				},
		-- 				n = {
		-- 					["kl"] = "close",
		-- 					["lk"] = "close",
		-- 				},
		-- 			}
		-- 		}
		-- 	}
		}

		local builtin = require('telescope.builtin')

		vim.keymap.set('n', '<leader>ts', builtin.find_files, {})
                vim.keymap.set('n', '<leader>td', builtin.treesitter, {})
                vim.keymap.set('n', '<leader>ta', builtin.live_grep, {})
                vim.keymap.set('n', '<leader>tj', builtin.grep_string, {})
	end
}
