return {
        'hrsh7th/nvim-cmp',
        dependencies = {
                'hrsh7th/cmp-nvim-lsp', -- lsp source for nvim-cmp (I guess nvim-cmp needs sources for things)
                'hrsh7th/cmp-buffer', -- source for the current buffer
                'hrsh7th/cmp-nvim-lua', -- source for nvim lua; knows to disable itself in inappropriate files
                'saadparwaiz1/cmp_luasnip', -- snippets source for nvim-cmp
                'L3MON4D3/LuaSnip', -- manage snippets (not sure about this yet)
                'williamboman/mason.nvim', -- this is to install language servers
                'williamboman/mason-lspconfig.nvim', -- not sure why nvim-lspcongfig doesn't just work with mason
                'neovim/nvim-lspconfig', -- used for configuring language servers and keybindings and all that

                'rafamadriz/friendly-snippets', -- big collection of nice snippets (need to figure out how this works)
        },
        config = function()
                require('mason').setup() -- need to set this up first, then mason-lspconfig, then lspconfig
                require('mason-lspconfig').setup({
                        ensure_installed = {
                                'pyright',
                                'html',
                                'cssls',
                        }
                }) -- this allows neovim's lspconfig to work with mason as normal
                require('mason-lspconfig').setup_handlers { -- the first entry (without a key) will be the default handler and will be called for each installed server that doesn't have a dedicated handler.
                        function(server_name) -- default handler (optional)
                                require('lspconfig')[server_name].setup {}
                        end,
                        ['html'] = function()
                                -- enable (broadcasting) snippet capability for completion
                                local capabilities = vim.lsp.protocol.make_client_capabilities()
                                capabilities.textDocument.completion.completionItem.snippetSupport = true

                                require('lspconfig').html.setup({
                                        capabilities = capabilities,
                                })
                        end,
                }

                -- luasnip stuff

                require('luasnip.loaders.from_vscode').lazy_load()

                local ls = require('luasnip')

                ls.config.set_config({
                        history = true,
                        updateevents = 'TextChanged, TextChangedI',
                })

                local s = ls.snippet
                local i = ls.insert_node
                local t = ls.text_node

                ls.add_snippets('all', {
                        ls.snippet('flask', {
                                t({
                                        'from flask import Flask, render_template',
                                        '',
                                        'app = Flask(__name__)',
                                        '',
                                        '',
                                        '@app.route(\'/\')',
                                        'def index():',
                                        '\treturn render_template(\'index.html\')',
                                        '',
                                        '',
                                        'if __name__ == \'__main__\':',
                                        '\tapp.run(host=\'0.0.0.0\', port=8000, debug=True)',
                                        ''
                                }),
                        }),
                        ls.snippet('fn', {
                                t('def '),
                                i(1),
                                t('('),
                                i(2),
                                t({ '):', '\t' }),
                                i(3)
                        })
                })

                vim.keymap.set('i', '<c-k>', function() -- TJ DeVries had {'i', 's'} for the mode
                        if ls.expand_or_jumpable() then -- if this is not true, <c-k> simply does nothing
                                ls.expand_or_jump()
                        end
                end, { silent = true })

                vim.keymap.set('i', '<c-j>', function()
                        if ls.jumpable(-1) then -- if you can jump back, do so.
                                ls.jump(-1)
                        end
                end, { silent = true })

                -- cmp stuff

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
                        sources = cmp.config.sources( -- ordering of sources here determines the ordering of completion suggestions (not sure how though)
                        {
                                { name = 'nvim_lsp' }, -- I believe this says to use the default neovim lsp
                                { name = 'nvim_lua' }, -- source for nvim-specific lua functions etc
                                { name = 'luasnip' }, -- snippet stuff; luasnip integrates with cmp using lsp
                        },
                        {
                                { name = 'buffer' }, -- not sure why this is seperate from the rest; keyword_length ensures that suggestions are not shown until that many characters have been entered
                        }
                        )
                })
        end
}
