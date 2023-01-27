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
  bind(vim.cmd, 'cnext'))

mykeymap.pair('n', 'd',
  vim.diagnostic.goto_prev,
  vim.diagnostic.goto_next)

-- TODO dedupe diagnostic open mappings
mykeymap.leader('n', 'e', vim.diagnostic.open_float)
mykeymap.leader('n', 'dg', vim.diagnostic.open_float)
