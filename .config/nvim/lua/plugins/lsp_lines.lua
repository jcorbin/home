local mykeymap = require 'my.keymap'

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

    mykeymap.leader('n', 'l', lsp_lines.toggle)
  end
}
