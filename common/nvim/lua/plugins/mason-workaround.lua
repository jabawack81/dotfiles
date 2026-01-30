-- ============================================================================
-- Mason Version Pinning Workaround
-- ============================================================================
-- This file pins Mason and mason-lspconfig to v1.x versions to avoid
-- breaking changes introduced in Mason 2.0.
--
-- PROBLEM:
--   Mason 2.0 (released May 2025) restructured internal modules, breaking
--   compatibility with LazyVim's LSP configuration. Specifically, the module
--   'mason-lspconfig.mappings' was removed/restructured, causing errors like:
--
--     module 'mason-lspconfig.mappings' not found
--
-- SOLUTION:
--   Pin to the last stable v1.x releases until LazyVim updates to support
--   Mason 2.0. This is a temporary workaround.
--
-- WHEN TO REMOVE:
--   Check https://github.com/LazyVim/LazyVim/issues/6039 for updates.
--   Once LazyVim adds Mason 2.0 support, you can delete this file and
--   run :Lazy sync to upgrade to the latest Mason versions.
--
-- NOTE ON PLUGIN UPDATES:
--   When Lazy shows updates available for mason.nvim or mason-lspconfig.nvim,
--   DO NOT update them while this workaround is in place. Updating will
--   override the version pins and cause errors.
--
-- RELATED FILES:
--   - This workaround replaces the need for fix-mason.lua compatibility shim
--   - The version pins ensure the correct module structure exists
-- ============================================================================

return {
  -- Pin mason.nvim to version 1.11.0 (last v1.x release)
  -- This is the core package manager for LSP servers, linters, formatters
  {
    "mason-org/mason.nvim",
    version = "1.11.0", -- Pinned to avoid Mason 2.0 breaking changes
  },

  -- Pin mason-lspconfig.nvim to version 1.32.0 (last v1.x release)
  -- This bridges Mason with nvim-lspconfig for automatic LSP setup
  {
    "mason-org/mason-lspconfig.nvim",
    version = "1.32.0", -- Pinned to maintain compatibility with LazyVim
  },
}
