-- ============================================================================
-- LSP Keybindings Configuration
-- ============================================================================
-- This file configures keybindings for Language Server Protocol (LSP)
-- features. LSP provides IDE-like functionality: go to definition,
-- find references, rename symbols, code actions, and diagnostics.
--
-- WHY CUSTOM KEYBINDINGS?
--   LazyVim provides defaults, but this config:
--   1. Uses Telescope for navigation (nicer fuzzy-finding UI)
--   2. Adds extra keybindings for LSP management (restart, logs)
--   3. Groups everything under <leader>c for discoverability
--
-- KEYBINDING CONVENTIONS:
--   <leader>c  = Code-related actions (via which-key group)
--   g*         = "Go to" navigation (gd, gr, gI, gy)
--   [* / ]*    = Previous/Next navigation (diagnostics)
--   K          = Hover documentation (vim convention)
--
-- REQUIREMENTS:
--   - An LSP server must be running for the current file type
--   - Check :LspInfo to see if LSP is attached
--   - Use :Mason to install language servers
-- ============================================================================

return {
  -- ==========================================================================
  -- Which-key Group Registration
  -- ==========================================================================
  -- Register the <leader>c prefix as the "code" group in which-key.
  -- This makes all code-related keybindings discoverable when you press
  -- <leader> and see the available groups.
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>c", group = "code" },
      },
    },
  },

  -- ==========================================================================
  -- LSP Keybindings
  -- ==========================================================================
  {
    "neovim/nvim-lspconfig",

    -- Telescope is required for the navigation keybindings (gd, gr, etc.)
    -- It provides a fuzzy-finder UI for selecting from multiple results
    dependencies = {
      { "nvim-telescope/telescope.nvim" },
    },

    keys = {
      -- ======================================================================
      -- CODE ACTIONS
      -- ======================================================================
      -- Code actions are context-aware suggestions from the LSP server.
      -- Examples: extract variable, add import, fix lint error, etc.

      -- Show all available code actions for current position
      -- Works in normal mode (cursor position) and visual mode (selection)
      {
        "<leader>ca",
        vim.lsp.buf.code_action,
        desc = "Code Action",
        mode = { "n", "v" },
      },

      -- Show only "source" actions (organize imports, fix all, etc.)
      -- Filters out quick-fixes to show only file-wide actions
      {
        "<leader>cA",
        function()
          vim.lsp.buf.code_action({
            context = {
              only = { "source" },
              diagnostics = {},
            },
          })
        end,
        desc = "Source Action",
      },

      -- ======================================================================
      -- RENAME
      -- ======================================================================
      -- Rename a symbol across all files in the project.
      -- The LSP server handles finding all references and updating them.

      -- Rename symbol under cursor (leader key version)
      { "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },

      -- Rename symbol under cursor (F2 - common IDE convention)
      { "<F2>", vim.lsp.buf.rename, desc = "Rename" },

      -- ======================================================================
      -- NAVIGATION (using Telescope for UI)
      -- ======================================================================
      -- These keybindings use Telescope to show results in a fuzzy-finder.
      -- reuse_win = true: If definition is in another file, reuse current window

      -- Go to where the symbol is defined
      -- Example: cursor on function call -> jump to function definition
      {
        "gd",
        function()
          require("telescope.builtin").lsp_definitions({ reuse_win = true })
        end,
        desc = "Goto Definition",
      },

      -- Find all places where the symbol is referenced/used
      -- Example: cursor on variable -> see everywhere it's used
      {
        "gr",
        "<cmd>Telescope lsp_references<cr>",
        desc = "References",
        nowait = true, -- Don't wait for additional keys
      },

      -- Go to the implementation (for interfaces/abstract methods)
      -- Example: cursor on interface method -> see concrete implementations
      {
        "gI",
        function()
          require("telescope.builtin").lsp_implementations({ reuse_win = true })
        end,
        desc = "Goto Implementation",
      },

      -- Go to the type definition
      -- Example: cursor on variable -> jump to its type/class definition
      {
        "gy",
        function()
          require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
        end,
        desc = "Goto Type Definition",
      },

      -- ======================================================================
      -- HOVER AND SIGNATURE HELP
      -- ======================================================================
      -- Display documentation and type information without navigating away

      -- Show hover documentation for symbol under cursor
      -- Displays type, documentation, and other info in a floating window
      { "K", vim.lsp.buf.hover, desc = "Hover" },

      -- Show function signature help (parameter info)
      -- Useful when writing function calls to see expected arguments
      { "gK", vim.lsp.buf.signature_help, desc = "Signature Help" },

      -- Signature help in insert mode (while typing function arguments)
      { "<C-k>", vim.lsp.buf.signature_help, mode = "i", desc = "Signature Help" },

      -- ======================================================================
      -- DIAGNOSTICS
      -- ======================================================================
      -- Navigate through errors, warnings, and other diagnostic messages.
      -- Diagnostics are the squiggly lines and gutter signs.

      -- Show diagnostics for the current line in a floating window
      { "<leader>cd", vim.diagnostic.open_float, desc = "Line Diagnostics" },

      -- Jump to next/previous diagnostic (any severity)
      {
        "]d",
        function()
          vim.diagnostic.goto_next()
        end,
        desc = "Next Diagnostic",
      },
      {
        "[d",
        function()
          vim.diagnostic.goto_prev()
        end,
        desc = "Prev Diagnostic",
      },

      -- Jump to next/previous ERROR only (skip warnings/hints)
      {
        "]e",
        function()
          vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
        end,
        desc = "Next Error",
      },
      {
        "[e",
        function()
          vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
        end,
        desc = "Prev Error",
      },

      -- Jump to next/previous WARNING only
      {
        "]w",
        function()
          vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
        end,
        desc = "Next Warning",
      },
      {
        "[w",
        function()
          vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
        end,
        desc = "Prev Warning",
      },

      -- ======================================================================
      -- WORKSPACE FOLDERS
      -- ======================================================================
      -- LSP servers can work with multiple project folders (workspaces).
      -- Useful for monorepos or when working across related projects.

      -- Add a folder to the LSP workspace
      {
        "<leader>cw",
        function()
          vim.lsp.buf.add_workspace_folder()
        end,
        desc = "Add Workspace Folder",
      },

      -- Remove a folder from the LSP workspace
      {
        "<leader>cW",
        function()
          vim.lsp.buf.remove_workspace_folder()
        end,
        desc = "Remove Workspace Folder",
      },

      -- List all workspace folders
      {
        "<leader>cl",
        function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end,
        desc = "List Workspace Folders",
      },

      -- ======================================================================
      -- LSP MANAGEMENT
      -- ======================================================================
      -- Commands for debugging and managing the LSP server itself

      -- Restart the LSP server (useful when it gets stuck or misconfigured)
      { "<leader>cR", "<cmd>LspRestart<cr>", desc = "Restart LSP" },

      -- Show info about attached LSP servers for current buffer
      { "<leader>cI", "<cmd>LspInfo<cr>", desc = "LSP Info" },

      -- Show LSP server logs (useful for debugging issues)
      { "<leader>cL", "<cmd>LspLog<cr>", desc = "LSP Log" },
    },
  },
}
