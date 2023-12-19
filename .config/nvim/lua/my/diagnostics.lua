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

mykeymap.leader('n', 'dh', vim.diagnostic.hide, { desc = 'Hide diagnostics' })
mykeymap.leader('n', 'dd', function()
  if vim.diagnostic.is_disabled() then
    vim.diagnostic.enable()
  else
    vim.diagnostic.disable()
  end
end, { desc = 'Toggle diagnostics' })

-- vim.diagnostic.config { virtual_text = true }
-- vim.diagnostic.set(ns, 0, diagnostics, { virtual_text = false })
