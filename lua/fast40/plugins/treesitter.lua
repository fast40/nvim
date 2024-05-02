return {
	'nvim-treesitter/nvim-treesitter',
	build = ':TSUpdate',
        -- dependencies = {
        --         'windwp/nvim-ts-autotag'
        -- },
	config = function()
		require('nvim-treesitter.configs').setup {
			ensure_installed = {
				'c',
				'cpp',
				'python',
				'html',
				'css',
				'javascript',
				'lua',
				'vim',
				'vimdoc'
			},
                        autotag = {
                                enable = true,
                        },

			-- Automatically install missing parsers when entering buffer
			-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
			auto_install = true,
			highlight = {
				enable = true,
			}
		}
	end
}
