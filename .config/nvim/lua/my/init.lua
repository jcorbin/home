-- eases editing and reloading neovim config

local augroup = require 'my.augroup'
local autocmd = augroup 'myinit'

local file_doer = function(path)
  return function()
    dofile(path)
    vim.notify('Reloaded ' .. path)
  end
end

autocmd('BufWritePost', vim.env.MYVIMRC, function(opts)
  vim.schedule(file_doer(opts.file))
end)
