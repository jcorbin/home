require 'my.init'
require 'my.lazy'
require 'my.terminal'

local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local opt = vim.opt

local bind = function(f, ...)
  local args = { ... }
  return function(...) return f(unpack(args), ...) end
end

-- TODO restore language plugins
-- * fatih/vim-go
-- * ziglang/zig.vim

local augroup = require 'my.augroup'

-- group for ungrouped autocmds so that they are deduped when reloading
local autocmd = augroup 'myvimrc'

local mykeymap = require 'my.keymap'

-- context marker motion
local context_marker = [[^\(@@ .* @@\|[<=>|]\{7}[<=>|]\@!\)]]
mykeymap.pair('n', 'n',
  bind(fn.search, context_marker, 'bW'),
  bind(fn.search, context_marker, 'W'))

-- line exchange mappings ; TODO mini.exchange is a planned module {{{
-- TODO repeatable
mykeymap.pair('n', 'e', ':move--<cr>', ':move+<cr>')
-- }}}

-- ex command convenience maps {{{

-- marginally quicker path to norm/move/copy a range
-- ... this mapping is barely useful in normal mode fwiw
mykeymap.leader({ 'n', 'v' }, 'nn', ':norm ')
mykeymap.leader({ 'n', 'v' }, 'mm', ':move ')
mykeymap.leader({ 'n', 'v' }, 'cc', ':copy ')

-- gre* family mappings that reuse the last search pattern
mykeymap.leader({ 'n', 'v' }, 'gn', [[:g\/ norm ]])
mykeymap.leader({ 'n', 'v' }, 'gm', [[:g\/ move ]])
mykeymap.leader({ 'n', 'v' }, 'gc', [[:g\/ copy ]])
mykeymap.leader({ 'n', 'v' }, 'gd', [[:g\/ delete<cr>]])

-- negative match versions of those
mykeymap.leader({ 'n', 'v' }, 'vn', [[:v\/ norm ]])
mykeymap.leader({ 'n', 'v' }, 'vm', [[:v\/ move ]])
mykeymap.leader({ 'n', 'v' }, 'vc', [[:v\/ copy ]])
mykeymap.leader({ 'n', 'v' }, 'vd', [[:v\/ delete<cr>]])

-- }}}

-- diagnostics and quickfix {{{

vim.diagnostic.config {
  signs = true,
  virtual_text = true,
  underline = true,
  float = {
    source = 'if_many',
  },
}

mykeymap.pair('n', 'q',
  bind(cmd, 'cprev'),
  bind(cmd, 'cnext'))

mykeymap.pair('n', 'd',
  vim.diagnostic.goto_prev,
  vim.diagnostic.goto_next)

-- TODO dedupe diagnostic open mappings
mykeymap.leader('n', 'e', vim.diagnostic.open_float)
mykeymap.leader('n', 'dg', vim.diagnostic.open_float)

-- }}}

-- highlight yanks
autocmd('TextYankPost', function() vim.highlight.on_yank { timeout = 500 } end)

require 'my.language_servers'

-- TODO glepnir/lspsaga.nvim
-- TODO jose-elias-alvarez/null-ls.nvim
-- TODO mfussenegger/nvim-dap

-- Options {{{

opt.guifont = 'JetBrains Mono:h12'

opt.termguicolors = true
opt.background = 'dark'

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

autocmd('FileType', {
  'zig',
}, 'setlocal commentstring=//\\ %s')

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

-- neovide specific config
if g.neovide then
  g.neovide_scale_factor = 1.0

  local scale_step = 0.05
  vim.keymap.set({ 'n' }, '<C-=>', function() g.neovide_scale_factor = g.neovide_scale_factor * (1 + scale_step) end)
  vim.keymap.set({ 'n' }, '<C-->', function() g.neovide_scale_factor = g.neovide_scale_factor / (1 + scale_step) end)
  vim.keymap.set({ 'n' }, '<C-0>', function() g.neovide_scale_factor = 1.0 end)

  g.neovide_hide_mouse_when_typing = true

  g.neovide_cursor_vfx_mode = 'railgun'
end

-- option toggles
mykeymap.opt_toggle('<leader>ci', 'ignorecase')
mykeymap.opt_toggle('<leader>ln', 'number')
mykeymap.opt_toggle('<leader>rc', 'relativenumber')
mykeymap.opt_toggle('<leader>cl', 'cursorline')
mykeymap.opt_toggle('<leader>cc', 'cursorcolumn')
mykeymap.opt_toggle('<leader>lw', 'wrap')
mykeymap.opt_toggle('<leader>sp', 'spell')

-- }}}

-- vim: set ts=2 sw=2 foldmethod=marker:
