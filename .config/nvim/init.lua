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

local telescopes = require 'telescope.builtin'

--- easy editing of/around $MYVIMRC {{{
vim.keymap.set('n', '<leader>ev', function()
  vim.cmd.vsplit(vim.env.MYVIMRC)
end, { desc = 'edit $MYVIMRC' })
vim.keymap.set('n', '<leader>ec', function()
  vim.cmd.vsplit(vim.fs.dirname(vim.env.MYVIMRC))
end, { desc = 'edit directory of $MYVIMRC' })

vim.keymap.set('n', '<leader>sc', bind(telescopes.find_files, {
  cwd = vim.fs.dirname(vim.env.MYVIMRC),
  previewer = false,
  hidden = true,
  no_ignore = true,
}), { desc = 'search files near $MYVIMRC' })

vim.keymap.set('n', '<leader>sl', bind(telescopes.find_files, {
  cwd = vim.fn.stdpath('data'),
  previewer = false,
  hidden = true,
  no_ignore = true,
}), { desc = 'search files near $MYVIMRC' })

-- }}}

--- UI options {{{
vim.opt.guifont = 'JetBrains Mono:h14'
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.opt.mouse = 'a'
vim.cmd.colorscheme 'kanagawa'
vim.opt.laststatus = 2
vim.opt.smoothscroll = true

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
vim.keymap.set({ 'n', 'v' }, '[n',
  function() vim.fn.search(context_marker, 'bW') end,
  { desc = 'Prev conflict marker' })
vim.keymap.set({ 'n', 'v' }, ']n',
  function() vim.fn.search(context_marker, 'W') end,
  { desc = 'Next conflict marker' })
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

--- misc telescopes {{{

vim.keymap.set('n', '<leader>s.', telescopes.resume, { desc = 'resume last search' })

vim.keymap.set('n', '<leader>sf', bind(telescopes.find_files, {
  previewer = false,
  hidden = true,
  no_ignore = true,
}), { desc = 'search files' })

vim.keymap.set('n', '<leader>sh', telescopes.help_tags, { desc = 'search help' })
vim.keymap.set('n', '<leader>sm', telescopes.man_pages, { desc = 'search man pages' })

vim.keymap.set('n', '<leader>sb', telescopes.current_buffer_fuzzy_find, { desc = 'search in current buffer' })

vim.keymap.set('n', '<leader>ss', telescopes.grep_string, { desc = 'grep string search' })
vim.keymap.set('n', '<leader>sg', telescopes.live_grep, { desc = 'live grep search' })

vim.keymap.set('n', '<leader>so', telescopes.oldfiles, { desc = 'search old files' })
vim.keymap.set('n', '<leader>st', telescopes.treesitter, { desc = 'search syntax tree' })
vim.keymap.set('n', '<leader>sd', telescopes.diagnostics, { desc = 'search diagnostics' })

--- }}}

--- :terminal Quality of Life {{{

-- Analog of :!
vim.keymap.set('n', '<leader>!', ':vert term ')

-- more natural prefix for terminal mode mappings than the awkward <C-\\> default
-- this is like a tmux prefix, but instead we choose C-w for alignment with normal mode's window command map
local tleader = '<C-w>'

--- less awkward escape from terminal mode back to normal mode
vim.keymap.set('t', tleader .. 'n', '<C-\\><C-n>')     -- N for Normal
vim.keymap.set('t', tleader .. '<Esc>', '<C-\\><C-n>') -- or <Escape> because reflex

-- double leader for literal
vim.keymap.set('t', tleader .. tleader, tleader)

-- wincmd without needing to bounce to normal mode
for _, key in ipairs({
  'c', 'o', 'q',
  'r', '<C-r>', 'R',
  'x', '<C-x>',
  '<C-w>', -- NOTE probably not unless you change tleader to something else
  'h', 'j', 'k', 'l',
  'H', 'J', 'K', 'L',
  'T',
  '=', '-', '+', '<', '>',
}) do
  if key ~= tleader then
    vim.keymap.set('t', tleader .. key, bind(vim.cmd.wincmd, key))
  end
end

-- easy paste without bouncing out to normal mode
vim.keymap.set('t', tleader .. 'p',
  function() vim.api.nvim_paste(vim.fn.getreg('"'), false, -1) end,
  { desc = 'Paste Internal' })
vim.keymap.set('t', tleader .. 'P',
  function() vim.api.nvim_paste(vim.fn.getreg('+'), false, -1) end,
  { desc = 'Paste OS' })

-- }}}

--- Easy Fixed Width Windows {{{

-- pin a window to 10x col increments
for _, n in ipairs({ 2, 4, 6, 8, }) do
  local width = 10 * n
  local setem = function()
    vim.cmd('vertical resize ' .. width)
    vim.o.winfixwidth = true
  end
  local opts = {
    desc = 'Fix Width to ' .. width .. ' columns',
  }
  vim.keymap.set('t', tleader .. n, setem, opts)
  vim.keymap.set('n', '<C-w>' .. n, setem, opts)
end

-- clear winfixwidth and equalize layout thereafter
local clear_winfixwidth = function()
  if vim.o.winfixwidth then
    vim.o.winfixwidth = false
    vim.cmd.wincmd '='
  end
end
vim.keymap.set('t', tleader .. '*', clear_winfixwidth, { desc = 'Clear winfixwidth' })
vim.keymap.set('n', '<C-w>*', clear_winfixwidth, { desc = 'Clear winfixwidth' })

-- }}}

--- Buffer management Quality of Life {{{

-- far better UX than needing to use :buffer or :bdelete directly
local other_buffer = bind(telescopes.buffers, { ignore_current_buffer = true })
vim.keymap.set('n', '<leader><Space>', other_buffer, { desc = 'search buffers' })
vim.keymap.set('t', tleader .. '<Space>', other_buffer, { desc = 'search buffers' })

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

vim.keymap.set('n', '<leader>dd',
  function()
    if vim.diagnostic.is_enabled() then
      vim.diagnostic.enable(false)
    else
      vim.diagnostic.enable()
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

autocmd('LspAttach', function(ev)
  local client = vim.lsp.get_client_by_id(ev.data.client_id)
  if client == nil then return end

  -- TODO Dynamic registration of LSP capabilities. An implication of this change is
  --      that checking a client's `server_capabilities` is no longer a sufficient
  --      indicator to see if a server supports a feature. Instead use
  --      `client.supports_method(<method>)`. It considers both the dynamic
  --      capabilities and static `server_capabilities`.

  local bufnr = ev.buf
  local caps = client.server_capabilities or {}

  local autocmd_local = autocmd.buffer(bufnr)
  local map_buffer = mykeymap.options { buffer = bufnr }
  local map_local = mykeymap.prefix('<LocalLeader>', map_buffer)

  map_buffer('n', '<C-k>', vim.lsp.buf.signature_help, { desc = 'lsp signature help' })

  -- keymaps to act on code
  map_local('n', 'a', vim.lsp.buf.code_action, { desc = 'invoke code action (lsp)' })
  map_local('n', 'gR', vim.lsp.buf.rename, { desc = 'rename symbol (lsp)' })

  -- telescope invocations
  local telescopes = require 'telescope.builtin'
  map_local('n', 'sr', telescopes.lsp_references, { desc = 'search lsp references' })
  map_local('n', 'sy', telescopes.lsp_document_symbols, { desc = 'search lsp document symbosl' })
  map_local('n', 'sw', telescopes.lsp_workspace_symbols, { desc = 'search lsp workspace symbols' })

  -- -- inlay hints (uses virtual text to display parameter names and such)
  -- if caps.inlayHintProvider then
  --   vim.lsp.inlay_hint.enable(bufnr, true)
  --   map_local('n', 'hh',
  --     function() vim.lsp.inlay_hint.enable(bufnr, not vim.lsp.inlay_hint.is_enabled()) end,
  --     { desc = 'toggle lsp inlay hints' })
  -- end

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

setup_lsp 'arduino_language_server'

setup_lsp('bashls', {
  filetypes = { 'sh', 'bash', 'zsh' },
})

setup_lsp 'clangd'

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

setup_lsp('basedpyright')

setup_lsp 'rust_analyzer'
-- https://github.com/rust-analyzer/rust-analyzer/tree/master/docs/user#settings

setup_lsp 'ts_ls'

-- setup_lsp('tsserver', {
--   completions = {
--     completeFunctionCalls = true,
--   },
--
--   init_options = {
--     preferences = {
--       includeInlayParameterNameHints = 'all',
--       includeInlayParameterNameHintsWhenArgumentMatchesName = false,
--
--       -- works, but too noisy imo
--       -- includeInlayFunctionParameterTypeHints = true,
--
--       -- broken
--       -- includeInlayFunctionLikeReturnTypeHints = true,
--       -- includeInlayVariableTypeHints = true,
--
--       -- untested
--       -- includeInlayPropertyDeclarationTypeHints = true,
--       -- includeInlayEnumMemberValueHints = true,
--       -- importModuleSpecifierPreference = 'non-relative',
--
--     },
--   },
-- })

setup_lsp 'yamlls'

setup_lsp 'vimls'

setup_lsp 'zls'
-- }}}

-- TODO break this out into an openscad ftplugin
autocmd('FileType', {
  'openscad',
}, 'setlocal commentstring=//\\ %s')

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
