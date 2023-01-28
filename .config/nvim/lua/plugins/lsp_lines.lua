local mykeymap = require 'my.keymap'

return {
  url = 'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  config = function()
    local lsp_lines = require 'lsp_lines'
    lsp_lines.setup()
    vim.diagnostic.config({ virtual_text = false, })
    mykeymap.leader('n', 'l', lsp_lines.toggle)
  end
}
