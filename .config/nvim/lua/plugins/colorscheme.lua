return {

  -- TODO investigate [dashboard.nvim](https://github.com/nvimdev/dashboard-nvim) 
  -- TODO investigate [snacks.dashboard](https://github.com/folke/snacks.nvim/blob/main/docs/dashboard.md)

  {
    -- Carbonfox: matches the Ghostty terminal theme for a cohesive look.
    -- transparent = true so the terminal's background (and its opacity) shows through.
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      options = {
        transparent = true,
        terminal_colors = true,
        styles = {
          comments = "italic",
          keywords = "italic",
        },
      },
    },
  },

}
