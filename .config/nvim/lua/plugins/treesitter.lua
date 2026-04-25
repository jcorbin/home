return {

  -- {
  --   "arborist-ts/arborist.nvim",
  -- },

  {
    "romus204/tree-sitter-manager.nvim",
    dependencies = {}, -- tree-sitter CLI must be installed system-wide
    config = function()
      require("tree-sitter-manager").setup({
        -- Optional: custom paths
        -- parser_dir = vim.fn.stdpath("data") .. "/site/parser",
        -- query_dir = vim.fn.stdpath("data") .. "/site/queries",
      })
    end
  },

  -- {
  --   'nvim-treesitter/nvim-treesitter',
  --   branch = 'main',
  --
  --   opts = {
  --     ensure_installed = {},
  --     sync_install = 'false',
  --     auto_install = 'true',
  --
  --     highlight = {
  --       enable = true,
  --       additional_vim_regex_highlighting = false,
  --     },
  --
  --     incremental_selection = {
  --       enable = true,
  --       keymaps = {
  --         init_selection = "gnn",
  --         node_incremental = "grn",
  --         scope_incremental = "grc",
  --         node_decremental = "grm",
  --       },
  --     },
  --
  --     indent = { enable = true },
  --
  --   },
  -- },

}
