-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Reload buffers changed outside Neovim (e.g. by Claude Code editing files directly).
-- LazyVim sets autoread, but Neovim only acts on it when something triggers a check —
-- without this you keep a stale buffer, and neotest never re-parses because its
-- discovery hooks BufAdd/BufWritePost.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermClose", "TermLeave" }, {
  group = vim.api.nvim_create_augroup("checktime_external_changes", { clear = true }),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})
