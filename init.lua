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

vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'help', 'checkhealth' },
        callback = function()
                vim.keymap.set('n', 'q', ':q<Enter>', { buffer = true })
        end
})

function CustomK()
        if vim.bo.filetype == 'help' then vim.cmd('normal! K') end

        local word = vim.fn.expand('<cword>')

        if pcall(vim.cmd, 'Man ' .. word) then return end
        if pcall(vim.cmd, ':h ' .. word) then return end
        print('nothing found in man or :h')
end

vim.keymap.set('n', 'K', CustomK)
vim.keymap.set('v', 'K', CustomK) -- I think this doesn't work properly yet

function ToggleDarkMode()
        vim.o.background = (vim.o.background == 'light') and 'dark' or 'light'
end

vim.keymap.set('n', '<leader>b', ToggleDarkMode)

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
                                        function (server_name) -- default handler (optional)
                                                require('lspconfig')[server_name].setup({})
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
                                require('telescope').setup({
                                        defaults = {
                                                file_ignore_patterns = {'venv'},
                                                mappings = {
                                                        i = {
                                                                ['kl'] = 'close',
                                                                ['lk'] = 'close',
                                                        },
                                                        n = {
                                                                ['kl'] = 'close',
                                                                ['lk'] = 'close',
                                                        },
                                                },
                                        },
                                })
                                local builtin = require('telescope.builtin')

                                vim.keymap.set('n', '<leader>ts', builtin.find_files, { desc = 'Telescope find files' })
                                vim.keymap.set('n', '<leader>ta', builtin.live_grep, { desc = 'Telescope live grep' })
                                vim.keymap.set('n', '<leader>tb', builtin.buffers, { desc = 'Telescope buffers' })
                                vim.keymap.set('n', '<leader>td', builtin.help_tags, { desc = 'Telescope help tags' })
                                vim.keymap.set('n', '<leader>tj', builtin.colorscheme) -- add descriptions to search for in telescope (builtin.builtin)
                                vim.keymap.set('n', '<leader>tr', builtin.lsp_references)
                                vim.keymap.set('n', '<leader>ti', builtin.lsp_implementations)
                                vim.keymap.set('n', '<leader>tc', builtin.commands)
                                vim.keymap.set('n', '<leader>tp', builtin.planets)
                                vim.keymap.set('n', '<leader>tt', builtin.builtin)
                        end
                },
                {
                        'mbbill/undotree',
                        config = function()
                                vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
                                vim.g.undotree_SetFocusWhenToggle = 1 -- sets focus to undo tree when it's opened
                        end
                }
        },
        install = { colorscheme = { 'default' } }, -- colorscheme that will be used when installing plugins.
        checker = { enabled = true }, -- automatically check for plugin updates
})

vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
                local buffer_number = args.buf
                local opts = { noremap = true, silent = true, buffer = buffer_number }

                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

                vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, opts)
        end,
})

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = 'double', -- 'rounded', 'single', 'double', 'solid', etc.
})
