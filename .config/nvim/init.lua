require 'my.init'
require 'my.lazy'
require 'my.terminal'
require 'my.diagnostics'

local bind = function(f, ...)
  local args = { ... }
  return function(...) return f(unpack(args), ...) end
end

local mykeymap = require 'my.keymap'

-- group for ungrouped autocmds so that they are deduped when reloading
local augroup = require 'my.augroup'
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
require 'my.options'

-- TODO mini.exchange? mini.move? to repalce line exchange pair mapping
-- TODO glepnir/lspsaga.nvim
-- TODO jose-elias-alvarez/null-ls.nvim
-- TODO mfussenegger/nvim-dap

-- TODO restore language plugins
-- * fatih/vim-go
-- * ziglang/zig.vim

-- TODO audit old vimrc for more
