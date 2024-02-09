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
    vim.keymap.set('n', '<leader>h', ':WhichKey<cr>', { desc = 'Keymap Help' })
  end,
}
