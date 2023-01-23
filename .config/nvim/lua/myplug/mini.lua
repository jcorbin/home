-- TODO decompose this into further sub-modules

return {
  "echasnovski/mini.nvim",
  config = function()

    local mykeymap = require 'my.keymap'

    require('mini.starter').setup {}
    mykeymap.leader('n', ':', MiniStarter.open)

    require('mini.sessions').setup {
      autoread = true,
    }
    mykeymap.leader('n', 'Sc', function()
      vim.ui.input({
        prompt = 'Create new session named: ',
        default = vim.fs.basename(vim.fn.getcwd()),
      }, function(session_name)
        if session_name ~= nil then
          MiniSessions.write(session_name, {})
        end
      end)
    end)
    mykeymap.leader('n', 'Sr', function() MiniSessions.select('read', {}) end)
    mykeymap.leader('n', 'Sw', function() MiniSessions.select('write', {}) end)
    mykeymap.leader('n', 'Sd', function() MiniSessions.select('delete', {}) end)

    require('mini.trailspace').setup {}
    mykeymap.leader('n', 'ts', MiniTrailspace.trim)

    require('mini.comment').setup {}

    require('mini.surround').setup {}

    require('mini.fuzzy').setup {}

    require('mini.statusline').setup {}

  end
}
