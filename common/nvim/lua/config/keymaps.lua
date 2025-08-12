-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- CreatePR keymap - opens GitHub PR creation page
vim.keymap.set("n", "<leader>gp", "<cmd>CreatePR<cr>", { desc = "Create GitHub PR" })

-- Register viewing keymaps (using <leader>r for registers)
vim.keymap.set("n", "<leader>rr", "<cmd>reg<cr>", { desc = "Show all registers" })
vim.keymap.set("n", "<leader>rc", "<cmd>reg \"<cr>", { desc = "Show copy register" })
vim.keymap.set("n", "<leader>r+", "<cmd>reg +<cr>", { desc = "Show system clipboard" })
vim.keymap.set("n", "<leader>ry", "<cmd>reg 0<cr>", { desc = "Show yank register" })
