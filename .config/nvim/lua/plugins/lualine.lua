return {
  'nvim-lualine/lualine.nvim',
  opts = {
    options = {
      icons_enabled = true,
      theme = 'auto',
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
      always_divide_middle = false,
      globalstatus = false,
      refresh = {
        statusline = 1000,
        tabline = 1000,
        winbar = 1000,
      }
    },
    sections = {
      lualine_a = {
        {
          'filename',
          newfile_status = true,
          file_status = true,
          path = 1, -- relative path
        },
      },
      lualine_b = {
        'filesize',
        'encoding',
        'fileformat',
      },
      lualine_c = {
        'searchcount',
        'diagnostics',
      },
      lualine_x = {
        'branch',
        'diff',
      },
      lualine_y = {
        'progress',
        'location',
      },
      lualine_z = {
        'mode',
      }
    },
    inactive_sections = {
      lualine_a = {
        {
          'filename',
          newfile_status = true,
          file_status = true,
          path = 1, -- relative path
        },
      },
      lualine_b = {
      },
      lualine_c = {
        'searchcount',
        'diagnostics',
      },
      lualine_x = {
      },
      lualine_y = {
        'location',
      },
      lualine_z = {
      }
    },
  },
}
