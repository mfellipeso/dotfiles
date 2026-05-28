return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },

  -- enable transparent on tokyonight
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
}
