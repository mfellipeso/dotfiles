return {
  -- { "folke/noice.nvim", enabled = false },
  { "nvim-treesitter/nvim-treesitter-textobjects", enabled = false },

  -- disable inlay_hints
  { "neovim/nvim-lspconfig", opts = {
    inlay_hints = { enabled = false },
  } },
}
