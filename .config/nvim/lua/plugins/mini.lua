local mykeymap = require 'my.keymap'

-- TODO decompose this into further sub-modules

return {
  "echasnovski/mini.nvim",
  config = function()

    local mini_starter = require('mini.starter')
    mini_starter.setup {}
    mykeymap.leader('n', ':', mini_starter.open)

    local mini_sessions = require('mini.sessions')
    mini_sessions.setup {
      autoread = true,
    }
    mykeymap.leader('n', 'Sc', function()
      vim.ui.input({
        prompt = 'Create new session named: ',
        default = vim.fs.basename(vim.fn.getcwd()),
      }, function(session_name)
        if session_name ~= nil then
          mini_sessions.write(session_name, {})
        end
      end)
    end)
    mykeymap.leader('n', 'Sr', function() mini_sessions.select('read', {}) end)
    mykeymap.leader('n', 'Sw', function() mini_sessions.select('write', {}) end)
    mykeymap.leader('n', 'Sd', function() mini_sessions.select('delete', {}) end)

    local mini_trailspace = require('mini.trailspace')
    mini_trailspace.setup {}
    mykeymap.leader('n', 'ts', mini_trailspace.trim)

    require('mini.comment').setup {}

    require('mini.surround').setup {}

    require('mini.fuzzy').setup {}

    require('mini.statusline').setup {}

  end
}
