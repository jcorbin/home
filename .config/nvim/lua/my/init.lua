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

mykeymap.leader('n', 'ev', ':vsplit $MYVIMRC<cr>')

autocmd('BufWritePost', vim.env.MYVIMRC, function(opts)
  vim.schedule(file_doer(opts.file))
end)
