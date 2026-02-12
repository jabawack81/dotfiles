-- ============================================================================
-- LSP Extra Keybindings
-- ============================================================================
-- Additional keybindings not provided by LazyVim defaults.
-- Navigation (gd, gr, gI, gy), hover (K, gK), code actions, rename,
-- and diagnostics navigation are all handled by LazyVim with FzfLua.
--
-- This file only adds:
--   - <F2> for rename (IDE convention)
--   - <leader>cd for line diagnostics
--   - Workspace folder management
--   - LSP management (restart, info, logs)
-- ============================================================================

return {
  {
    "neovim/nvim-lspconfig",

    keys = {
      -- Rename symbol (F2 - common IDE convention)
      { "<F2>", vim.lsp.buf.rename, desc = "Rename" },

      -- Show diagnostics for the current line in a floating window
      { "<leader>cd", vim.diagnostic.open_float, desc = "Line Diagnostics" },

      -- Workspace folder management
      {
        "<leader>cw",
        function()
          vim.lsp.buf.add_workspace_folder()
        end,
        desc = "Add Workspace Folder",
      },
      {
        "<leader>cW",
        function()
          vim.lsp.buf.remove_workspace_folder()
        end,
        desc = "Remove Workspace Folder",
      },

      -- LSP management
      { "<leader>cR", "<cmd>LspRestart<cr>", desc = "Restart LSP" },
      { "<leader>cI", "<cmd>LspInfo<cr>", desc = "LSP Info" },
      { "<leader>cL", "<cmd>LspLog<cr>", desc = "LSP Log" },
    },
  },
}
