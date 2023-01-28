local mykeymap = require 'my.keymap'

return {
  'folke/which-key.nvim',
  opts = {
    spelling = {
      enabled = true,
    },
  },
  config = function(_, opts)
    vim.o.timeout = true
    vim.o.timeoutlen = 300
    local which_key = require('which-key')
    which_key.setup(opts)
    mykeymap.leader('n', 'h', ':WhichKey<cr>', { desc = 'Keymap Help' })
  end,
}
