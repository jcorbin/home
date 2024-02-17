return {
  {
    'hrsh7th/nvim-cmp',

    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/cmp-emoji',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lsp-signature-help',
      'hrsh7th/cmp-path',
      'ray-x/cmp-treesitter',
      'petertriho/cmp-git',
      'PhilRunninger/cmp-rpncalc',
      'dcampos/cmp-snippy', -- TODO this is just here to pull in file defintions, use something more minimal
    },

    config = function()
      local cmp = require 'cmp'

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      -- TODO rework and hoist into plugin spec
      local opts = {

        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },

        sources = cmp.config.sources({
          { name = 'emoji' },
          { name = 'rpncalc' },
        }, {
          { name = 'nvim_lsp_signature_help' },
          { name = 'nvim_lsp' },
          { name = 'snippy' },
        }, {
          { name = 'treesitter' },
          { name = 'buffer' },
          { name = 'path' },
        }),

        mapping = {
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-n>'] = cmp.mapping.select_next_item(),

          ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),

          ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
          ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),

          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.snippet.jumpable(1) then
              vim.snippet.jump(1)
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { 'i', 's' }),

          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.snippet.jump(-1) then
              vim.snippet.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),

          -- ['<C-s>'] = cmp.mapping.complete({ sources = { { name = 'vsnip' } } })
          -- inoremap <C-S> <Cmd>lua require('cmp').complete({ sources = { { name = 'vsnip' } } })<CR>

        },

        -- completion.autocomplete
        experimental = {
          ghost_text = true,
        },

        view = {
          entries = { name = 'custom', selection_order = 'near_cursor' },
        },

        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },

        -- formatting = {
        --   format = lspkind.cmp_format(),
        -- },

        -- TODO can se use mini.fuzzy?
        -- sorting.comparators~
        --   `(fun(entry1: cmp.Entry, entry2: cmp.Entry): boolean | nil)`

      }

      cmp.setup(opts)

      -- `/` cmdline setup.
      cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'treesitter' },
          { name = 'buffer' },
        }
      })

      -- `:` cmdline setup.
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = 'path' },
        }, {
          { name = 'cmdline' },
        })
      })

      cmp.setup.filetype('gitcommit', {
        sources = cmp.config.sources({
          { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
        }, {
          { name = 'buffer' },
        })
      })
    end
  },

  {
    'petertriho/cmp-git',
    name = 'cmp_git',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },

  {
    'dcampos/cmp-snippy',
    dependencies = {
      'dcampos/nvim-snippy',
    },
  }

}
