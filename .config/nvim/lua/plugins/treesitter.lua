return {
  {
    'nvim-treesitter/nvim-treesitter',

    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },

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
          init_selection = "gnn",
          node_incremental = "grn",
          scope_incremental = "grc",
          node_decremental = "grm",
        },
      },

      indent = { enable = true },

      textobjects = {
        select = {
          enable = true,
          lookahead = true,

          keymaps = {

            -- You can use the capture groups defined in textobjects.scm
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",

            -- You can optionally set descriptions to the mappings (used in the desc parameter of
            -- nvim_buf_set_keymap) which plugins like which-key display
            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },

            -- You can also use captures from other query groups like `locals.scm`
            ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
          },
        },

        swap = {
          enable = true,
          swap_previous = { ["[."] = "@parameter.inner", },
          swap_next = { ["]."] = "@parameter.inner", },
        },
      },

    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)

      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
    end,
  },
  'nvim-treesitter/nvim-treesitter-textobjects',
}
