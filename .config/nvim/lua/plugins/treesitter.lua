_G.get_foldtext = function()
  local res = vim.treesitter.foldtext()

  local foldstart = vim.v.foldstart
  local foldend = vim.v.foldend
  if type(res) == "string" then
    local line = vim.api.nvim_buf_get_lines(0, foldstart - 1, foldstart, false)[1]
    res = { { line, "Normal" } }
  end

  local suffix = string.format("  ┉ [%s lines]", foldend - foldstart + 1)
  table.insert(res, { suffix, "Folded" })

  return res
end

return {
  {
    'nvim-treesitter/nvim-treesitter',

    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'nvim-treesitter/nvim-treesitter-refactor',
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

      refactor = {
        highlight_definitions = {
          enable = true,
          -- Set to false if you have an `updatetime` of ~100.
          clear_on_cursor_move = true,
        },
        highlight_current_scope = { enable = false },
        smart_rename = {
          enable = true,
          -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
          keymaps = {
            smart_rename = "grr",
          },
        },
      },

    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)

      vim.opt.foldmethod = 'expr'
      vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.opt.foldtext = "v:lua.get_foldtext()"
    end,
  },
  'nvim-treesitter/nvim-treesitter-textobjects',
  'nvim-treesitter/nvim-treesitter-refactor',
}
