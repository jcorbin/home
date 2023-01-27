return {
  {
    'Mofiqul/vscode.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.vscode_style = 'dark'
      vim.cmd [[colorscheme vscode]]
    end
  },
  -- TODO restore optional/alternate colorschemes
  -- 'rktjmp/lush.nvim';
  -- 'tanvirtin/monokai.nvim';
  -- 'folke/tokyonight.nvim';
  -- 'shaunsingh/moonlight.nvim';
}
