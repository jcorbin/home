return {
  'hrsh7th/nvim-cmp',

  dependencies = {
    'L3MON4D3/LuaSnip',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-emoji',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-path',
    'ray-x/cmp-treesitter',
    'saadparwaiz1/cmp_luasnip';
  },

  config = function()
    local cmp = require 'cmp'

    -- TODO rework and hoist into plugin spec
    local opts = {

      sources = cmp.config.sources({
        { name = 'emoji' },
      }, {
        { name = 'nvim_lsp_signature_help' },
      }, {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
      }, {
        { name = 'treesitter' },
        { name = 'buffer' },
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
          local luasnip = require 'luasnip'
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expandable() then
            luasnip.expand {}
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { 'i', 's' }),

        ['<S-Tab>'] = cmp.mapping(function(fallback)
          local luasnip = require 'luasnip'
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),

        -- ['<C-s>'] = cmp.mapping.complete({ sources = { { name = 'vsnip' } } })
        -- inoremap <C-S> <Cmd>lua require('cmp').complete({ sources = { { name = 'vsnip' } } })<CR>

      },

      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        end,
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
    cmp.setup.cmdline('/', {
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

  end
}
