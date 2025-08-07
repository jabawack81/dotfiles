-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- CreatePR keymap - opens GitHub PR creation page
vim.keymap.set("n", "<leader>gp", "<cmd>CreatePR<cr>", { desc = "Create GitHub PR" })
