local filename = {
    'filename',
    newfile_status = true,
    file_status = true,
    path = 1, -- relative path
}

local function cwd()
  return vim.fn.getcwd()
end

return {
    'nvim-lualine/lualine.nvim',
    opts = {

        options = {
            icons_enabled = true,
            theme = 'auto',

            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },

            always_divide_middle = false,
            globalstatus = true,

            refresh = {
                statusline = 1000,
                tabline = 1000,
                winbar = 1000,
            }
        },

        sections = {
            lualine_a = {
                'mode',
            },
            lualine_b = {
            },
            lualine_c = {
            },
            lualine_x = {
                'diff',
            },
            lualine_y = {
                cwd,
            },
            lualine_z = {
                'branch',
            }
        },

        winbar = {
            lualine_a = {
                filename,
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
            },
            lualine_y = {
                'progress',
                'location',
            },
            lualine_z = {
            }
        },

        inactive_winbar = {
            lualine_a = {
                filename,
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
    config = function(_, opts)
      vim.opt.laststatus = 3
      vim.opt.cmdheight = 0
      require('lualine').setup(opts)
    end,
}
