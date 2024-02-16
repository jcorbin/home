-- prettier toast-style notifications
return {
  'rcarriga/nvim-notify',
  lazy = false,
  opts = {
    render = 'minimal',
    timeout = 3000,
  },
  config = function(_, opts)
    local notify = require('notify')
    notify.setup(opts)
    vim.notify = notify
  end
}
