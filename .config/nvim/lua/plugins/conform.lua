return {
  'stevearc/conform.nvim',
  opts = {

    formatters_by_ft = {
      sh = { 'shfmt' },
    },

    format_on_save = {
      -- These options will be passed to conform.format()
      timeout_ms = 500,
      lsp_fallback = true,
      quiet = true,
    },

  },

  config = function(_, opts)
    local conform = require('conform')
    conform.setup(opts)

    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    vim.keymap.set('n', '<leader>f', function()
      conform.format {
        timeout_ms = 5000,
        lsp_fallback = true,
      }
    end)
  end

}
