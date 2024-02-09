-- eases editing and reloading neovim config

local augroup = require 'my.augroup'
local autocmd = augroup 'myinit'

local mykeymap = require 'my.keymap'

local file_doer = function(path)
  return function()
    dofile(path)
    vim.notify('Reloaded ' .. path)
  end
end

mykeymap.leader('n', 'ev', function()
  vim.cmd.vsplit(vim.env.MYVIMRC)
end, { desc = 'edit $MYVIMRC' })

mykeymap.leader('n', 'ec', function()
  vim.cmd.vsplit(vim.fs.dirname(vim.env.MYVIMRC))
end, { desc = 'edit directory of $MYVIMRC' })

autocmd('BufWritePost', vim.env.MYVIMRC, function(opts)
  vim.schedule(file_doer(opts.file))
end)
