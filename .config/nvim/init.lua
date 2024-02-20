--- use <Space> for mapleader {{{
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- }}}

--- utilities {{{
local bind = function(f, ...)
  local args = { ... }
  return function(...) return f(unpack(args), ...) end
end

-- group for ungrouped autocmds so that they are deduped when reloading
local augroup = require 'my.augroup'
local autocmd = augroup 'myvimrc'

local mykeymap = require 'my.keymap'
-- }}}

--- Lazy plugin manager {{{
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

-- NOTE needs to happen AFTER mapleader option is set, since plugins' setup may define leader mappings
require('lazy').setup('plugins')
-- }}}

--- easy editing of/around $MYVIMRC {{{
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
-- }}}

--- UI options {{{
vim.opt.guifont = 'JetBrains Mono:h14'
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.opt.mouse = 'a'
vim.cmd.colorscheme 'kanagawa'
vim.opt.laststatus = 2

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
-- }}}

--- Various options {{{
-- allow placing cursor in virtual space (past end of line)
vim.opt.virtualedit = 'all'

-- use completion popup menu with manual seleection
vim.opt.completeopt = { 'menuone', 'popup', 'noselect' }

-- display 2 lines of context top/bottom when scrolling
vim.opt.scrolloff = 2

-- set for CursorHold purposes
vim.opt.updatetime = 250

-- }}}

--- Folding {{{
vim.opt.foldlevelstart = 1 -- start out with level 1 folds open
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- }}}

--- Indentation {{{
vim.opt.breakindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
-- }}}

--- Searching {{{
vim.opt.incsearch = true
vim.opt.smartcase = true
vim.keymap.set('n', '<leader>ci',
  function() vim.opt.ignorecase = not vim.opt.ignorecase:get() end,
  { desc = 'toggle search case sensitivity' })
-- }}}

--- context marker motion {{{
local context_marker = [[^\(@@ .* @@\|[<=>|]\{7}[<=>|]\@!\)]]
vim.keymap.set('n', '<leader>[n',
  function() vim.fn.search(context_marker, 'bW') end,
  { desc = 'prev conflict marker' })
vim.keymap.set('n', '<leader>]n',
  function() vim.fn.search(context_marker, 'W') end,
  { desc = 'next conflict marker' })
-- }}}

-- line exchange mappings
vim.keymap.set('n', '[e', '<leader>:move--<cr>')
vim.keymap.set('n', ']e', '<leader>:move+<cr>')

--- marginally quicker path to norm/move/copy a range {{{
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
-- }}}

--- Line numbering and wrapping toggles {{{
vim.keymap.set('n', '<leader>ln',
  function() vim.opt.number = not vim.opt.number:get() end,
  { desc = 'toggle line numbers' })
vim.keymap.set('n', '<leader>lr',
  function() vim.opt.relativenumber = not vim.opt.relativenumber:get() end,
  { desc = 'toggle relative line numbers' })
vim.keymap.set('n', '<leader>lw',
  function() vim.opt.wrap = not vim.opt.wrap:get() end,
  { desc = 'toggle virtual line wrapping' })
-- }}}

--- Cursor reticle toggles {{{
vim.opt.cursorline = true
vim.keymap.set('n', '<leader>cl',
  function() vim.opt.cursorline = not vim.opt.cursorline:get() end,
  { desc = 'toggle cursor line highlight' })
vim.keymap.set('n', '<leader>cc',
  function() vim.opt.cursorcolumn = not vim.opt.cursorcolumn:get() end,
  { desc = 'toggle cursor column highlight' })
-- }}}

--- Spellchecking {{{
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
-- }}}

--- :terminal Quality of Life {{{
-- Analog of :!
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
-- }}}

--- vim.diagnostic setup {{{
vim.diagnostic.config {
  signs = true,
  virtual_text = true,
  underline = true,
  float = {
    source = 'if_many',
  },
}

vim.keymap.set('n', '[q', vim.cmd.cprev, { desc = 'Previous error (quickfix)' })
vim.keymap.set('n', ']q', vim.cmd.cnext, { desc = 'Next error (quickfix)' })

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
-- }}}

-- highlight yanks
autocmd('TextYankPost', function() vim.highlight.on_yank { timeout = 500 } end)

--- Inspects any value in a floating window scratch buffer.
--- Focus is transferred to the new floating window.
---
--- TODO add an easy Q/<Esc> keymap to dismiss
--- TODO is there a better standard-ish way of doing this? surely?
---
--- @param v any
local function popup(v)
  local mess = type(v) == "string" and v or vim.inspect(v)
  local lines = vim.split(mess, "\n")
  local width = vim.iter(lines)
      :map(function(line) return #line end)
      :fold(1, function(a, b) return a > b and a or b end)
  local height = #lines

  local winheight = vim.fn.winheight(0)
  local winwidth = vim.fn.winwidth(0)
  local remheight = winheight - vim.fn.winline() - 1
  local remwidth = winwidth - vim.fn.wincol()
  if width > remwidth then width = remwidth end
  if height > remheight then height = remheight end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, lines)

  vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    anchor = 'NW',
    col = 0,
    row = 1,
    width = width,
    height = height,
    style = 'minimal'
  })
end

autocmd('LspAttach', function(args)
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if client == nil then return end

  local bufnr = args.buf
  local caps = client.server_capabilities or {}

  local autocmd_local = autocmd.buffer(bufnr)
  local map_buffer = mykeymap.options { buffer = bufnr }
  local map_local = mykeymap.prefix('<LocalLeader>', map_buffer)

  map_buffer('n', '<C-k>', vim.lsp.buf.signature_help)

  -- keymaps to act on code
  map_local('n', 'a', vim.lsp.buf.code_action, { desc = 'invoke code action (lsp)' })
  map_local('n', 'gR', vim.lsp.buf.rename, { desc = 'rename symbol (lsp)' })

  -- telescope invocations
  local telescopes = require 'telescope.builtin'
  map_local('n', 'sr', telescopes.lsp_references, { desc = 'search lsp references' })
  map_local('n', 'sy', telescopes.lsp_document_symbols, { desc = 'search lsp document symbosl' })
  map_local('n', 'sw', telescopes.lsp_workspace_symbols, { desc = 'search lsp workspace symbols' })

  -- inlay hints (uses virtual text to display parameter names and such)
  if caps.inlayHintProvider then
    vim.lsp.inlay_hint.enable(bufnr, true)
    map_local('n', 'hh',
      function() vim.lsp.inlay_hint.enable(bufnr, not vim.lsp.inlay_hint.is_enabled()) end,
      { desc = 'toggle lsp inlay hints' })
  end

  -- cursor hold highlighting
  if caps.documentHighlightProvider then
    autocmd_local({ 'CursorHold', 'CursorHoldI' }, function()
      vim.lsp.buf.document_highlight()
    end)
    autocmd_local('CursorMoved', function()
      vim.lsp.buf.clear_references()
    end)
  end

  if caps.codeLensProvider ~= nil and caps.codeLensProvider.resolveProvider then
    autocmd_local({ 'BufEnter', 'CursorHold', 'InsertLeave' }, function()
      vim.lsp.codelens.refresh({ bufnr = 0 })
    end)
  end

  map_local('n', 'lc', function()
    popup({ server_capabilities = vim.lsp.get_clients()[1].server_capabilities })
  end)

  map_local('n', 'lt', function()
    popup({ semantic_tokens = vim.lsp.semantic_tokens.get_at_pos() })
  end)
end)

--- Setup Language Servers {{{

local function setup_lsp(name, opts)
  if opts == nil then
    opts = {}
  end
  opts = vim.tbl_extend('keep', opts, {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
  })
  require('lspconfig')[name].setup(opts)
end

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
-- }}}

-- TODO break this out into a zig ftplugin
autocmd('FileType', {
  'zig',
}, 'setlocal commentstring=//\\ %s')

-- TODO glepnir/lspsaga.nvim
-- TODO mfussenegger/nvim-dap

-- TODO restore language plugins
-- * fatih/vim-go
-- * ziglang/zig.vim

-- vim:foldmethod=marker
