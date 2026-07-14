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

    -- Bound under the <leader>l* line-toggle group (avoids shadowing that prefix).
    vim.keymap.set('n', '<leader>lL', lsp_lines.toggle, { desc = 'toggle lsp_lines diagnostics' })
  end
}
