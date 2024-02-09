return {
  url = 'https://git.sr.ht/~whynothugo/lsp_lines.nvim',

  opts = {},

  config = function(_, opts)
    local lsp_lines = require 'lsp_lines'
    lsp_lines.setup(opts)

    vim.diagnostic.config({
      virtual_text = true,
      virtual_lines = { only_current_line = true },
    })

    vim.keymap.set('n', '<leader>l', lsp_lines.toggle)
  end
}
