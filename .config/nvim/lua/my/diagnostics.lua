local mykeymap = require 'my.keymap'

local bind = function(f, ...)
  local args = { ... }
  return function(...) return f(unpack(args), ...) end
end

vim.diagnostic.config {
  signs = true,
  virtual_text = true,
  underline = true,
  float = {
    source = 'if_many',
  },
}

mykeymap.pair('n', 'q',
  bind(vim.cmd, 'cprev'),
  bind(vim.cmd, 'cnext'),
  { desc = 'error (quickfix)' })

mykeymap.pair('n', 'd',
  vim.diagnostic.goto_prev,
  vim.diagnostic.goto_next,
  { desc = 'diagnostic' })

-- TODO dedupe diagnostic open mappings
mykeymap.leader('n', 'dg', vim.diagnostic.open_float, { desc = 'Open diagnostics float' })
