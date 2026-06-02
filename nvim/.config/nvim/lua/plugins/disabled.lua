return {
  -- disable inlay_hints
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    }
  },
}
