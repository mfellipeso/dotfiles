return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        explorer = {
          -- Keep the explorer, but hide the search/input bar at the top.
          layout = {
            preset = "sidebar",
            preview = false,
            hidden = { "input" },
          },
        },
      },
    },
  },
  keys = {
    -- <leader>e always opens the explorer at the project (git) root, instead
    -- of the LSP/cwd root that LazyVim uses by default.
    {
      "<leader>e",
      function()
        Snacks.explorer({ cwd = LazyVim.root.git() })
      end,
      desc = "Explorer (project root)",
    },
  },
}
