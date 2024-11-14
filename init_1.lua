vim.opt.mouse = ''
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.ignorecase = true -- ignore case in general for searches and stuff
vim.opt.smartcase = true -- if you type a capital letter start caring about case
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.list = false
vim.opt.listchars = { space = '·', tab = '→ ', eol = '↲' }
vim.opt.fillchars = { eob = ' ' }
vim.opt.gdefault = true  -- this means have /g on every substitute by default. including /g then does the opposite

vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

vim.keymap.set('i', 'kj', '<Esc>')
vim.keymap.set('i', 'jk', '<Esc>')

vim.keymap.set('n', '<leader>rw', ':Ex<Enter>')

vim.keymap.set('n', '<leader>c', 'gcc', { remap = true }) -- normally remap is true but vim has explicitly disabled this for the gcc mapping
vim.keymap.set('v', '<leader>c', 'gc', { remap = true })

vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>y', '"+yy')

vim.keymap.set('n', '<leader>w', function() vim.opt.list = not vim.opt.list:get() end)

vim.keymap.set('n', '<leader>i', '~h')  -- tilde moves the cursor forward by one so h moves it back
vim.keymap.set('v', '<leader>i', '~')

vim.keymap.set('n', 'vie', 'ggVG')
vim.keymap.set('n', 'yie', 'ggVGy')
vim.keymap.set('n', 'die', 'ggVGd')
vim.keymap.set('n', 'cie', 'ggVGc')

vim.keymap.set('v', '<leader>lk', '<Esc>') -- can remap to <C-c> instead of <Esc> if terminal is intercepting <Esc>
vim.keymap.set('v', '<leader>kl', '<Esc>') -- need to use <leader> here to avoid delay on k or l (important keys!)

-- this makes it so that I can close the help by just pressing q instead of :q<Enter>
vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'help', 'checkhealth' },
        callback = function()
                vim.keymap.set('n', 'q', ':q<Enter>', { buffer = true })
        end
})

function CustomK()
        -- idea: keep building this out with more INFO! (possibly use pydoc? idk exactly what vim.buf.hover() does)
        -- I think :normal! K just calls :h on the word under your cursor but I'm not sure
        -- this should also work in visual mode!
        if vim.bo.filetype == 'help' then vim.cmd('normal! K') end

        local word = vim.fn.expand('<cword>')

        print(word)

        if pcall(vim.cmd, 'Man ' .. word) then return end
        -- print('man entry for \'' .. word .. '\' not found')
        if pcall(vim.cmd, ':h ' .. word) then return end
        -- print(':h entry for \'' .. word .. '\' not found')
        print('nothing found in man or :h')
end

vim.keymap.set('n', 'K', CustomK)
vim.keymap.set('v', 'K', CustomK)

function testl()
        local t = vim.lsp.get_clients()

        print(vim.inspect(t))
end


-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
        local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
                vim.api.nvim_echo({
                        { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
                        { out, 'WarningMsg' },
                        { '\nPress any key to exit...' },
                }, true, {})
                vim.fn.getchar()
                os.exit(1)
        end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before loading lazy.nvim so that mappings are correct.

require('lazy').setup({
        git = {
                url_format = 'git@github.com:%s.git'
        },
	spec = {
		{
			'williamboman/mason-lspconfig.nvim',
			dependencies = {
				'williamboman/mason.nvim',
				'neovim/nvim-lspconfig'
			},
			config = function()
				require('mason').setup()
				require('mason-lspconfig').setup({
					ensure_installed = {  -- need to be lspconfig names not mason names
						'lua_ls',
						'pyright'
					}
				})

                                require('mason-lspconfig').setup_handlers({
                                --         -- The first entry (without a key) will be the default handler
                                --         -- and will be called for each installed server that doesn't have
                                --         -- a dedicated handler.
                                        function (server_name) -- default handler (optional)
                                                require('lspconfig')[server_name].setup({})

                                                -- vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = true })
                                                -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = true })
                                        end,
                                        ['lua_ls'] = function()
                                                require('lspconfig').lua_ls.setup {
                                                        settings = {
                                                                Lua = {
                                                                        runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
                                                                        diagnostics = { globals = { 'vim' } },
                                                                        workspace = {
                                                                                library = vim.api.nvim_get_runtime_file('', true),
                                                                                checkThirdParty = false,
                                                                        },
                                                                        telemetry = { enable = false },
                                                                },
                                                        },
                                                }
                                        end,
                                })
                        end
		},
                {
                        'nvim-telescope/telescope.nvim', tag = '0.1.8',
                        dependencies = { 'nvim-lua/plenary.nvim' },
                        config = function()
                                local builtin = require('telescope.builtin')

                                vim.keymap.set('n', '<leader>ts', builtin.find_files, { desc = 'Telescope find files' })
                                vim.keymap.set('n', '<leader>ta', builtin.live_grep, { desc = 'Telescope live grep' })
                                vim.keymap.set('n', '<leader>tb', builtin.buffers, { desc = 'Telescope buffers' })
                                vim.keymap.set('n', '<leader>td', builtin.help_tags, { desc = 'Telescope help tags' })
                        end
                }
	},
        -- Configure any other settings here. See the documentation for more details.
        -- colorscheme that will be used when installing plugins.
        install = { colorscheme = { 'default' } },
        -- automatically check for plugin updates
        checker = { enabled = true },
})

vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
                local buffer_number = args.buf
                local opts = { noremap = true, silent = true, buffer = buffer_number }

                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        end,
})


-- local lspconfig = require('lspconfig')
-- lspconfig.pyright.setup({
--         cmd = { 'npx', '--prefix', '~/lsp', 'pyright-langserver', '--stdio' },
-- })

-- vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })




-- LSP STUFF

-- local lspconfig = require('lspconfig')

-- lspconfig['pyright'].setup({
--         cmd = { 'npx', '--prefix', '~/lsp', 'pyright-langserver', '--stdio' },
--         filetypes = { 'python' },
--         root_dir = vim.fn.getcwd()
-- })

-- vim.lsp.start({
--         name = 'pyright',
--         cmd = { 'npx', '--prefix', 'home/elifast/lsp', 'pyright-langserver', '--stdio' },
--         root_dir = vim.fn.getcwd(),
--         settings = {
--                 python = {
--                         analysis = {
--                                 autoSearchPaths = true,
--                                 diagnosticMode = "openFilesOnly",
--                                 useLibraryCodeForTypes = true
--                         }
--                 }
--         }
-- })

-- vim.lsp.buf_attach_client(0, 1)  -- 0 is id of current buffer


-- print(vim.fn.getcwd())
-- print(type(vim.fn.getcwd()))





-- local function get_client(name, cmd)
--         for _, client in ipairs(vim.lsp.get_clients()) do
--                 if client.name == name then
--                         return client.id
--                 end
--         end
--
--         return vim.lsp.start_client({  -- returns client_id of the client 
--                 cmd = cmd or { 'npx', '--prefix', '~/lsp', 'pyright-langserver', '--stdio' },
--                 -- root_dir = '/home/elifast/lsp',
--                 -- workspace_folders = { '/home/elifast/lsp' },
--                 -- workspace_folders = {
--                 --         {
--                 --                 uri = vim.uri_from_fname('/home/elifast/lsp'),
--                 --                 name = 'lsp'
--                 --         }
--                 -- },
--                 name = name,
--                 -- capabilities = vim.lsp.protocol.make_client_capabilities(),
--         })
-- end
--
-- vim.api.nvim_create_autocmd('filetype', {
--         pattern = 'python',
--         callback = function()
--                 vim.lsp.buf_attach_client(0, get_client('python'))  -- 0 is id of current buffer
--                 vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = true })
--                 vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = true })
--         end,
-- })


-- vim.lsp.start({
--         name = 'pyright',
--         cmd = { 'npx', '--prefix', 'home/elifast/lsp', 'pyright-langserver', '--stdio' },
--         root_dir = vim.fn.getcwd()
--         -- root_dir = vim.fs.root(0, {'pyrightconfig.json'}),
-- })
--

-- vim.lsp.start({ name = 'pyright', cmd = { 'npx', '--prefix', 'home/elifast/lsp', 'pyright-langserver', '--stdio' }, root_dir = vim.fn.getcwd() })
-- vim.lsp.start({ name = 'pyright', cmd = { 'npx', '--prefix', 'home/elifast/lsp', 'pyright-langserver', '--stdio' } })
-- vim.lsp.start({ name = 'pyright', cmd = { 'pyright-langserver', '--stdio' } })
-- vim.lsp.start({ name = 'html', cmd = { 'npx', '--prefix', '/home/elifast/lsp', 'vscode-html-language-server', '--stdio' }, root_dir = vim.fn.getcwd() })
-- vim.lsp.start({ name = 'html', cmd = { 'npx', '--prefix', '/home/elifast/lsp', 'vscode-html-language-server', '--stdio' }})

-- vim.lsp.set_log_level('debug')



-- 'npx', '--prefix', '~/lsp', 'pyright-langserver', '--stdio'







-- function t()
--         vim.lsp.buf_request(0, "textDocument/hover", vim.lsp.util.make_position_params(), function(_, result, ctx, _)
--                 if result then
--                         vim.lsp.handlers["textDocument/hover"](nil, result, ctx)
--                 else
--                         print("No hover information available")
--                 end
--         end)
-- end


-- vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
--         vim.lsp.handlers.hover, {
--                 -- Use a sharp border with `FloatBorder` highlights
--                 border = "single",
--                 -- add the title in hover float window
--                 title = "hover"
--         }
-- )

