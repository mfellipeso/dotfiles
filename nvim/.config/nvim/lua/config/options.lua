-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.fixendofline = true

-- Path absoluto
vim.api.nvim_create_user_command("CopyAbsPath", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.notify("Copied absolute path to clipboard!")
end, {})

-- Path relativo (sua versão)
vim.api.nvim_create_user_command("CopyRelPath", function()
  local rel_path = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  vim.fn.setreg("+", rel_path)
  vim.notify('Copied relative path "' .. rel_path .. '" to clipboard!')
end, {})
