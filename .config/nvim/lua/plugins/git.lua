local mykeymap = require 'my.keymap'

return {
  'tpope/vim-fugitive',

  config = function()
    mykeymap.leader('n', 'Gg', ':G<cr>', { desc = 'Git Dashboard' })
    mykeymap.leader('n', 'GG', ':G<cr>', { desc = 'Git Dashboard' })
    mykeymap.leader('n', 'Gd', ':Gdiff<cr>', { desc = 'Git diff' })
    mykeymap.leader('n', 'Ga', ':G add %<cr>', { desc = 'Git add buffer' })
    mykeymap.leader('n', 'GA', ':G add --update<cr>', { desc = 'Git add update' })
    mykeymap.leader('n', 'Gr', ':G reset<cr>', { desc = 'Git reset' })
    mykeymap.leader('n', 'Gb', ':G blame<cr>', { desc = 'Git blame' })
    mykeymap.leader('n', 'Gc', ':G commit<cr>', { desc = 'Git commmit' })
    mykeymap.leader('n', 'GC', ':G commit --amend<cr>', { desc = 'Git commmit amend' })
    mykeymap.leader('n', 'Go',
      -- TODO implement a function that avoids clobbering the default register
      'yaw:Gsplit <C-r>"<cr>', { desc = 'Git open object' })
  end
}
