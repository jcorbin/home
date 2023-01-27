local mykeymap = require 'my.keymap'

local bind = function(f, ...)
  local args = { ... }
  return function(...) return f(unpack(args), ...) end
end

local tmap = bind(mykeymap.prefix('<C-\\>'), 't')

return {
  'nvim-telescope/telescope.nvim',

  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    'folke/trouble.nvim',
  },

  config = function()
    local telescope = require 'telescope'
    local telescopes = require 'telescope.builtin'
    local actions = require 'telescope.actions'

    local open_with_trouble = require('trouble.providers.telescope').open_with_trouble

    -- TODO rework and hoist into the plugin spec
    local opts = {
      defaults = {
        generic_sorter = require('mini.fuzzy').get_telescope_sorter,
        mappings = {
          i = {
            ["<c-t>"] = open_with_trouble,
            ["<C-u>"] = false,
            ["<C-h>"] = actions.which_key,
            ['<c-d>'] = actions.delete_buffer,
          },
          n = {
            ["<c-t>"] = open_with_trouble,
            ["<C-h>"] = actions.which_key,
            ['<c-d>'] = actions.delete_buffer,
          },
        },
        layout_strategy = 'cursor',
        layout_config = {
          cursor = {
            width = 0.8,
            height = 0.5,
          },
          horizontal = {
            anchor = 'SE',
            width = 0.8,
            height = 0.5,
          },
          vertical = {
            anchor = 'SE',
            width = 0.5,
            height = 0.8,
          },
        },
      },
      pickers = {
        buffers = {
          sort_lastused = true,
          sort_mru = true,
        },
      },

      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown {
            -- even more opts
          },

          -- pseudo code / specification for writing custom displays, like the one
          -- for "codeactions"
          -- specific_opts = {
          --   [kind] = {
          --     make_indexed = function(items) -> indexed_items, width,
          --     make_displayer = function(widths) -> displayer
          --     make_display = function(displayer) -> function(e)
          --     make_ordinal = function(e) -> string
          --   },
          --   -- for example to disable the custom builtin "codeactions" display
          --      do the following
          --   codeactions = false,
          -- },
        },
      },
    }

    telescope.setup(opts)
    telescope.load_extension('ui-select')

    mykeymap.leader('n', '<Space>', telescopes.buffers)
    tmap('<Space>', bind(telescopes.buffers, { ignore_current_buffer = true }))

    mykeymap.leader('n', 'sf', bind(telescopes.find_files, {
      previewer = false,
      hidden = true,
      no_ignore = true,
    }))
    mykeymap.leader('n', 'sb', telescopes.current_buffer_fuzzy_find)
    mykeymap.leader('n', 'sh', telescopes.help_tags)
    mykeymap.leader('n', 'st', telescopes.tags)
    mykeymap.leader('n', 'ss', telescopes.grep_string)
    mykeymap.leader('n', 'sg', telescopes.live_grep)
    mykeymap.leader('n', 'so', bind(telescopes.tags, { only_current_buffer = true }))
    mykeymap.leader('n', '?', telescopes.oldfiles)
    mykeymap.leader('n', 'sm', telescopes.man_pages)
    mykeymap.leader('n', 'st', telescopes.treesitter)
    mykeymap.leader('n', 'sd', telescopes.diagnostics)
    mykeymap.leader('n', 's.', telescopes.resume)
  end
}
