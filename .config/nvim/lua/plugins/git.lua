return {
  'tpope/vim-fugitive',

  config = function()
    vim.keymap.set('n', '<leader>Gg', ':G<cr>', { desc = 'Git Dashboard' })
    vim.keymap.set('n', '<leader>GG', ':G<cr>', { desc = 'Git Dashboard' })
    vim.keymap.set('n', '<leader>Gd', ':Gdiff<cr>', { desc = 'Git diff' })
    vim.keymap.set('n', '<leader>Ga', ':G add %<cr>', { desc = 'Git add buffer' })
    vim.keymap.set('n', '<leader>GA', ':G add --update<cr>', { desc = 'Git add update' })
    vim.keymap.set('n', '<leader>Gr', ':G reset<cr>', { desc = 'Git reset' })
    vim.keymap.set('n', '<leader>Gb', ':G blame<cr>', { desc = 'Git blame' })
    vim.keymap.set('n', '<leader>Gc', ':G commit<cr>', { desc = 'Git commmit' })
    vim.keymap.set('n', '<leader>GC', ':G commit --amend<cr>', { desc = 'Git commmit amend' })
    vim.keymap.set('n', '<leader>Go',
      -- TODO implement a function that avoids clobbering the default register
      'yaw:Gsplit <C-r>"<cr>', { desc = 'Git open object' })
  end
}
