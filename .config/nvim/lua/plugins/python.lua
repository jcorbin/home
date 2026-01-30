return {
  "linux-cultist/venv-selector.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "nvim-telescope/telescope.nvim",
  },
  ft = "python", -- Load when opening Python files
  opts = {
    search = {}, -- if you add your own searches, they go here.
    options = {} -- if you add plugin options, they go here.
  },
  event = 'VeryLazy', -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
  keys = {
    { "<leader>V", "<cmd>VenvSelect<cr>" }, -- Open picker on keymap
  },

  -- Pipenv found itself running within a virtual environment, so it will
  -- automatically use that environment, instead of creating its own for any
  -- project.
  -- You can set PIPENV_IGNORE_VIRTUALENVS=1 to force pipenv to ignore that
  -- environment and create its own instead. You can set PIPENV_VERBOSITY=-1 to
  -- suppress this warning.

}
