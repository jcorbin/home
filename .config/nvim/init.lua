local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt

local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim' -- {{{
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path})
end
local paq = require('paq')
-- }}}

paq { -- {{{
	"savq/paq-nvim";

	"rcarriga/nvim-notify";
	"echasnovski/mini.nvim";

	"nvim-lua/plenary.nvim";
	"nvim-telescope/telescope.nvim";

	"nvim-treesitter/nvim-treesitter";
	"neovim/nvim-lspconfig";

  "hrsh7th/cmp-nvim-lsp";
  "hrsh7th/cmp-buffer";
  "hrsh7th/cmp-path";
  "hrsh7th/cmp-cmdline";
  "hrsh7th/nvim-cmp";

  'hrsh7th/cmp-vsnip';
  'hrsh7th/vim-vsnip';

  -- " For luasnip users.
  -- " 'L3MON4D3/LuaSnip';
  -- " 'saadparwaiz1/cmp_luasnip';

	"rafcamlet/nvim-luapad";

	"fatih/vim-go";
	"tpope/vim-fugitive";

} -- }}}

local keymap = vim.keymap

-- prettier toast-style notifications {{{
require('notify').setup {
	stages = 'slide',
	render = 'minimal',
	timeout = 3000,
}
vim.notify = require('notify');
-- }}}

local notify = vim.notify;

-- set mapleader early so that it applies to all mappings defined
g.mapleader = ' '

-- init.lua iteration {{{
keymap.set('n', '<leader>ev', ':vsplit $MYVIMRC<cr>')
keymap.set('n', '<leader>sv', function()
	dofile(fn.stdpath('config') .. '/init.lua')
	notify('Reloaded init.lua')
end)
-- }}}

-- startify/dashboard "mini" alternative {{{
require('mini.starter').setup {}
require('mini.sessions').setup {
	autoread = true,
}

keymap.set('n', '<leader>:', MiniStarter.open)
-- TODO session management mappings

-- }}}

-- "mini" alternative to statusline and tabline plugins {{{
require('mini.statusline').setup {}
require('mini.tabline').setup {
	show_icons = false,
}
-- }}}

require('mini.comment').setup {}
require('mini.jump').setup {}
require('mini.pairs').setup {}
require('mini.surround').setup {}
require('mini.fuzzy').setup {}

-- line exchange mappings ; TODO mini.exchange is a planned module {{{
keymap.set('n', '[e', ':move--<cr>') -- TODO repeatable
keymap.set('n', ']e', ':move+<cr>') -- TODO repeatable
-- }}}

require('mini.trailspace').setup {} -- {{{
keymap.set('n', '<leader>ts', MiniTrailspace.trim)
-- }}}

require('nvim-treesitter.configs').setup { -- {{{
	ensure_installed = 'all',
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	incremental_selection = {
		enable = true,
		keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
	},
	textobjects = { enable = true },
	indent = { enable = true },
} -- }}}

vim.diagnostic.config { -- {{{
	signs = true,
	virtual_text = true,
	underline = true,
	float = {
		source = 'if_many',
	},
}

keymap.set('n', '<leader>dg', vim.diagnostic.open_float) -- }}}

-- LSP capabilities to pass around
-- ... currently just to enable LSP snippet completion
-- ... but left here since it may prove to be more general
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Auto completion framework {{{
local cmp = require('cmp')

cmp.setup {

	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'vsnip' }, -- For vsnip users.
		-- { name = 'luasnip' }, -- For luasnip users.
		-- { name = 'snippy' }, -- For snippy users.
		-- { name = 'ultisnips' }, -- For ultisnips users.
	}, {
		{ name = 'buffer' },
	}),

	mapping = {
		['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
		['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
		['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
		['<C-e>'] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		['<CR>'] = cmp.mapping.confirm({ select = true }),

		-- ['<C-s>'] = cmp.mapping.complete({ sources = { { name = 'vsnip' } } })
		-- inoremap <C-S> <Cmd>lua require('cmp').complete({ sources = { { name = 'vsnip' } } })<CR>

	},

	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
			-- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
			-- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
			-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
		end,
	},

	-- completion.autocomplete
	experimental = {
		ghost_text = true,
	},

	-- TODO can se use mini.fuzzy?
	-- sorting.comparators~
	--   `(fun(entry1: cmp.Entry, entry2: cmp.Entry): boolean | nil)`

}

-- `/` cmdline setup.
cmp.setup.cmdline('/', {
	sources = {
		{ name = 'buffer' }
	}
})

-- `:` cmdline setup.
cmp.setup.cmdline(':', {
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	})
})

capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Let tab key advance completion items
keymap.set('i', '<Tab>', function()
	return fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end, { expr = true })

-- }}}

require('telescope').setup { -- {{{
	defaults = {
		generic_sorter = require('mini.fuzzy').get_telescope_sorter
	},
}

keymap.set('n', '<leader>tt', ':Telescope<cr>')

local telescopes = require('telescope.builtin')
keymap.set('n', '<leader>ff', telescopes.find_files)
keymap.set('n', '<leader>gr', telescopes.live_grep)
keymap.set('n', '<leader>bs', telescopes.buffers)
keymap.set('n', '<leader>??', telescopes.help_tags)

-- }}}

-- LUA Langauge Server {{{
local sumneko_binary = vim.env.HOME .. '/.local/lua-language-server/bin/macOS/lua-language-server'
local sumneko_path = vim.split(package.path, ';')
table.insert(sumneko_path, "lua/?.lua")
table.insert(sumneko_path, "lua/?/init.lua")
require'lspconfig'.sumneko_lua.setup {
  cmd = {sumneko_binary};
	capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
				-- Tell the language server which version of Lua you're using (most
				-- likely LuaJIT in the case of Neovim)
				version = 'LuaJIT',
        -- Setup your lua path
        path = sumneko_path,
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
} -- }}}

-- TODO typescript lang server

-- TODO folke/trouble.nvim

-- TODO glepnir/lspsaga.nvim
-- TODO jose-elias-alvarez/null-ls.nvim

-- TODO kyazdani42/nvim-tree.lua vs lambdalisue/fern.vim

-- TODO lewis6991/gitsigns.nvim
-- TODO TimUntersberger/neogit

-- TODO mfussenegger/nvim-dap

-- TODO more from https://github.com/rockerBOO/awesome-neovim

-- TODO snippets
-- TODO term support: float, quake, etc
-- TODO tab detection

-- TODO vinegar like mappings for netrw, or a replacement above

-- colorscheme {{{

-- TODO maybe break out into nvim/colors/mine.lua

local base16 = require('mini.base16')

local minibg = '#101018'
local minifg = '#a0a8b0'
local minihi = 66

local function recolor(options)
	if options ~= nil then
		if options.bg ~= nil then minibg = options.bg end
		if options.fg ~= nil then minifg = options.fg end
		if options.hi ~= nil then minihi = options.hi end
	end
	opt.termguicolors = true
	if opt.background:get() == 'light' then
		base16.setup { palette = base16.mini_palette(minifg, minibg, minihi) }
	else
		base16.setup { palette = base16.mini_palette(minibg, minifg, minihi) }
	end
end

keymap.set('n', '<leader>hi', function()
	vim.ui.input({
		prompt = 'Accent Color Chroma: ',
		default = tostring(minihi),
	}, function(input)
		local hi = tonumber(input)
		if hi == nil or hi < 0 or hi > 100 then
			notify('Invalid chroma, expected number in range 0-100', 'error')
		else
			recolor {hi = hi}
			notify('Set accent color chroma=' .. tostring(minihi))
		end
	end)
end)

keymap.set('n', '<leader>bg', function()
	vim.ui.input({
		prompt = 'Background Color: ',
		default = minibg,
	}, function(input)
		if input ~= nil then
			recolor {bg = input}
			notify('Set background color=' .. minibg)
		end
	end)
end)

keymap.set('n', '<leader>fg', function()
	vim.ui.input({
		prompt = 'Foreground Color: ',
		default = minifg,
	}, function(input)
		if input ~= nil then
			recolor {fg = input}
			notify('Set foreground color=' .. minifg)
		end
	end)
end)

keymap.set('n', '<leader>li', function()
	if opt.background:get() == 'light' then
		opt.background = 'dark'
	else
		opt.background = 'light'
	end
	recolor()
end)

recolor()

-- g.colors_name = 'mine'

-- }}}

-- Options {{{

opt.mouse = 'a'
opt.scrolloff = 2

opt.incsearch = true
opt.smartcase = true

opt.virtualedit = 'all'

opt.laststatus = 3

opt.guifont = 'JetBrains Mono ExtraLight:h12'

-- TODO listchars
-- opt.listchars = {
-- eol = '↲',
-- tab = '▸ ',
-- trail = '·',
-- extends
-- precedes
-- conceal
-- nbsp
-- }

opt.completeopt = {'menu', 'menuone', 'noselect'}

-- TODO audit old vimrc for more
-- TODO swap dir

-- }}}

-- option toggles {{{

local function option_toggler(name)
	return function()
		if opt[name]:get() then
			opt[name] = false
			vim.notify('set no' .. name)
		else
			opt[name] = true
			vim.notify('set ' .. name)
		end
	end
end

keymap.set('n', '<leader>ci', option_toggler 'ignorecase')
keymap.set('n', '<leader>ln', option_toggler 'number')
keymap.set('n', '<leader>rc', option_toggler 'relativenumber')
keymap.set('n', '<leader>cl', option_toggler 'cursorline')
keymap.set('n', '<leader>cc', option_toggler 'cursorcolumn')
keymap.set('n', '<leader>lw', option_toggler 'wrap')
-- TODO other toggles ala unimpaired

-- }}}

-- vim: set ts=2 sw=2 foldmethod=marker:
