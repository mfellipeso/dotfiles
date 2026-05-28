-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter", "VimResized", "WinResized" }, {
  group = vim.api.nvim_create_augroup("transparent_overrides", { clear = true }),
  callback = function()
    local groups = {
      "Normal",
      "NormalNC",
      "NormalFloat",
      "FloatBorder",
      "FloatTitle",
      "SignColumn",
      "EndOfBuffer",
      "TabLine",
      "TabLineFill",
      "TabLineSel",
      "WinBar",
      "WinBarNC",
      "BufferLineFill",
      "BufferLineBackground",
      "BufferLineBufferVisible",
      "BufferLineBufferSelected",
      "BufferLineSeparator",
      "BufferLineSeparatorVisible",
      "BufferLineSeparatorSelected",
      "BufferLineIndicator",
      "BufferLineIndicatorVisible",
      "BufferLineIndicatorSelected",
      "BufferLineCloseButton",
      "BufferLineCloseButtonVisible",
      "BufferLineCloseButtonSelected",
      "BufferLineModified",
      "BufferLineModifiedVisible",
      "BufferLineModifiedSelected",
      "BufferLineDuplicate",
      "BufferLineDuplicateVisible",
      "BufferLineDuplicateSelected",
      "BufferLineNumbers",
      "BufferLineNumbersVisible",
      "BufferLineNumbersSelected",
      "BufferLineTab",
      "BufferLineTabSelected",
      "BufferLineTabClose",
      "BufferLineOffset",
      "BufferLineOffsetSeparator",
      "SnacksNormal",
      "SnacksNormalNC",
      "SnacksWinBar",
      "SnacksWinBarNC",
      "SnacksDashboardNormal",
      "SnacksPicker",
      "SnacksPickerBorder",
      "SnacksPickerTitle",
      "SnacksPickerFooter",
      "SnacksPickerInput",
      "SnacksPickerInputBorder",
      "SnacksPickerInputTitle",
      "SnacksPickerList",
      "SnacksPickerListBorder",
      "SnacksPickerListTitle",
      "SnacksPickerPreview",
      "SnacksPickerPreviewBorder",
      "SnacksPickerPreviewTitle",
      "SnacksPickerCursorLine",
      "SnacksExplorerDir",
      "SnacksExplorerFile",
      "NeoTreeNormal",
      "NeoTreeNormalNC",
      "NeoTreeEndOfBuffer",
    }
    for _, g in ipairs(groups) do
      vim.api.nvim_set_hl(0, g, { bg = "none" })
    end
  end,
})
