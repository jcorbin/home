local mykeymap = require 'my.keymap'

local bind = function(f, ...)
  local args = { ... }
  return function(...) return f(unpack(args), ...) end
end

local myterm = {}

myterm.keymap = bind(mykeymap.prefix('<C-\\>'), 't')

-- Easy run in :terminal map
mykeymap.leader('n', '!', ':vsplit | term ')

-- Quicker 'Go Back' binding
-- myterm.keymap('<C-o>', <C-\><C-n><C-o>)

-- Quicker window operations
myterm.keymap('c', bind(vim.cmd, 'close'))

myterm.keymap('<C-w>', bind(vim.cmd, 'wincmd '))
myterm.keymap('<C-h>', bind(vim.cmd, 'wincmd h'))
myterm.keymap('<C-j>', bind(vim.cmd, 'wincmd j'))
myterm.keymap('<C-k>', bind(vim.cmd, 'wincmd k'))
myterm.keymap('<C-l>', bind(vim.cmd, 'wincmd l'))

myterm.keymap('p', function()
  local reg = '"' -- vim "clipboard"
  vim.api.nvim_paste(vim.fn.getreg(reg), false, -1)
end)

myterm.find_term = function(findCmd)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local i, _, termcmd = bufname:find('term://.*//%d+:(.*)')
    -- TODO expand termcwd with something like a realpath() that supports ~
    -- expansion, compare against session dir / workspace dir / cwd
    if i and termcmd == findCmd then
      return bufnr
    end
  end
  return nil
end

return myterm
