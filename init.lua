vim.opt.mouse = ''
vim.opt.number = true
vim.opt.expandtab = true
-- vim.opt.tabstop = 2
-- vim.opt.shiftwidth = 2
vim.opt.ignorecase = true -- ignore case in general for searches and stuff
vim.opt.smartcase = true -- if you type a capital letter start caring about case
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.list = false
vim.opt.listchars = { space = '·', tab = '→ ', eol = '↲' }
vim.opt.fillchars = { eob = ' ' }
vim.opt.gdefault = true  -- this means have /g on every substitute by default. including /g then does the opposite
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.showbreak = '>'

vim.diagnostic.config({ virtual_text = true })
vim.keymap.set('n', 'gK', function()
        local new_config = not vim.diagnostic.config().virtual_lines
        vim.diagnostic.config({ virtual_lines = new_config })
end, { desc = 'Toggle diagnostic virtual_lines' })

vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

vim.keymap.set('i', 'kj', '<Esc>')
vim.keymap.set('i', 'jk', '<Esc>')

vim.keymap.set('i', '\\date', ':echo hi<Enter>')

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

vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end)
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end)

vim.keymap.set('v', '<leader>lk', '<Esc>') -- can remap to <C-c> instead of <Esc> if terminal is intercepting <Esc>
vim.keymap.set('v', '<leader>kl', '<Esc>') -- need to use <leader> here to avoid delay on k or l (important keys!)

vim.keymap.set('n', '<leader>pl', ':Lazy<Enter>')
vim.keymap.set('n', '<leader>pm', ':Mason<Enter>')

vim.api.nvim_set_keymap('i', '<C-Space>', '<C-x><C-o>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('i', '<C-Space>', '<Cmd>lua vim.lsp.buf.completion()<CR>', { noremap = true, silent = true })


vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*',
    callback = function()
        vim.bo.formatoptions = 'tcqj'
    end,
}) -- look back into this

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
        local lazyrepo = 'git@github.com:folke/lazy.nvim.git'
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
                        'williamboman/mason.nvim',
                        dependencies = {
                                'williamboman/mason-lspconfig.nvim',
                                'neovim/nvim-lspconfig',
                                'mason-org/mason-registry'
                        },
                        config = function()
                                require('mason').setup()
                                require('mason-lspconfig').setup({
                                        ensure_installed = {  -- need to be lspconfig names not mason names
                                                'lua_ls',
                                                'pyright',
                                                'clangd'
                                        }
                                })
                                require('mason-lspconfig').setup_handlers({
                                        function (server_name) -- default handler (optional)
                                                require('lspconfig')[server_name].setup({})
                                                vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
                                        end,
                                        ['lua_ls'] = function()
                                                require('lspconfig').lua_ls.setup {
                                                        settings = {
                                                                Lua = {
                                                                        runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
                                                                        diagnostics = { globals = { 'vim' } },
                                                                        workspace = {
                                                                                library = {
                                                                                        vim.fn.stdpath('data') .. '/lazy',
                                                                                        unpack(vim.api.nvim_get_runtime_file('', true))
                                                                                },
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
                },
                {
                        'ThePrimeagen/harpoon',
                        dependencies = {
                                'nvim-lua/plenary.nvim'
                        },
                        config = function()
                                local mark = require('harpoon.mark')
                                local ui = require('harpoon.ui')

                                vim.keymap.set('n', '<leader>ha', mark.add_file)
                                vim.keymap.set('n', '<leader>ht', ui.toggle_quick_menu)

                                vim.keymap.set('n', '<leader>a', function() ui.nav_file(1) end)
                                vim.keymap.set('n', '<leader>s', function() ui.nav_file(2) end)
                                vim.keymap.set('n', '<leader>d', function() ui.nav_file(3) end)
                                vim.keymap.set('n', '<leader>f', function() ui.nav_file(4) end)
                        end
                },
                {
                        'hrsh7th/nvim-cmp',
                        dependencies = {
                                'hrsh7th/cmp-nvim-lsp',
                                'hrsh7th/cmp-buffer',
                                'hrsh7th/cmp-path', -- filesystem paths
                        },
                        config = function()
                                local cmp = require('cmp')

                                cmp.setup({
                                        mapping = cmp.mapping.preset.insert({
                                                -- ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                                                -- ['<C-f>'] = cmp.mapping.scroll_docs(4),
                                                -- ['<C-Space>'] = cmp.mapping.complete(),
                                                ['<Esc>'] = cmp.mapping.abort(),
                                                ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                                        }),
                                        sources = cmp.config.sources(
                                                {
                                                        { name = 'nvim_lsp' },
                                                        { name = 'path' },
                                                        { name = 'buffer' }
                                                        -- { name = 'vsnip' }, -- For vsnip users.
                                                        -- { name = 'luasnip' }, -- For luasnip users.
                                                        -- { name = 'ultisnips' }, -- For ultisnips users.
                                                        -- { name = 'snippy' }, -- For snippy users.
                                                }
                                        )
                                })
                        end
                }
        },
        install = { colorscheme = { 'default' } }, -- colorscheme that will be used when installing plugins.
        checker = { enabled = true, notify = false }, -- automatically check for plugin updates
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

vim.filetype.add({
        extension = {
                pt1 = function()
                        vim.bo.filetype = 'prompttool1'
                        vim.bo.commentstring='// %s'
                end,
        },
})

function LLM()
        -- '< and '> marks are not obviously better than v and . here because they aren't set until you exit visual mode. You exit and re-select but that's a bit aids
        local _, srow, scol, _ = unpack(vim.fn.getpos('v'))
        local _, erow, ecol, _ = unpack(vim.fn.getpos('.'))

        if (srow > erow) or (srow == erow and scol > ecol) then
                srow, erow = erow, srow
                scol, ecol = ecol, scol
        end

        local lines = vim.api.nvim_buf_get_text(0, srow - 1, scol - 1, erow - 1, ecol, {})
        print(table.concat(lines, "\n"))


        -- local _, srow, scol, _ = unpack(vim.fn.getpos("'<"))
        -- local _, erow, ecol, _ = unpack(vim.fn.getpos("'>"))
        --
        -- print('start:', srow, scol, 'end:', erow, ecol)
        --
        -- local lines = vim.api.nvim_buf_get_text(0, srow - 1, scol - 1, erow - 1, ecol, {})
        --
        -- local text = table.concat(lines, '\n')
        --
        -- print(text)
        -- local selection_start_pos = vim.fn.getpos('v')
        -- local cursor_pos = vim.fn.getpos('.')
        --
        -- -- vim.fn.getpos returns 0-indexed columns (so the first char in a row is col 0)
        -- -- but 1-indexed rows (so the first line is line 1).
        -- -- vim.api.nvim_buf_get_text expects zero indexed everything, so we need to 
        -- -- make the rows 0-indexed by subtracting one
        -- local _, row1, col1 = selection_start_pos[2]
        -- local col1 = selection_start_pos[3]
        --
        -- local row2 = cursor_pos[2]
        -- local col2 = cursor_pos[3]

        -- print('visual start: line', srow, 'char', scol, '\ncursor pos: line', erow, 'char', ecol)

        -- vim.api.nvim_buf_get_text expects 0 indexed everything, is inclusive of all row
        -- values (so lines), and is exclusive of the ending col value (so last char in
        -- last row is excluded by default and we want to include it which is the reason
        -- for col2 + 1)
        -- local lines = vim.api.nvim_buf_get_text(0, row1 - 1, col1 - 1, row2 - 1, col2, {})

        -- vim.api.nvim_buf_get_text returns a list of lines, so we need to concatenate them
        -- together to get the text
        -- local text = table.concat(lines, '\n')
        --
        -- print(text)


        -- vim.system({'curl', '-N', 'http://api.open-notify.org/iss-now.json'}, { text = true }, function (obj) print(obj.stdout) end)
        -- vim.system({'curl', '-N', 'http://api.open-notify.org/iss-now.json'}, {
        --         stdout = function(_, data)
        --                 if data then
        --                         print('longitude: ' .. vim.json.decode(data).iss_position.longitude .. '\nlatitude: ' .. vim.json.decode(data).iss_position.latitude)
        --                 end
        --         end
        -- })
end

vim.keymap.set('v', '<leader>gl', LLM)
