return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>c", group = "code" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "nvim-telescope/telescope.nvim" },
    },
    keys = {
        -- Code actions
        { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" } },
        { "<leader>cA", function()
          vim.lsp.buf.code_action({
            context = {
              only = { "source" },
              diagnostics = {},
            },
          })
        end, desc = "Source Action" },
        
        -- Rename
        { "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },
        { "<F2>", vim.lsp.buf.rename, desc = "Rename" },
        
        -- Navigation
        { "gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, desc = "Goto Definition" },
        { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References", nowait = true },
        { "gI", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, desc = "Goto Implementation" },
        { "gy", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, desc = "Goto Type Definition" },
        
        -- Hover and signature help
        { "K", vim.lsp.buf.hover, desc = "Hover" },
        { "gK", vim.lsp.buf.signature_help, desc = "Signature Help" },
        { "<C-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help" },
        
        -- Diagnostics
        { "<leader>cd", vim.diagnostic.open_float, desc = "Line Diagnostics" },
        { "]d", function() vim.diagnostic.goto_next() end, desc = "Next Diagnostic" },
        { "[d", function() vim.diagnostic.goto_prev() end, desc = "Prev Diagnostic" },
        { "]e", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, desc = "Next Error" },
        { "[e", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, desc = "Prev Error" },
        { "]w", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN }) end, desc = "Next Warning" },
        { "[w", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN }) end, desc = "Prev Warning" },
        
        -- Workspace
        { "<leader>cw", function() vim.lsp.buf.add_workspace_folder() end, desc = "Add Workspace Folder" },
        { "<leader>cW", function() vim.lsp.buf.remove_workspace_folder() end, desc = "Remove Workspace Folder" },
        { "<leader>cl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, desc = "List Workspace Folders" },
        
        -- LSP Management
        { "<leader>cR", "<cmd>LspRestart<cr>", desc = "Restart LSP" },
        { "<leader>cI", "<cmd>LspInfo<cr>", desc = "LSP Info" },
        { "<leader>cL", "<cmd>LspLog<cr>", desc = "LSP Log" },
    },
  },
}