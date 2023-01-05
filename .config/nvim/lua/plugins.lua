local packer_github = 'wbthomason/packer.nvim'

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/' .. packer_github, install_path }
    vim.cmd 'packadd packer.nvim'
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  pattern = 'plugins.lua',
  callback = function(event)
    dofile(event.file)
    vim.cmd 'PackerSync'
  end
})

return require('packer').startup { function(use)
  use { packer_github }

  if packer_bootstrap then
    require('packer').sync()
  end
end, config = {
  display = {
    prompt_border = 'none',
    open_fn = function()
      return require('packer.util').float { border = 'none' }
    end,
  },
} }

-- vim: set ts=2 sw=2 foldmethod=marker:
