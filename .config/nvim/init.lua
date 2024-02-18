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

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

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

-- toggle spellchecking
vim.keymap.set('n', '<leader>sp',
  function() vim.opt.spell = not vim.opt.spell:get() end,
  { desc = 'toggle spellchecking' })

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

-- TODO hoist to be nearly first thing after we pull all keymaps and other order-sensitive settings out
require('lazy').setup('plugins')

require 'my.language_servers'

-- highlight yanks
autocmd('TextYankPost', function() vim.highlight.on_yank { timeout = 500 } end)

-- TODO break this out into a zig-specific module
autocmd('FileType', {
  'zig',
}, 'setlocal commentstring=//\\ %s')

-- TODO glepnir/lspsaga.nvim
-- TODO jose-elias-alvarez/null-ls.nvim
-- TODO mfussenegger/nvim-dap

-- TODO restore language plugins
-- * fatih/vim-go
-- * ziglang/zig.vim

-- TODO audit old vimrc for more
