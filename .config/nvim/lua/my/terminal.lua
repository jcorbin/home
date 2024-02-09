local bind = function(f, ...)
  local args = { ... }
  return function(...) return f(unpack(args), ...) end
end

local myterm = {}

-- Easy run in :terminal map
vim.keymap.set('n', '<leader>!', ':vsplit | term ')

-- Quicker window operations
vim.keymap.set('t', '<C-\\>c', vim.cmd.close, { desc = 'Close buffer' })

vim.keymap.set('t', '<C-\\><C-w>', bind(vim.cmd.wincmd, ''), { desc = 'Last window' })
vim.keymap.set('t', '<C-\\><C-h>', bind(vim.cmd.wincmd, 'h'), { desc = 'Window ←' })
vim.keymap.set('t', '<C-\\><C-j>', bind(vim.cmd.wincmd, 'j'), { desc = 'Window ↓' })
vim.keymap.set('t', '<C-\\><C-k>', bind(vim.cmd.wincmd, 'k'), { desc = 'Window ↑' })
vim.keymap.set('t', '<C-\\><C-l>', bind(vim.cmd.wincmd, 'l'), { desc = 'Window →' })

vim.keymap.set('t', '<C-\\>p', function()
  local reg = '"' -- vim "clipboard"
  vim.api.nvim_paste(vim.fn.getreg(reg), false, -1)
end, { desc = 'Paste Internal' })

vim.keymap.set('t', '<C-\\>P', function()
  local reg = '+' -- os clipboard
  vim.api.nvim_paste(vim.fn.getreg(reg), false, -1)
end, { desc = 'Paste OS' })

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
