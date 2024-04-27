return {
	'hrsh7th/nvim-cmp',
	dependencies = {
		'hrsh7th/cmp-nvim-lsp', -- lsp source for nvim-cmp (I guess nvim-cmp needs sources for things)
		'saadparwaiz1/cmp_luasnip', -- snippets source for nvim-cmp
		'L3MON4D3/LuaSnip', -- manage snippets (not sure about this yet)
		'williamboman/mason.nvim', -- this is to install language servers
		'williamboman/mason-lspconfig.nvim', -- not sure why nvim-lspcongfig doesn't just work with mason
		'neovim/nvim-lspconfig', -- used for configuring language servers and keybindings and all that
	},
	config = function()
		require('luasnip.loaders.from_vscode').lazy_load()

		require('mason').setup() -- need to set this up first, then mason-lspconfig, then lspconfig
		require('mason-lspconfig').setup() -- this allows neovim's lspconfig to work with mason as normal

		local cmp = require('cmp')

		cmp.setup({
			snippet = {
				expand = function(args)
					require('luasnip').lsp_expand(args.body) -- uses language server protocol to integrate everything
				end,
			},
			window = {
				-- completion = cmp.config.window.bordered(),
				-- documentation = cmp.config.window.bordered(),
			},
			mapping = cmp.mapping.preset.insert({
				['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
				['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
				['<C-b>'] = cmp.mapping.scroll_docs(-4),
				['<C-f>'] = cmp.mapping.scroll_docs(4),
				['<C-Space>'] = cmp.mapping.complete(),
				['<C-e>'] = cmp.mapping.abort(),
				['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
			}),
			sources = cmp.config.sources({
				{ name = 'nvim_lsp' }, -- I believe this says to use the default neovim lsp
				{ name = 'luasnip' }, -- snippet stuff; luasnip integrates with cmp using lsp
			}, {
				{ name = 'buffer' }, -- not sure why this is seperate from the rest
			})
		})

		-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
		--
		-- require('lspconfig')['pyright'].setup {
		-- 	capabilities = capabilities
		-- }
	end
}
