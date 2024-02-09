local mykeymap = require 'my.keymap'

local bind = function(f, ...)
  local args = { ... }
  return function(...) return f(unpack(args), ...) end
end

local tmap = require('my.terminal').keymap

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
    local telescopes = require 'telescope.builtin'
    local actions = require 'telescope.actions'
    local themes = require 'telescope.themes'

    local open_with_trouble = require('trouble.providers.telescope').open_with_trouble

    -- TODO rework and hoist into the plugin spec
    local opts = {
      defaults = themes.get_ivy {
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

    mykeymap.leader('n', 's.', telescopes.resume, { desc = 'resume last search' })

    local other_buffer = bind(telescopes.buffers, { ignore_current_buffer = true })
    mykeymap.leader('n', '<Space>', other_buffer, { desc = 'search buffers' })
    tmap('<Space>', other_buffer, { desc = 'search buffers' })

    mykeymap.leader('n', 'sf', bind(telescopes.find_files, {
      previewer = false,
      hidden = true,
      no_ignore = true,
    }), { desc = 'search files' })

    mykeymap.leader('n', 'sh', telescopes.help_tags, { desc = 'search help' })
    mykeymap.leader('n', 'sm', telescopes.man_pages, { desc = 'search man pages' })

    mykeymap.leader('n', 'sb', telescopes.current_buffer_fuzzy_find, { desc = 'search in current buffer' })

    mykeymap.leader('n', 'ss', telescopes.grep_string, { desc = 'grep string search' })
    mykeymap.leader('n', 'sg', telescopes.live_grep, { desc = 'live grep search' })

    mykeymap.leader('n', 'so', telescopes.oldfiles, { desc = 'search old files' })
    mykeymap.leader('n', 'st', telescopes.treesitter, { desc = 'search syntax tree' })
    mykeymap.leader('n', 'sd', telescopes.diagnostics, { desc = 'search diagnostics' })
  end
}
