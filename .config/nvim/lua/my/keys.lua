vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('n', '<leader>ev', function()
  vim.cmd.vsplit(vim.env.MYVIMRC)
end, { desc = 'edit $MYVIMRC' })

vim.keymap.set('n', '<leader>ec', function()
  vim.cmd.vsplit(vim.fs.dirname(vim.env.MYVIMRC))
end, { desc = 'edit directory of $MYVIMRC' })

local mykeymap = require 'my.keymap'

-- context marker motion
local context_marker = [[^\(@@ .* @@\|[<=>|]\{7}[<=>|]\@!\)]]
mykeymap.pair('n', 'n',
  function() vim.fn.search(context_marker, 'bW') end,
  function() vim.fn.search(context_marker, 'W') end,
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
