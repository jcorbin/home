return {

  {
    'esmuellert/nvim-eslint',
    config = function()
      require('nvim-eslint').setup({})
    end,
  },

  -- {
  --   'microsoft/eslint-ls',
  --   ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'markdown', 'json' },
  -- },

}
