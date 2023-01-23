return {
  -- prettier toast-style notifications
  'rcarriga/nvim-notify',
  config = function()
    local notify = require('notify')
    notify.setup {
      stages = 'fade_in_slide_out',
      render = 'minimal',
      timeout = 3000,
    }
    vim.notify = notify
  end
}
