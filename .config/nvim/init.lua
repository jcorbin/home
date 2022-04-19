-- local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt

local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim' -- {{{
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ 'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path })
end
local paq = require('paq')
-- }}}

paq { -- {{{
  "savq/paq-nvim";

  "rcarriga/nvim-notify";
  "echasnovski/mini.nvim";

  "nvim-lua/plenary.nvim";
  "nvim-telescope/telescope.nvim";

  { "nvim-treesitter/nvim-treesitter",
    run = function() vim.cmd('TSUpdate') end };
  "nvim-treesitter/nvim-treesitter-textobjects";
  "nvim-treesitter/nvim-treesitter-refactor";
  "romgrk/nvim-treesitter-context";
  -- maybe "theHamsta/nvim-treesitter-pairs";
  "lewis6991/spellsitter.nvim";

  "mfussenegger/nvim-ts-hint-textobject";

  "neovim/nvim-lspconfig";
  'folke/lsp-colors.nvim';

  "hrsh7th/cmp-nvim-lsp";
  "hrsh7th/cmp-buffer";
  "hrsh7th/cmp-path";
  -- "hrsh7th/cmp-cmdline";
  "hrsh7th/nvim-cmp";

  'folke/trouble.nvim';

  'hrsh7th/cmp-vsnip';
  'hrsh7th/vim-vsnip';

  'jcorbin/neovim-termhide';

  -- " For luasnip users.
  -- " 'L3MON4D3/LuaSnip';
  -- " 'saadparwaiz1/cmp_luasnip';

  "rafcamlet/nvim-luapad";

  "fatih/vim-go";
  "tpope/vim-fugitive";

  -- file browsing
  'justinmk/vim-dirvish';
  'kristijanhusak/vim-dirvish-git';
  -- TODO maybe 'tpope/vim-eunuch' or a lua replacement

} -- }}}

local keymap = vim.keymap
g.mapleader = ' ' -- set mapleader early so that it applies to all mappings defined

local function cmd_fn(cmd_str)
  return function() vim.cmd(cmd_str) end
end

local function map_pair(mode, base, prev, next)
  keymap.set(mode, base .. '[', prev)
  keymap.set(mode, base .. ']', next)
end

-- termhide {{{

g.termhide_default_shell = 'zsh'
g.termhide_hud_size = 15

-- Create or show existing terminal buffer
keymap.set('n', '<leader>$', cmd_fn 'Term')
keymap.set('n', '<leader>#', cmd_fn 'TermVSplit')

-- Easy HUD toggle
keymap.set('n', '<leader>`', cmd_fn 'TermHUD')

-- Quicker 'Go Back' binding
-- tnoremap <C-\><C-o> <C-\><C-n><C-o>

-- Quicker window operations
keymap.set('t', '<C-\\>`', cmd_fn 'close')

keymap.set('t', '<C-\\><C-w>', '<C-\\><C-n><C-w><C-w>')
keymap.set('t', '<C-\\><C-h>', '<C-\\><C-n><C-w>h')
keymap.set('t', '<C-\\><C-j>', '<C-\\><C-n><C-w>j')
keymap.set('t', '<C-\\><C-k>', '<C-\\><C-n><C-w>k')
keymap.set('t', '<C-\\><C-l>', '<C-\\><C-n><C-w>l')

-- Easy 'paste inside terminal' map
keymap.set('t', '<C-\\>p', '<C-\\><C-n>pi')

-- }}}

-- prettier toast-style notifications {{{
require('notify').setup {
  stages = 'slide',
  render = 'minimal',
  timeout = 3000,
}
vim.notify = require('notify');
-- }}}

local notify = vim.notify;

-- fugitive keymaps {{{
keymap.set('n', '<leader>gg', ':G<cr>')
keymap.set('n', '<leader>gd', ':Gdiff<cr>')
keymap.set('n', '<leader>ga', ':G add %<cr>')
keymap.set('n', '<leader>gA', ':G add --update<cr>')
keymap.set('n', '<leader>gr', ':G reset<cr>')
keymap.set('n', '<leader>gb', ':G blame<cr>')
keymap.set('n', '<leader>gc', ':G commit<cr>')
keymap.set('n', '<leader>gC', ':G commit --amend<cr>')
keymap.set('n', '<leader>go',
  -- TODO implement a function that avoids clobbering the default register
  'yaw:Gsplit <C-r>"<cr>')
-- }}}

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

keymap.set('n', '<leader>ss', function()
  vim.ui.input({
    prompt = 'write new session named: ',
    -- default = TODO basename of cwd
  }, function(session_name)
    if session_name ~= nil then
      MiniSessions.write(session_name)
    end
  end)
end)

keymap.set('n', '<leader>sc', function()
  MiniSessions.select('read')
end)

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
-- require('mini.pairs').setup {}
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
  indent = { enable = true },

  textobjects = {

    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },

    lsp_interop = {
      enable = true,
      border = 'none',
      peek_definition_code = {
        ["<leader>df"] = "@function.outer",
        ["<leader>dF"] = "@class.outer",
      },
    },

    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },

    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = "@parameter.inner",
      },
      swap_previous = {
        ["<leader>A"] = "@parameter.inner",
      },
    },

  },

  refactor = {

    highlight_definitions = {
      enable = true,
      -- Set to false if you have an `updatetime` of ~100.
      clear_on_cursor_move = true,
    },

    highlight_current_scope = {
      enable = false,
    },

    smart_rename = {
      enable = true,
      keymaps = {
        smart_rename = "grr",
      },
    },

    navigation = {
      enable = true,
      keymaps = {
        goto_definition = "gnd",
        list_definitions = "gnD",
        list_definitions_toc = "gO",
        goto_next_usage = "<a-*>",
        goto_previous_usage = "<a-#>",
      },
    },

  },

}

opt.foldmethod = 'expr'
opt.foldexpr = 'nvim_treesitter#foldexpr()'

require 'treesitter-context'.setup {
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  throttle = true, -- Throttles plugin updates (may improve performance)
  max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
  patterns = { -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
    -- For all filetypes
    -- Note that setting an entry here replaces all other patterns for this entry.
    -- By setting the 'default' entry below, you can control which nodes you want to
    -- appear in the context window.
    default = {
      'class',
      'function',
      'method',
      'for',
      'while',
      'if',
      'switch',
      'case',
    },
    -- Example for a specific filetype.
    -- If a pattern is missing, *open a PR* so everyone can benefit.
    --   rust = {
    --       'impl_item',
    --   },
  },
  exact_patterns = {
    -- Example for a specific filetype with Lua patterns
    -- Treat patterns.rust as a Lua pattern (i.e "^impl_item$" will
    -- exactly match "impl_item" only)
    -- rust = true,
  }
}

require('spellsitter').setup {
  -- Whether enabled, can be a list of filetypes, e.g. {'python', 'lua'}
  enable = true,
}

keymap.set({ 'o', 'v' }, 'm', require('tsht').nodes, { silent = true })

-- }}}

vim.diagnostic.config { -- {{{
  signs = true,
  virtual_text = true,
  underline = true,
  float = {
    source = 'if_many',
  },
}

keymap.set('n', '<leader>dg', vim.diagnostic.open_float) -- }}}

local lsp = vim.lsp
local lspconfig = require 'lspconfig'

-- LSP capabilities to pass around
-- ... currently just to enable LSP snippet completion
-- ... but left here since it may prove to be more general
local capabilities = lsp.protocol.make_client_capabilities()

-- adds missing highlights if the current colorscheme does not support LSP
require 'lsp-colors'.setup {
  Error = "#db4b4b",
  Warning = "#e0af68",
  Information = "#0db9d7",
  Hint = "#10B981"
}

local trouble = require 'trouble' -- {{{
trouble.setup {
  position = "bottom", -- position of the list can be: bottom, top, left, right
  height = 10, -- height of the trouble list when position is top or bottom
  width = 50, -- width of the list when position is left or right
  icons = false, -- use devicons for filenames
  mode = "workspace_diagnostics", -- "workspace_diagnostics", "document_diagnostics", "quickfix", "lsp_references", "loclist"
  -- fold_open = "", -- icon used for open folds
  -- fold_closed = "", -- icon used for closed folds
  fold_open = "*", -- icon used for open folds
  fold_closed = "-", -- icon used for closed folds
  group = true, -- group results by file
  padding = true, -- add an extra new line on top of the list
  action_keys = { -- key mappings for actions in the trouble list
    -- map to {} to remove a mapping, for example:
    -- close = {},
    close = "q", -- close the list
    cancel = "<esc>", -- cancel the preview and get back to your last window / buffer / cursor
    refresh = "r", -- manually refresh
    jump = { "<cr>", "<tab>" }, -- jump to the diagnostic or open / close folds
    open_split = { "<c-x>" }, -- open buffer in new split
    open_vsplit = { "<c-v>" }, -- open buffer in new vsplit
    open_tab = { "<c-t>" }, -- open buffer in new tab
    jump_close = { "o" }, -- jump to the diagnostic and close the list
    toggle_mode = "m", -- toggle between "workspace" and "document" diagnostics mode
    toggle_preview = "P", -- toggle auto_preview
    hover = "K", -- opens a small popup with the full multiline message
    preview = "p", -- preview the diagnostic location
    close_folds = { "zM", "zm" }, -- close all folds
    open_folds = { "zR", "zr" }, -- open all folds
    toggle_fold = { "zA", "za" }, -- toggle fold of current file
    previous = "k", -- preview item
    next = "j" -- next item
  },
  indent_lines = true, -- add an indent guide below the fold icons
  auto_open = false, -- automatically open the list when you have diagnostics
  auto_close = false, -- automatically close the list when you have no diagnostics
  auto_preview = true, -- automatically preview the location of the diagnostic. <esc> to close preview and go back to last window
  auto_fold = false, -- automatically fold a file trouble list at creation
  auto_jump = { "lsp_definitions" }, -- for the given modes, automatically jump if there is only a single result
  signs = {
    -- icons / text used for a diagnostic
    error = "",
    warning = "",
    hint = "",
    information = "",
    other = "﫠"
  },
  use_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
}

keymap.set('n', '<leader>xx', cmd_fn 'TroubleToggle')
keymap.set('n', '<leader>xw', cmd_fn 'TroubleToggle workspace_diagnostics')
keymap.set('n', '<leader>xd', cmd_fn 'TroubleToggle document_diagnostics')

map_pair('n', '<leader>x',
  function() trouble.previous { skip_groups = true, jump = true } end,
  function() trouble.next { skip_groups = true, jump = true } end
)

-- }}}

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

-- -- `/` cmdline setup.
-- cmp.setup.cmdline('/', {
--   sources = {
--     { name = 'buffer' }
--   }
-- })

-- -- `:` cmdline setup.
-- cmp.setup.cmdline(':', {
--   sources = cmp.config.sources({
--     { name = 'path' }
--   }, {
--     { name = 'cmdline' }
--   })
-- })

capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- Let tab key advance completion items
keymap.set('i', '<Tab>', function()
  return fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
end, { expr = true })

-- }}}

local telescope = require 'telescope' -- {{{
local telescopes = require 'telescope.builtin'

telescope.setup {
  defaults = {
    generic_sorter = require('mini.fuzzy').get_telescope_sorter,
    i = { ["<c-t>"] = trouble.open_with_trouble },
    n = { ["<c-t>"] = trouble.open_with_trouble },
  },
}

keymap.set('n', '<leader>tt', ':Telescope<cr>')

keymap.set('n', '<leader>ff', telescopes.find_files)
keymap.set('n', '<leader>gr', telescopes.live_grep)
keymap.set('n', '<leader>bs', telescopes.buffers)
keymap.set('n', '<leader>??', telescopes.help_tags)

-- }}}

-- per-buffer LSP setup {{{
local custom_lsp_attach = function()

  -- hookup omnifunc
  vim.api.nvim_buf_set_option(0, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  keymap.set('n', 'K', lsp.buf.hover)
  keymap.set('n', '<c-]>', lsp.buf.definition)

  -- auto formatting
  -- TODO how do autocmds work... this yield an error at runtime
  -- vim.api.nvim_command [[
  -- augroup LSPAutoFormat
  -- autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 1000)
  -- augroup END
  -- ]]

  -- cursor hold highlighting
  -- TODO how do autocmds work... this yield an error at runtime
  -- vim.api.nvim_command [[
  -- augroup LSPDocHighlight
  -- autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
  -- autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
  -- autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
  -- augroup END
  -- ]]

  -- -- Use LSP as the handler for formatexpr.
  -- --    See `:help formatexpr` for more information.
  -- vim.api.nvim_buf_set_option(0, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

  -- TODO explore usefulness of code lens ala
  -- autocmd BufEnter,CursorHold,InsertLeave <buffer> lua vim.lsp.codelens.refresh()

  -- keymaps to act on code
  keymap.set('n', '<leader>a', lsp.buf.code_action)
  keymap.set('n', '<leader>f', lsp.buf.formatting)
  -- TODO format range/object

  -- TODO other typical LSP keymaps, like:
  -- keymap.set('n', '<leader>gd',    lsp.buf.declaration)
  -- keymap.set('n', '<leader>gD',    lsp.buf.implementation)
  -- keymap.set('n', '<leader>1gD',   lsp.buf.type_definition)
  -- keymap.set('n', '<leader>gR',  lsp.buf.rename)
  -- keymap.set('n', '<leader>gr',  telescopes.lsp_references)
  -- keymap.set('n', '<leader>g0',  telescopes.lsp_document_symbols)
  -- keymap.set('n', '<leader>gW',  telescopes.lsp_workspace_symbols)
  -- keymap.set('n', 'g!', lsp.util.show_line_diagnostics)
  -- nnoremap <silent> <leader>l :LspDocumentDiagnostics<CR>
  -- nnoremap <silent> <leader>r :LspRename<CR>
  -- nnoremap <silent> <leader>e :LspNextError<CR>

  -- For plugins with an `on_attach` callback, call them here. For example:
  -- require('completion').on_attach()

end
-- }}}

-- Langauge Servers {{{

lspconfig.bashls.setup {
  on_attach = custom_lsp_attach,
  capabilities = capabilities,
}

lspconfig.cssls.setup {
  on_attach = custom_lsp_attach,
  capabilities = capabilities,
}

lspconfig.dockerls.setup {
  on_attach = custom_lsp_attach,
  capabilities = capabilities,
}

lspconfig.gopls.setup {
  on_attach = custom_lsp_attach,
  capabilities = capabilities,
}

lspconfig.html.setup {
  on_attach = custom_lsp_attach,
  capabilities = capabilities,
}

lspconfig.jsonls.setup {
  on_attach = custom_lsp_attach,
  capabilities = capabilities,
}

local sumneko_path = vim.split(package.path, ';')
table.insert(sumneko_path, "lua/?.lua")
table.insert(sumneko_path, "lua/?/init.lua")

lspconfig.sumneko_lua.setup {
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
        globals = { 'vim' },
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
  on_attach = custom_lsp_attach,
  capabilities = capabilities,
}

lspconfig.tsserver.setup {
  on_attach = custom_lsp_attach,
  capabilities = capabilities,
}

lspconfig.yamlls.setup {
  on_attach = custom_lsp_attach,
  capabilities = capabilities,
}

lspconfig.vimls.setup {
  on_attach = custom_lsp_attach,
  capabilities = capabilities,
}

-- }}}

-- TODO glepnir/lspsaga.nvim
-- TODO jose-elias-alvarez/null-ls.nvim

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
      recolor { hi = hi }
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
      recolor { bg = input }
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
      recolor { fg = input }
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

opt.shiftwidth = 2
opt.tabstop = 2
opt.expandtab = true

opt.breakindent = true

opt.cursorline = true

opt.mouse = 'a'
opt.scrolloff = 2

opt.incsearch = true
opt.smartcase = true

opt.virtualedit = 'all'

opt.laststatus = 2

opt.updatetime = 250

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

opt.completeopt = { 'menu', 'menuone', 'noselect' }

-- TODO audit old vimrc for more
-- TODO swap dir

-- }}}

-- option toggles {{{

local function map_opt_toggle(keys, name)
  keymap.set('n', keys, function()
    if opt[name]:get() then
      opt[name] = false
      vim.notify('set no' .. name)
    else
      opt[name] = true
      vim.notify('set ' .. name)
    end
  end)
end

map_opt_toggle('<leader>ci', 'ignorecase')
map_opt_toggle('<leader>ln', 'number')
map_opt_toggle('<leader>rc', 'relativenumber')
map_opt_toggle('<leader>cl', 'cursorline')
map_opt_toggle('<leader>cc', 'cursorcolumn')
map_opt_toggle('<leader>lw', 'wrap')

-- }}}

-- vim: set ts=2 sw=2 foldmethod=marker:
