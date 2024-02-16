local augroup = require 'my.augroup'
local autocmd = augroup 'my.options'

local opt = vim.opt

opt.guifont = 'JetBrains Mono:h14'

opt.termguicolors = true
opt.background = 'dark'

opt.shiftwidth = 2
opt.tabstop = 2
opt.expandtab = true

opt.breakindent = true

opt.cursorline = true

opt.mouse = 'a'
opt.scrolloff = 2

opt.incsearch = true
opt.smartcase = true

opt.virtualedit = 'all'
opt.updatetime = 250

opt.foldlevelstart = 1

-- TODO break this out into a zig-specific module
autocmd('FileType', {
  'zig',
}, 'setlocal commentstring=//\\ %s')

-- TODO listchars
-- opt.listchars = {
-- eol = '↲',
-- tab = '▸ ',
-- trail = '·',
-- extends
-- precedes
-- conceal
-- nbsp
-- }

opt.completeopt = { 'menuone', 'noselect' }

-- neovide specific config
if vim.g.neovide then
  vim.g.neovide_scale_factor = 1.0

  local scale_step = 0.05
  vim.keymap.set({ 'n' }, '<C-=>',
    function() vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * (1 + scale_step) end)
  vim.keymap.set({ 'n' }, '<C-->',
    function() vim.g.neovide_scale_factor = vim.g.neovide_scale_factor / (1 + scale_step) end)
  vim.keymap.set({ 'n' }, '<C-0>', function() vim.g.neovide_scale_factor = 1.0 end)

  vim.g.neovide_hide_mouse_when_typing = true

  vim.g.neovide_cursor_vfx_mode = 'railgun'
  vim.g.neovide_cursor_animation_length = 0.1

  vim.g.neovide_scroll_animation_length = 0.2

  vim.g.neovide_remember_window_size = false
  vim.g.neovide_remember_window_position = false
end

local opt_toggle = function(keys, name)
  vim.keymap.set('n', keys, function()
    if vim.opt[name]:get() then
      vim.opt[name] = false
      vim.notify('set no' .. name)
    else
      vim.opt[name] = true
      vim.notify('set ' .. name)
    end
  end, {
    desc = "toggle '" .. name .. "' option"
  })
end

-- option toggles
opt_toggle('<leader>ci', 'ignorecase')
opt_toggle('<leader>ln', 'number')
opt_toggle('<leader>rc', 'relativenumber')
opt_toggle('<leader>cl', 'cursorline')
opt_toggle('<leader>cc', 'cursorcolumn')
opt_toggle('<leader>lw', 'wrap')
opt_toggle('<leader>sp', 'spell')
