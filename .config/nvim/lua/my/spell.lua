local augroup = require 'my.augroup'
local autocmd = augroup 'my.spell'

-- spellchecking on by default...
vim.opt.spell = true

-- ...off by exception
autocmd('FileType', {
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
