return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',

  opts = {

    ensure_installed = 'all',

    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },

    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },

    indent = { enable = true },

  },

  config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)

    vim.opt.foldmethod = 'expr'
    vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'

  end,
}
