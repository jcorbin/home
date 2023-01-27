local mykeymap = require 'my.keymap'

return {
  'tpope/vim-fugitive',

  config = function()
    mykeymap.leader('n', 'Gg', ':G<cr>')
    mykeymap.leader('n', 'GG', ':G<cr>')
    mykeymap.leader('n', 'Gd', ':Gdiff<cr>')
    mykeymap.leader('n', 'Ga', ':G add %<cr>')
    mykeymap.leader('n', 'GA', ':G add --update<cr>')
    mykeymap.leader('n', 'Gr', ':G reset<cr>')
    mykeymap.leader('n', 'Gb', ':G blame<cr>')
    mykeymap.leader('n', 'Gc', ':G commit<cr>')
    mykeymap.leader('n', 'GC', ':G commit --amend<cr>')
    mykeymap.leader('n', 'Go',
      -- TODO implement a function that avoids clobbering the default register
      'yaw:Gsplit <C-r>"<cr>')
  end
}
