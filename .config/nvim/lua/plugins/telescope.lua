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

    vim.keymap.set('n', '<leader>s.', telescopes.resume, { desc = 'resume last search' })

    local other_buffer = bind(telescopes.buffers, { ignore_current_buffer = true })
    vim.keymap.set('n', '<leader><Space>', other_buffer, { desc = 'search buffers' })
    vim.keymap.set('t', '<C-\\><Space>', other_buffer, { desc = 'search buffers' })

    vim.keymap.set('n', '<leader>sf', bind(telescopes.find_files, {
      previewer = false,
      hidden = true,
      no_ignore = true,
    }), { desc = 'search files' })

    vim.keymap.set('n', '<leader>sc', bind(telescopes.find_files, {
      cwd = vim.fs.dirname(vim.env.MYVIMRC),
      previewer = false,
      hidden = true,
      no_ignore = true,
    }), { desc = 'search files near $MYVIMRC' })

    vim.keymap.set('n', '<leader>sl', bind(telescopes.find_files, {
      cwd = vim.fn.stdpath('data'),
      previewer = false,
      hidden = true,
      no_ignore = true,
    }), { desc = 'search files near $MYVIMRC' })

    vim.keymap.set('n', '<leader>sh', telescopes.help_tags, { desc = 'search help' })
    vim.keymap.set('n', '<leader>sm', telescopes.man_pages, { desc = 'search man pages' })

    vim.keymap.set('n', '<leader>sb', telescopes.current_buffer_fuzzy_find, { desc = 'search in current buffer' })

    vim.keymap.set('n', '<leader>ss', telescopes.grep_string, { desc = 'grep string search' })
    vim.keymap.set('n', '<leader>sg', telescopes.live_grep, { desc = 'live grep search' })

    vim.keymap.set('n', '<leader>so', telescopes.oldfiles, { desc = 'search old files' })
    vim.keymap.set('n', '<leader>st', telescopes.treesitter, { desc = 'search syntax tree' })
    vim.keymap.set('n', '<leader>sd', telescopes.diagnostics, { desc = 'search diagnostics' })
  end
}
