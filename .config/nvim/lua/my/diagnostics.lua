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

vim.keymap.set('n', '[q', bind(vim.cmd, 'cprev'), { desc = 'Previous error (quickfix)' })
vim.keymap.set('n', ']q', bind(vim.cmd, 'cnext'), { desc = 'Next error (quickfix)' })

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })

-- TODO dedupe diagnostic open mappings
vim.keymap.set('n', '<leader>dg',
  vim.diagnostic.open_float, { desc = 'Open diagnostics float' })

vim.keymap.set('n', '<leader>dh',
  vim.diagnostic.hide, { desc = 'Hide diagnostics' })

vim.keymap.set('n', '<leader>dd',
  function()
    if vim.diagnostic.is_disabled() then
      vim.diagnostic.enable()
    else
      vim.diagnostic.disable()
    end
  end,
  { desc = 'Toggle diagnostics' })

-- vim.diagnostic.config { virtual_text = true }
-- vim.diagnostic.set(ns, 0, diagnostics, { virtual_text = false })
