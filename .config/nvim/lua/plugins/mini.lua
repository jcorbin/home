-- TODO decompose this into further sub-modules

return {
  "echasnovski/mini.nvim",
  config = function()
    local mini_starter = require('mini.starter')
    mini_starter.setup {}
    vim.keymap.set('n', '<leader>:', mini_starter.open, { desc = 'Start screen' })

    local mini_sessions = require('mini.sessions')
    mini_sessions.setup {
      autoread = true,
    }
    vim.keymap.set('n', '<leader>Sc', function()
      vim.ui.input({
        prompt = 'Create new session named: ',
        default = vim.fs.basename(vim.fn.getcwd()),
      }, function(session_name)
        if session_name ~= nil then
          mini_sessions.write(session_name, {})
        end
      end)
    end, { desc = 'Create new session' })
    vim.keymap.set('n', '<leader>Sr', function() mini_sessions.select('read', {}) end, { desc = 'Read session' })
    vim.keymap.set('n', '<leader>Sw', function() mini_sessions.select('write', {}) end, { desc = 'Write session' })
    vim.keymap.set('n', '<leader>Sd', function() mini_sessions.select('delete', {}) end, { desc = 'Delete session' })

    require('mini.fuzzy').setup {}
  end
}
