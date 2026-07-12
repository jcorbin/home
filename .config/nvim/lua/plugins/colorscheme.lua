return {

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
