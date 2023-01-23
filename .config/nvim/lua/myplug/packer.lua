local github = 'wbthomason/packer.nvim'

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/' .. github, install_path }
    vim.cmd 'packadd packer.nvim'
    return true
  end
  return false
end

return function(spec)
  local auid = vim.api.nvim_create_augroup('MyPacker', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
    group = auid,
    pattern = 'plugins.lua',
    callback = function(event)
      dofile(event.file)
      vim.cmd('PackerSync')
    end
  })

  -- TODO: provide a PackerReload command/function
  --       maybe wire it up to myplug/*.lua write event

  local bootstrap = ensure_packer()

  local packer = require('packer')

  return packer.startup {
    function(use)
      use { github }

      if type(spec) == 'function' then
        spec(use)
      elseif type(spec) == 'table' then
        for _, v in ipairs(spec) do
          if type(v) == 'function' then
            v(use)
          else
            use(v)
          end
        end
      end

      if bootstrap then
        packer.sync()
      end
    end,
    config = {
      display = {
        prompt_border = 'none',
        open_fn = function()
          return require('packer.util').float { border = 'none' }
        end,
      },
    }
  }
end
