-- prettier toast-style notifications
return {
  'rcarriga/nvim-notify',
  lazy = false,
  opts = {
    render = 'minimal',
    timeout = 3000,
    top_down = false,
  },
  config = function(_, opts)
    local notify = require('notify')
    notify.setup(opts)
    vim.notify = notify
  end
}
