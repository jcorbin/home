return {
  'nvim-treesitter/nvim-treesitter',
  opts = {
    ensure_installed = {},
    sync_install = 'false',
    auto_install = 'true',

    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },

    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },

    indent = { enable = true },

    textobjects = { enable = true },

  },
  config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)

    vim.opt.foldmethod = 'expr'
    vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
  end,
}
