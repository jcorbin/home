require 'my.init'
require 'my.lazy'
require 'my.terminal'
require 'my.diagnostics'

local bind = function(f, ...)
  local args = { ... }
  return function(...) return f(unpack(args), ...) end
end

local mykeymap = require 'my.keymap'
local augroup = require 'my.augroup'

-- group for ungrouped autocmds so that they are deduped when reloading
local autocmd = augroup 'myvimrc'

-- context marker motion
local context_marker = [[^\(@@ .* @@\|[<=>|]\{7}[<=>|]\@!\)]]
mykeymap.pair('n', 'n',
  bind(vim.fn.search, context_marker, 'bW'),
  bind(vim.fn.search, context_marker, 'W'),
  { desc = 'conflict marker' })

-- line exchange mappings
mykeymap.pair('n', 'e', ':move--<cr>', ':move+<cr>')

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

-- highlight yanks
autocmd('TextYankPost', function() vim.highlight.on_yank { timeout = 500 } end)

require 'my.language_servers'

-- Options {{{

local opt = vim.opt

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

-- neovide specific config
if vim.g.neovide then
  vim.g.neovide_scale_factor = 1.0

  local scale_step = 0.05
  vim.keymap.set({ 'n' }, '<C-=>', function() vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * (1 + scale_step) end)
  vim.keymap.set({ 'n' }, '<C-->', function() vim.g.neovide_scale_factor = vim.g.neovide_scale_factor / (1 + scale_step) end)
  vim.keymap.set({ 'n' }, '<C-0>', function() vim.g.neovide_scale_factor = 1.0 end)

  vim.g.neovide_hide_mouse_when_typing = true

  vim.g.neovide_cursor_vfx_mode = 'railgun'
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

-- TODO mini.exchange? mini.move? to repalce line exchange pair mapping
-- TODO glepnir/lspsaga.nvim
-- TODO jose-elias-alvarez/null-ls.nvim
-- TODO mfussenegger/nvim-dap

-- TODO restore language plugins
-- * fatih/vim-go
-- * ziglang/zig.vim

-- TODO audit old vimrc for more

-- vim: set ts=2 sw=2 foldmethod=marker:
