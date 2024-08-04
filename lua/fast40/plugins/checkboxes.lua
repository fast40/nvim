-- I want to re-write this plugin myself to learn how to write plugins

return {
	'opdavies/toggle-checkbox.nvim',
	config = function()
                vim.keymap.set('n', '<leader>tc', require('toggle-checkbox').toggle)
	end
}
