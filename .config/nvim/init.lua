require 'my.init'
require 'my.keys'
require 'my.options'
require 'my.lazy'
require 'my.terminal'
require 'my.diagnostics'
require 'my.language_servers'

-- group for ungrouped autocmds so that they are deduped when reloading
local augroup = require 'my.augroup'
local autocmd = augroup 'myvimrc'

-- highlight yanks
autocmd('TextYankPost', function() vim.highlight.on_yank { timeout = 500 } end)

-- TODO glepnir/lspsaga.nvim
-- TODO jose-elias-alvarez/null-ls.nvim
-- TODO mfussenegger/nvim-dap

-- TODO restore language plugins
-- * fatih/vim-go
-- * ziglang/zig.vim

-- TODO audit old vimrc for more
