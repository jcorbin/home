-- useful showcmd analog when using cmdheight=0 (like with noice.nvim)
local ns = vim.api.nvim_create_namespace('showcmd_msg')

local last_showcmd_msg = '⋯'
local last_showcmd_pending
local last_showcmd_linger = 1000

vim.ui_attach(ns, { ext_messages = true }, function(event, ...)
  if event == 'msg_showcmd' then
    local content = ...

    if last_showcmd_pending then
      last_showcmd_pending:stop()
      last_showcmd_pending = nil
    end

    if #content > 0 then
      local it = vim.iter(content)
      it:map(function(tup) return tup[2] end)
      last_showcmd_msg = it:join('')
    else
      last_showcmd_pending = vim.defer_fn(function()
        last_showcmd_msg = '⋯'
      end, last_showcmd_linger)
    end
  end
end)
local function showcmd()
  return last_showcmd_msg
end

local filename = {
  'filename',
  newfile_status = true,
  file_status = true,
  path = 1, -- relative path
}

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
      lualine_a = { filename },
      lualine_b = { 'location' },
      lualine_c = { 'diagnostics' },
      lualine_x = { 'branch', 'diff' },
      lualine_y = { showcmd },
      lualine_z = { 'mode' }
    },
    inactive_sections = {
      lualine_a = { filename },
      lualine_b = { 'location' },
      lualine_c = { 'diagnostics' },
      lualine_x = { 'branch', 'diff' },
      lualine_y = {},
      lualine_z = {},
    },

    winbar = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {}
    },
    inactive_winbar = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {}
    },

  },
}
