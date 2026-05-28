-- No Omarchy, carrega o tema atual (gruvbox, etc.) dinamicamente.
-- Fora dele, cai no fallback tokyonight transparente abaixo.
local omarchy_theme = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")
if (vim.uv or vim.loop).fs_stat(omarchy_theme) then
  return dofile(omarchy_theme)
end

return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },

  -- enable 123 transparent on tokyonight
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
