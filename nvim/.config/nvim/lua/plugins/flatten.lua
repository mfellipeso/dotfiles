local TREE_FT = {
  ["neo-tree"] = true,
  ["snacks_layout_box"] = true,
  ["snacks_picker_list"] = true,
  ["snacks_picker_input"] = true,
  ["snacks_picker_preview"] = true,
  ["NvimTree"] = true,
  ["aerial"] = true,
  ["Outline"] = true,
  ["Trouble"] = true,
  ["trouble"] = true,
}

local function is_normal_file_win(win)
  local cfg = vim.api.nvim_win_get_config(win)
  if cfg.relative ~= "" then
    return false
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.bo[buf].buftype ~= "" then
    return false
  end
  if TREE_FT[vim.bo[buf].filetype] then
    return false
  end
  return true
end

local function is_protected_win(win)
  local cfg = vim.api.nvim_win_get_config(win)
  if cfg.relative ~= "" then
    return true
  end
  local buf = vim.api.nvim_win_get_buf(win)
  return TREE_FT[vim.bo[buf].filetype] == true
end

return {
  "willothy/flatten.nvim",
  lazy = false,
  priority = 1001,
  opts = {
    window = {
      open = function(opts)
        local target_buf = opts.files[1].bufnr
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if is_normal_file_win(win) then
            vim.api.nvim_set_current_win(win)
            vim.api.nvim_set_current_buf(target_buf)
            return win, target_buf
          end
        end
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if not is_protected_win(win) and vim.bo[vim.api.nvim_win_get_buf(win)].buftype ~= "terminal" then
            vim.api.nvim_set_current_win(win)
            vim.api.nvim_set_current_buf(target_buf)
            return win, target_buf
          end
        end
        vim.cmd("vsplit")
        local win = vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_buf(target_buf)
        return win, target_buf
      end,
    },
    hooks = {
      pre_open = function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local cfg = vim.api.nvim_win_get_config(win)
          local buf = vim.api.nvim_win_get_buf(win)
          if cfg.relative ~= "" and not TREE_FT[vim.bo[buf].filetype] then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
      end,
    },
    block_for = {
      gitcommit = true,
      gitrebase = true,
    },
  },
}
