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

require 'my.options'
require 'my.lazy'
require 'my.terminal'
require 'my.diagnostics'
require 'my.language_servers'

-- highlight yanks
autocmd('TextYankPost', function() vim.highlight.on_yank { timeout = 500 } end)

-- TODO glepnir/lspsaga.nvim
-- TODO jose-elias-alvarez/null-ls.nvim
-- TODO mfussenegger/nvim-dap

-- TODO restore language plugins
-- * fatih/vim-go
-- * ziglang/zig.vim

-- TODO audit old vimrc for more
