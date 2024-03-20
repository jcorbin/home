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

local showmacro_mess = ''
local showmacro_pending
local showmacro_linger = 1000
local function showmacro_notify(mess)
  if showmacro_pending then
    showmacro_pending:stop()
    showmacro_pending = nil
  end
  showmacro_mess = mess
  if showmacro_mess ~= '' then
    showmacro_pending = vim.defer_fn(function()
      showmacro_mess = ''
    end, showmacro_linger)
  end
  return showmacro_mess
end

local last_recording = ''
local last_recorded = ''
local function showmacro()
  local rec = vim.fn.reg_recording()
  if rec ~= '' then
    last_recording = rec
    last_recorded = ''
    return 'Recording @' .. last_recording
  end

  local exe = vim.fn.reg_executing()
  if exe ~= '' then
    return 'Executing @' .. exe
  end

    if last_recording ~= '' and last_recorded == '' then
    last_recorded = vim.fn.reg_recorded()
    if last_recorded ~= '' then
      showmacro_notify('Recorded @' .. last_recorded)
    end
  end

  return showmacro_mess
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
      lualine_z = { showmacro, 'mode' }
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
