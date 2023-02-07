local mykeymap = require 'my.keymap'

local augroup = require 'my.augroup'
local autocmd = augroup 'my.options'

local opt = vim.opt

opt.guifont = 'JetBrains Mono:h12'

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
opt.laststatus = 2
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

opt.completeopt = { 'menu', 'menuone', 'noselect' }

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
end

-- option toggles
mykeymap.opt_toggle('<leader>ci', 'ignorecase')
mykeymap.opt_toggle('<leader>ln', 'number')
mykeymap.opt_toggle('<leader>rc', 'relativenumber')
mykeymap.opt_toggle('<leader>cl', 'cursorline')
mykeymap.opt_toggle('<leader>cc', 'cursorcolumn')
mykeymap.opt_toggle('<leader>lw', 'wrap')
mykeymap.opt_toggle('<leader>sp', 'spell')
