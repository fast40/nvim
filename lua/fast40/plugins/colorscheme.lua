return {
	'ellisonleao/gruvbox.nvim',
	config = function()
		require('gruvbox').setup({
			contrast = "hard",
			palette_overrides = {
				dark0_hard = "#ff0000", -- does not apply when transparent_mode is true
				dark1 = "#101010"
			},
			transparent_mode = true
		})

		vim.cmd.colorscheme('gruvbox')
	end
}
