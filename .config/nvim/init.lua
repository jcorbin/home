local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt
local env = vim.env

local bind = function(f, ...)
  local args = { ... }
  return function(...) return f(unpack(args), ...) end
end

local defered = function(callback)
  return function()
    vim.schedule(callback)
  end
end

local install_path = fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim' -- {{{
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ 'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', install_path })
end

require 'paq' {
  "savq/paq-nvim";

  "rcarriga/nvim-notify";
  "echasnovski/mini.nvim";

  "nvim-lua/plenary.nvim";
  "nvim-telescope/telescope.nvim";

  { "nvim-treesitter/nvim-treesitter",
    run = bind(cmd, 'TSUpdate') };
  "nvim-treesitter/nvim-treesitter-textobjects";
  "nvim-treesitter/nvim-treesitter-refactor";
  "romgrk/nvim-treesitter-context";
  -- maybe "theHamsta/nvim-treesitter-pairs";
  "lewis6991/spellsitter.nvim";

  "neovim/nvim-lspconfig";
  'folke/lsp-colors.nvim';

  "hrsh7th/cmp-nvim-lsp";
  "hrsh7th/cmp-buffer";
  "hrsh7th/cmp-path";
  "hrsh7th/cmp-cmdline";
  "hrsh7th/nvim-cmp";
  "hrsh7th/cmp-nvim-lsp-signature-help";
  "hrsh7th/cmp-emoji";
  "ray-x/cmp-treesitter";

  'folke/trouble.nvim';

  'jcorbin/neovim-termhide';

  'L3MON4D3/LuaSnip';
  'saadparwaiz1/cmp_luasnip';

  "rafcamlet/nvim-luapad";

  "fatih/vim-go";
  "tpope/vim-fugitive";

  -- file browsing
  'justinmk/vim-dirvish';
  'kristijanhusak/vim-dirvish-git';
  -- TODO maybe 'tpope/vim-eunuch' or a lua replacement

  'norcalli/nvim-colorizer.lua';

  -- colorschemes
  'rktjmp/lush.nvim';
  'tanvirtin/monokai.nvim';
  'folke/tokyonight.nvim';
  'Mofiqul/vscode.nvim';
  'shaunsingh/moonlight.nvim';

} -- }}}

-- autocmd helper object around lower level vim.api.nvim_create_augroup etc functions
--
-- usage:
--
--   local group = augroup('MyCommands')
--
--   -- pattern defaults to '*' if not given or you can pass it
--   group('BufEnter', do_stuff)
--   group('BufEnter', '*.js', do_stuff)
--
--   -- additional options may be passed thru to vim.api.nvim_create_autocmd
--   group('BufEnter', do_stuff, {desc = 'bla'})
--   group('BufEnter', '*.js', do_stuff, {desc = 'bla'})
--
--   -- can create a buffer-local sub group
--   group('FileType', 'java', function(opts)
--     local group_local = group.buffer(opts.buf)
--     group_local('CursorHoldI', function()
--       vim.notify('Keep Typing! You're getting paid by the character!')
--     end)
--   end)
--
local augroup = function(name)
  local group = vim.api.nvim_create_augroup(name, { clear = true })

  local make

  make = function(fixed_opts)
    return setmetatable({

      buffer = function(bufnr)
        local sub = make(vim.tbl_extend('force', fixed_opts, { buffer = bufnr }))
        sub.clear()
        return sub
      end,

      clear = function(opts)
        vim.api.nvim_clear_autocmds(vim.tbl_extend('force', opts or {}, fixed_opts))
      end,

    }, {
      __call = function(self, ...)
        local event, action, opts

        if fixed_opts.buffer == nil then
          local pattern
          event, pattern, action, opts = ...
          if opts == nil and type(action) == 'table' then
            opts = action
            action = nil
          end
          if action == nil then
            action = pattern
            pattern = '*'
          end
          opts = vim.tbl_extend('force', opts or {}, { pattern = pattern })
        else
          event, action, opts = ...
        end

        opts = vim.tbl_extend('force', opts or {}, fixed_opts)

        if type(action) == 'function' then
          opts.callback = action
        else
          opts.command = action
        end

        return vim.api.nvim_create_autocmd(event, opts)
      end
    })

  end

  return make({ group = group })
end

-- group for ungrouped autocmds so that they are deduped when reloading
local autocmd = augroup('myvimrc-autocmd')

local keymap = vim.keymap

-- use <Space> for mapleader
keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
g.mapleader = ' '
g.maplocalleader = ' '

-- creates a pair of mappings under the [ and ] family
local map_pair = function(mode, key, prev, next)
  keymap.set(mode, '[' .. key, prev)
  keymap.set(mode, ']' .. key, next)
end

-- keymap.set combinator that adds a LHS prefix
local keymap_prefix = function(prefix, mapper)
  if mapper == nil then
    mapper = keymap.set
  end
  return function(mode, key, rhs, opts)
    local lhs = prefix .. key
    mapper(mode, lhs, rhs, opts)
  end
end

-- keymap.set combinator that forces some options
local keymap_options = function(forced_opts, mapper)
  if mapper == nil then
    mapper = keymap.set
  end
  return function(mode, lhs, rhs, opts)
    if opts == nil then
      opts = forced_opts
    else
      opts = vim.tbl_extend('force', opts, forced_opts)
    end
    mapper(mode, lhs, rhs, opts)
  end
end

local map_leader = keymap_prefix '<Leader>'

-- termhide {{{

local tmap = bind(keymap_prefix('<C-\\>'), 't')

g.termhide_default_shell = 'zsh'
g.termhide_hud_size = 15

-- Create or show existing terminal buffer
map_leader('n', '$', bind(cmd, 'Term'))
map_leader('n', '#', bind(cmd, 'TermVSplit'))

-- Easy HUD toggle
map_leader('n', '`', bind(cmd, 'TermHUD'))

-- Quicker 'Go Back' binding
-- tnoremap <C-\><C-o> <C-\><C-n><C-o>

-- Quicker window operations
tmap('`', bind(cmd, 'close'))

tmap('<C-w>', bind(cmd, 'wincmd '))
tmap('<C-h>', bind(cmd, 'wincmd h'))
tmap('<C-j>', bind(cmd, 'wincmd j'))
tmap('<C-k>', bind(cmd, 'wincmd k'))
tmap('<C-l>', bind(cmd, 'wincmd l'))

local paste_from = function(reg)
  vim.api.nvim_paste(vim.fn.getreg(reg), false, -1)
end

tmap('p', bind(paste_from, '"')) -- vim "clipboard"
tmap('p', bind(paste_from, '+')) -- os clipboard

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
map_leader('n', 'Gg', ':G<cr>')
map_leader('n', 'GG', ':G<cr>')
map_leader('n', 'Gd', ':Gdiff<cr>')
map_leader('n', 'Ga', ':G add %<cr>')
map_leader('n', 'GA', ':G add --update<cr>')
map_leader('n', 'Gr', ':G reset<cr>')
map_leader('n', 'Gb', ':G blame<cr>')
map_leader('n', 'Gc', ':G commit<cr>')
map_leader('n', 'GC', ':G commit --amend<cr>')
map_leader('n', 'Go',
  -- TODO implement a function that avoids clobbering the default register
  'yaw:Gsplit <C-r>"<cr>')
-- }}}

-- init.lua iteration {{{

local file_doer = function(path)
  return function()
    dofile(path)
    notify('Reloaded ' .. path)
  end
end

map_leader('n', 'ev', ':vsplit $MYVIMRC<cr>')
map_leader('n', 'sv', file_doer(env.MYVIMRC))

autocmd('BufWritePost', env.MYVIMRC,
  -- defered because sourcing a file inside an autocmd callback seems to work less good
  defered(file_doer(env.MYVIMRC))

-- another option that generalizes, since it takes the path from the autocmd callback
--   function(opts) vim.schedule(file_doer(opts.file)) end

)

-- }}}

-- startify/dashboard "mini" alternative {{{
require('mini.starter').setup {}
require('mini.sessions').setup {
  autoread = true,
}

map_leader('n', 'ss', function()
  vim.ui.input({
    prompt = 'write new session named: ',
    -- default = TODO basename of cwd
  }, function(session_name)
    if session_name ~= nil then
      MiniSessions.write(session_name)
    end
  end)
end)

map_leader('n', 'sc', bind(MiniSessions.select, 'read'))

map_leader('n', ':', MiniStarter.open)
-- TODO session management mappings

-- }}}

-- "mini" alternative to statusline and tabline plugins {{{
require('mini.statusline').setup {}
-- require('mini.tabline').setup {
--   show_icons = false,
-- }
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

-- ex command convenience maps {{{
map_leader({ 'n', 'v' }, 'nn', ':norm ')

map_leader({ 'n', 'v' }, 'gn', ':g\\/ norm ')
map_leader({ 'n', 'v' }, 'vn', ':v\\/ norm ')

map_leader({ 'n', 'v' }, 'mm', ':move ')
map_leader({ 'n', 'v' }, 'gm', ':g\\/ move ')
map_leader({ 'n', 'v' }, 'vm', ':v\\/ move ')

map_leader({ 'n', 'v' }, 'cc', 'copy ')
map_leader({ 'n', 'v' }, 'gc', ':g\\/ copy ')
map_leader({ 'n', 'v' }, 'vc', ':v\\/ copy ')

map_leader({ 'n', 'v' }, 'gd', ':g\\/ delete<cr>')
map_leader({ 'n', 'v' }, 'vd', ':v\\/ delete<cr>')
-- }}}

require('mini.trailspace').setup {} -- {{{
map_leader('n', 'ts', MiniTrailspace.trim)
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
      enable = false,
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

-- }}}

vim.diagnostic.config { -- {{{
  signs = true,
  virtual_text = true,
  underline = true,
  float = {
    source = 'if_many',
  },
}

map_leader('n', 'dg', vim.diagnostic.open_float) -- }}}

local lsp = vim.lsp
local lspconfig = require 'lspconfig'

-- LSP capabilities to pass around
-- ... currently just to enable LSP snippet completion
-- ... but left here since it may prove to be more general
local capabilities = lsp.protocol.make_client_capabilities()

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

map_leader('n', 'xx', bind(cmd, 'TroubleToggle'))
map_leader('n', 'xw', bind(cmd, 'TroubleToggle workspace_diagnostics'))
map_leader('n', 'xd', bind(cmd, 'TroubleToggle document_diagnostics'))

map_pair('n', 'x',
  bind(trouble.previous, { skip_groups = true, jump = true }),
  bind(trouble.next, { skip_groups = true, jump = true }))

map_leader('n', 'e', vim.diagnostic.open_float)

map_pair('n', 'd',
  vim.diagnostic.goto_prev,
  vim.diagnostic.goto_next)

-- }}}

-- Auto completion framework {{{
local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {

  sources = cmp.config.sources({
    { name = 'emoji' },
  }, {
    { name = 'nvim_lsp_signature_help' },
  }, {
    { name = 'nvim_lsp' },
    { name = 'luasnip' }, -- For luasnip users.
  }, {
    { name = 'treesitter' },
    { name = 'buffer' },
  }),

  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),

    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),

    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),

    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expandable() then
        luasnip.expand()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),

    -- ['<C-s>'] = cmp.mapping.complete({ sources = { { name = 'vsnip' } } })
    -- inoremap <C-S> <Cmd>lua require('cmp').complete({ sources = { { name = 'vsnip' } } })<CR>

  },

  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },

  -- completion.autocomplete
  experimental = {
    ghost_text = true,
  },

  view = {
    entries = { name = 'custom', selection_order = 'near_cursor' },
  },

  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },

  -- formatting = {
  --   format = lspkind.cmp_format(),
  -- },

  -- TODO can se use mini.fuzzy?
  -- sorting.comparators~
  --   `(fun(entry1: cmp.Entry, entry2: cmp.Entry): boolean | nil)`

}

-- `/` cmdline setup.
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'treesitter' },
    { name = 'buffer' },
  }
})

-- `:` cmdline setup.
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
  }, {
    { name = 'cmdline' },
  })
})

capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

-- }}}

local telescope = require 'telescope' -- {{{
local telescopes = require 'telescope.builtin'
local teleactions = require 'telescope.actions'

telescope.setup {
  defaults = {
    generic_sorter = require('mini.fuzzy').get_telescope_sorter,
    i = { ["<c-t>"] = trouble.open_with_trouble },
    n = { ["<c-t>"] = trouble.open_with_trouble },
    mappings = {
      i = {
        ["<C-u>"] = false,
        ["<C-h>"] = teleactions.which_key,
        ['<c-d>'] = require('telescope.actions').delete_buffer,
      },
      n = {
        ["<C-h>"] = teleactions.which_key,
        ['<c-d>'] = require('telescope.actions').delete_buffer,
      },
    },
    layout_strategy = 'cursor',
    layout_config = {
      cursor = {
        width = 0.8,
        height = 0.5,
      },
      horizontal = {
        anchor = 'SE',
        width = 0.8,
        height = 0.5,
      },
      vertical = {
        anchor = 'SE',
        width = 0.5,
        height = 0.8,
      },
    },
  },
  pickers = {
    buffers = {
      sort_lastused = true,
      sort_mru = true,
    },
  },
}

map_leader('n', '<Space>', telescopes.buffers)
tmap('<Space>', bind(telescopes.buffers, { ignore_current_buffer = true }))

map_leader('n', 'sf', bind(telescopes.find_files, { previewer = false }))
map_leader('n', 'sb', telescopes.current_buffer_fuzzy_find)
map_leader('n', 'sh', telescopes.help_tags)
map_leader('n', 'st', telescopes.tags)
map_leader('n', 'ss', telescopes.grep_string)
map_leader('n', 'sg', telescopes.live_grep)
map_leader('n', 'so', bind(telescopes.tags, { only_current_buffer = true }))
map_leader('n', '?', telescopes.oldfiles)
map_leader('n', 'sm', telescopes.man_pages)

-- }}}

-- highlight yanks
autocmd('TextYankPost', function() vim.highlight.on_yank { timeout = 500 } end)

-- per-buffer LSP setup {{{
local on_lsp_attach = function(_, bufnr)
  local autocmd_local = autocmd.buffer(bufnr)

  local map_buffer = keymap_options { buffer = bufnr }
  local map_local = keymap_prefix('<LocalLeader>', map_buffer)

  map_buffer('n', 'K', lsp.buf.hover)
  map_buffer('n', '<C-k>', lsp.buf.signature_help)

  -- keymaps to jump
  map_buffer('n', '<c-]>', lsp.buf.definition)
  map_local('n', 'gD', lsp.buf.declaration)
  map_local('n', 'gI', lsp.buf.implementation)
  map_local('n', 'gT', lsp.buf.type_definition)

  -- keymaps to act on code
  map_local('n', 'a', lsp.buf.code_action)
  map_local('n', 'f', lsp.buf.formatting)
  map_local('n', 'gR', lsp.buf.rename)
  -- TODO format range/object

  -- telescope invocations
  map_local('n', 'sr', telescopes.lsp_references)
  map_local('n', 'so', telescopes.lsp_document_symbols)
  map_local('n', 'sw', telescopes.lsp_workspace_symbols)

  -- auto formatting
  autocmd_local('BufWritePre', function()
    lsp.buf.formatting_sync(nil, 1000)
  end)

  -- cursor hold highlighting
  autocmd_local({ 'CursorHold', 'CursorHoldI' }, function()
    lsp.buf.document_highlight()
  end)
  autocmd_local('CursorMoved', function()
    lsp.buf.clear_references()
  end)

  -- -- Use LSP as the handler for formatexpr.
  -- --    See `:help formatexpr` for more information.
  -- vim.api.nvim_buf_set_option(0, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')

  autocmd_local({ 'BufEnter', 'CursorHold', 'InsertLeave' }, function()
    lsp.codelens.refresh()
  end)

end
-- }}}

-- Langauge Servers {{{

local initls = function(name, opts)
  if opts == nil then
    opts = {}
  end
  lspconfig[name].setup(vim.tbl_extend('keep', opts, {
    on_attach = on_lsp_attach,
    capabilities = capabilities,
  }))
end

initls 'bashls'
initls 'cssls'
initls 'dockerls'
initls 'gopls'
initls 'html'
initls 'jsonls'

local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

initls('sumneko_lua', {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most
        -- likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
        -- Setup your lua path
        path = runtime_path,
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
})

initls 'tsserver'
initls 'yamlls'
initls 'vimls'

-- }}}

require 'colorizer'.setup()

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

-- adds missing highlights if the current colorscheme does not support LSP
require 'lsp-colors'.setup {
  Error = "#db4b4b",
  Warning = "#e0af68",
  Information = "#0db9d7",
  Hint = "#10B981"
}

-- NOTE: useful pattern for patching colorschemes
-- autocmd('ColorScheme', 'onedark', function()
--   local h = function(...) vim.api.nvim_set_hl(0, ...) end
--   h('String', {fg = '#FFEB95'})
--   h('TelescopeMatching', {link = 'Boolean'})
-- end)

opt.background = 'dark'

-- require 'monokai'.setup {
--   -- palette = require 'monokai'.pro
--   -- palette = require 'monokai'.soda
--   -- palette = require 'monokai'.ristretto
-- }

g.vscode_style = 'dark'
vim.cmd [[colorscheme vscode]]

-- require 'lush'

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

opt.spell = true -- on by default... {{{
-- ...off by exception
autocmd('FileType', {
  'help',
  'man',
  'startify',
  'godoc',
  'qf',
  'netrw',
  'fugitiveblame',
  'goterm',
  'godebug*',
  'dirvish',
}, 'setlocal nospell')
autocmd('TermOpen', 'setlocal nospell')
-- }}}

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
