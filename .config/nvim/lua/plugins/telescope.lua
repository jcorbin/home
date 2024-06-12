local bind = function(f, ...)
  local args = { ... }
  return function(...) return f(unpack(args), ...) end
end

return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    'folke/trouble.nvim',
  },
  config = function()
    local telescope = require 'telescope'
    local actions = require 'telescope.actions'
    local themes = require 'telescope.themes'

    local open_with_trouble = require("trouble.sources.telescope").open

    -- TODO rework and hoist into the plugin spec
    local opts = {
      defaults = themes.get_dropdown {
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
      },

      pickers = {
        buffers = {
          sort_lastused = true,
          sort_mru = true,
        },
      },

      extensions = {
        ["ui-select"] = {
          themes.get_dropdown(),
        },
      },

    }

    telescope.setup(opts)
    telescope.load_extension('ui-select')
  end
}
