local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git', 'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

local bind = function(f, ...)
  local args = { ... }
  return function(...) return f(unpack(args), ...) end
end

-- general ui options
vim.opt.guifont = 'JetBrains Mono:h14'
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.opt.mouse = 'a'

-- neovide gui-specifics
if vim.g.neovide then
  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_cursor_vfx_mode = 'railgun'
  vim.g.neovide_cursor_animation_length = 0.1
  vim.g.neovide_scroll_animation_length = 0.2
  vim.g.neovide_remember_window_size = false
  vim.g.neovide_remember_window_position = false
  vim.g.neovide_scale_factor = 1.0
  local scale_step = 0.05
  vim.keymap.set({ 'n' }, '<C-=>',
    function() vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * (1 + scale_step) end)
  vim.keymap.set({ 'n' }, '<C-->',
    function() vim.g.neovide_scale_factor = vim.g.neovide_scale_factor / (1 + scale_step) end)
  vim.keymap.set({ 'n' }, '<C-0>', function() vim.g.neovide_scale_factor = 1.0 end)
end

-- allow placing cursor in virtual space (past end of line)
vim.opt.virtualedit = 'all'

-- searching
vim.opt.incsearch = true
vim.opt.smartcase = true
vim.keymap.set('n', '<leader>ci',
  function() vim.opt.ignorecase = not vim.opt.ignorecase:get() end,
  { desc = 'toggle search case sensitivity' })

-- use completion popup menu with manual seleection
vim.opt.completeopt = { 'menuone', 'popup', 'noselect' }

-- display 2 lines of context top/bottom when scrolling
vim.opt.scrolloff = 2

-- start out with level 1 folds open
vim.opt.foldlevelstart = 1

-- set for CursorHold purposes
vim.opt.updatetime = 250

-- indent settings and defaults
vim.opt.breakindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true

-- group for ungrouped autocmds so that they are deduped when reloading
local augroup = require 'my.augroup'
local autocmd = augroup 'myvimrc'

-- use <Space> for mapleader
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local mykeymap = require 'my.keymap'

-- easy editing of/around $MYVIMRC
vim.keymap.set('n', '<leader>ev', function()
  vim.cmd.vsplit(vim.env.MYVIMRC)
end, { desc = 'edit $MYVIMRC' })
vim.keymap.set('n', '<leader>ec', function()
  vim.cmd.vsplit(vim.fs.dirname(vim.env.MYVIMRC))
end, { desc = 'edit directory of $MYVIMRC' })

-- auto reload $MYVIMRC after write
autocmd('BufWritePost', vim.env.MYVIMRC, function(opts)
  local path = opts.file
  vim.schedule(function()
    dofile(path)
    vim.notify('Reloaded ' .. path)
  end)
end)

-- context marker motion
local context_marker = [[^\(@@ .* @@\|[<=>|]\{7}[<=>|]\@!\)]]
vim.keymap.set('n', '<leader>[n',
  function() vim.fn.search(context_marker, 'bW') end,
  { desc = 'prev conflict marker' })
vim.keymap.set('n', '<leader>]n',
  function() vim.fn.search(context_marker, 'W') end,
  { desc = 'next conflict marker' })

-- line exchange mappings
vim.keymap.set('n', '[e', '<leader>:move--<cr>')
vim.keymap.set('n', ']e', '<leader>:move+<cr>')

-- marginally quicker path to norm/move/copy a range
-- ... this mapping is barely useful in normal mode fwiw
vim.keymap.set({ 'n', 'v' }, '<leader>nn', ':norm ')
vim.keymap.set({ 'n', 'v' }, '<leader>nn', ':norm ')
vim.keymap.set({ 'n', 'v' }, '<leader>mm', ':move ')
vim.keymap.set({ 'n', 'v' }, '<leader>cc', ':copy ')

-- gre* family mappings that reuse the last search pattern
vim.keymap.set({ 'n', 'v' }, '<leader>gn', [[:g\/ norm ]], { desc = 'gren last search' })
vim.keymap.set({ 'n', 'v' }, '<leader>gm', [[:g\/ move ]], { desc = 'grem last search' })
vim.keymap.set({ 'n', 'v' }, '<leader>gc', [[:g\/ copy ]], { desc = 'grec last search' })
vim.keymap.set({ 'n', 'v' }, '<leader>gd', [[:g\/ delete<cr>]], { desc = 'gred last search' })

-- negative match versions of those
vim.keymap.set({ 'n', 'v' }, '<leader>vn', [[:v\/ norm ]], { desc = 'vren last search' })
vim.keymap.set({ 'n', 'v' }, '<leader>vm', [[:v\/ move ]], { desc = 'vrem last search' })
vim.keymap.set({ 'n', 'v' }, '<leader>vc', [[:v\/ copy ]], { desc = 'vrec last search' })
vim.keymap.set({ 'n', 'v' }, '<leader>vd', [[:v\/ delete<cr>]], { desc = 'vred last search' })

-- line option toggles
vim.keymap.set('n', '<leader>ln',
  function() vim.opt.number = not vim.opt.number:get() end,
  { desc = 'toggle line numbers' })
vim.keymap.set('n', '<leader>lr',
  function() vim.opt.relativenumber = not vim.opt.relativenumber:get() end,
  { desc = 'toggle relative line numbers' })
vim.keymap.set('n', '<leader>lw',
  function() vim.opt.wrap = not vim.opt.wrap:get() end,
  { desc = 'toggle virtual line wrapping' })

-- cursor column/line toggles
vim.opt.cursorline = true
vim.keymap.set('n', '<leader>cl',
  function() vim.opt.cursorline = not vim.opt.cursorline:get() end,
  { desc = 'toggle cursor line highlight' })
vim.keymap.set('n', '<leader>cc',
  function() vim.opt.cursorcolumn = not vim.opt.cursorcolumn:get() end,
  { desc = 'toggle cursor column highlight' })

-- spellchecking
vim.keymap.set('n', '<leader>sp',
  function() vim.opt.spell = not vim.opt.spell:get() end,
  { desc = 'toggle spellchecking' })
vim.opt.spell = true  -- spellchecking on by default...
autocmd('FileType', { -- ...off by exception
  'help',
  'man',
  'startify',
  'godoc',
  'qf',
  'netrw',
  'fugitiveblame',
  'gitrebase',
  'goterm',
  'godebug*',
  'dirvish',
}, 'setlocal nospell')
autocmd('TermOpen', 'setlocal nospell')

-- Easy run in :terminal keymap
vim.keymap.set('n', '<leader>!', ':vsplit | term ')

-- Easy terminal window operations
vim.keymap.set('t', '<C-\\>c', vim.cmd.close, { desc = 'Close buffer' })
vim.keymap.set('t', '<C-\\><C-w>', bind(vim.cmd.wincmd, ''), { desc = 'Last window' })
vim.keymap.set('t', '<C-\\><C-h>', bind(vim.cmd.wincmd, 'h'), { desc = 'Window ←' })
vim.keymap.set('t', '<C-\\><C-j>', bind(vim.cmd.wincmd, 'j'), { desc = 'Window ↓' })
vim.keymap.set('t', '<C-\\><C-k>', bind(vim.cmd.wincmd, 'k'), { desc = 'Window ↑' })
vim.keymap.set('t', '<C-\\><C-l>', bind(vim.cmd.wincmd, 'l'), { desc = 'Window →' })

-- Easy terminal paste operations
vim.keymap.set('t', '<C-\\>p',
  function() vim.api.nvim_paste(vim.fn.getreg('"'), false, -1) end,
  { desc = 'Paste Internal' })
vim.keymap.set('t', '<C-\\>P',
  function() vim.api.nvim_paste(vim.fn.getreg('+'), false, -1) end,
  { desc = 'Paste OS' })

-- diagnostic config and mappings
vim.diagnostic.config {
  signs = true,
  virtual_text = true,
  underline = true,
  float = {
    source = 'if_many',
  },
}

vim.keymap.set('n', '[q', bind(vim.cmd, 'cprev'), { desc = 'Previous error (quickfix)' })
vim.keymap.set('n', ']q', bind(vim.cmd, 'cnext'), { desc = 'Next error (quickfix)' })

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })

-- TODO dedupe diagnostic open mappings
vim.keymap.set('n', '<leader>dg',
  vim.diagnostic.open_float, { desc = 'Open diagnostics float' })

vim.keymap.set('n', '<leader>dh',
  vim.diagnostic.hide, { desc = 'Hide diagnostics' })

vim.keymap.set('n', '<leader>dd',
  function()
    if vim.diagnostic.is_disabled() then
      vim.diagnostic.enable()
    else
      vim.diagnostic.disable()
    end
  end,
  { desc = 'Toggle diagnostics' })

-- highlight yanks
autocmd('TextYankPost', function() vim.highlight.on_yank { timeout = 500 } end)

-- TODO hoist to be nearly first thing after we pull all keymaps and other order-sensitive settings out
require('lazy').setup('plugins')

-- language server setup routine
local lsp_autocmd = augroup 'plugins.lsp'

local function on_lsp_attach(caps, bufnr)
  local lsp = vim.lsp
  local telescopes = require 'telescope.builtin'
  local autocmd_local = lsp_autocmd.buffer(bufnr)
  local map_buffer = mykeymap.options { buffer = bufnr }
  local map_local = mykeymap.prefix('<LocalLeader>', map_buffer)

  map_buffer('n', '<C-k>', lsp.buf.signature_help)

  -- keymaps to jump
  map_buffer('n', '<c-]>', lsp.buf.definition, { desc = 'jump to definition (lsp)' })
  map_local('n', 'gD', lsp.buf.declaration, { desc = 'jump to declaration (lsp)' })
  map_local('n', 'gI', lsp.buf.implementation, { desc = 'jump to implementation (lsp)' })
  map_local('n', 'gT', lsp.buf.type_definition, { desc = 'jump to type definition (lsp)' })

  -- keymaps to act on code
  map_local('n', 'a', lsp.buf.code_action, { desc = 'invoke code action (lsp)' })
  map_local('n', 'gR', lsp.buf.rename, { desc = 'rename symbol (lsp)' })

  -- telescope invocations
  map_local('n', 'sr', telescopes.lsp_references, { desc = 'search lsp references' })
  map_local('n', 'sy', telescopes.lsp_document_symbols, { desc = 'search lsp document symbosl' })
  map_local('n', 'sw', telescopes.lsp_workspace_symbols, { desc = 'search lsp workspace symbols' })

  -- inlay hints (uses virtual text to display parameter names and such)
  lsp.inlay_hint.enable(bufnr, true)
  map_local('n', 'hh',
    function() lsp.inlay_hint.enable(bufnr, not lsp.inlay_hint.is_enabled()) end,
    { desc = 'toggle inlay hints' })

  -- cursor hold highlighting
  if caps['textDocument/documentHighlight'] ~= nil then
    autocmd_local({ 'CursorHold', 'CursorHoldI' }, function()
      lsp.buf.document_highlight()
    end)
    autocmd_local('CursorMoved', function()
      lsp.buf.clear_references()
    end)
  end

  if caps['textDocument/codeLens'] ~= nil then
    autocmd_local({ 'BufEnter', 'CursorHold', 'InsertLeave' }, function()
      lsp.codelens.refresh()
    end)
  end
end

local function setup_lsp(name, opts)
  if opts == nil then
    opts = {}
  end
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  require('lspconfig')[name].setup(vim.tbl_extend('keep', opts, {
    on_attach = on_lsp_attach,
    capabilities = capabilities,
  }))
end

-- setup language servers

setup_lsp 'bashls'

setup_lsp 'cssls'

setup_lsp 'dockerls'

setup_lsp('glslls', {
  cmd = {
    "glslls",
    "--stdin",
    "--target-env", "opengl",
    -- [vulkan vulkan1.0 vulkan1.1 vulkan1.2 vulkan1.3 opengl opengl4.5]
  },
})

setup_lsp 'gopls'

setup_lsp 'html'

setup_lsp 'jsonls'

setup_lsp('lua_ls', {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
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

setup_lsp('openscad_lsp', {
  cmd = { "openscad-lsp", "--stdio", "--fmt-style", "file" },
})

setup_lsp('pylsp', {
  settings = {
    -- https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md
    pylsp = {
      plugins = {
        pycodestyle = {
          ignore = {
            -- NOTE these don't actually work for pylint... what even is the point of pycodestyle?
            'C0114', -- missing-module-docstring
            'C0115', -- missing-class-docstring
            'C0116', -- missing-function-docstring
          },
          maxLineLength = 100
        },
        jedi_completion = {
          fuzzy = true,
          eager = true,
        },

        -- TODO useful or not w/ pycodestyle?
        pylint = {
          enabled = false,
        },

        -- TODO decide on black vs yapf
        black = {
          enabled = false,
          line_length = 100,
        },
        yapf = {
          enabled = true,
        },
      },
    },
  },
})

setup_lsp 'rust_analyzer'
-- https://github.com/rust-analyzer/rust-analyzer/tree/master/docs/user#settings

setup_lsp('tsserver', {
  completions = {
    completeFunctionCalls = true,
  },

  init_options = {
    preferences = {
      includeInlayParameterNameHints = 'all',
      includeInlayParameterNameHintsWhenArgumentMatchesName = false,

      -- works, but too noisy imo
      -- includeInlayFunctionParameterTypeHints = true,

      -- broken
      -- includeInlayFunctionLikeReturnTypeHints = true,
      -- includeInlayVariableTypeHints = true,

      -- untested
      -- includeInlayPropertyDeclarationTypeHints = true,
      -- includeInlayEnumMemberValueHints = true,
      -- importModuleSpecifierPreference = 'non-relative',

    },
  },
})

setup_lsp 'yamlls'

setup_lsp 'vimls'

setup_lsp 'zls'

-- TODO break this out into a zig-specific module
autocmd('FileType', {
  'zig',
}, 'setlocal commentstring=//\\ %s')

-- TODO glepnir/lspsaga.nvim
-- TODO mfussenegger/nvim-dap

-- TODO restore language plugins
-- * fatih/vim-go
-- * ziglang/zig.vim
