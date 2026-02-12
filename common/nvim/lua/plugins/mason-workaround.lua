-- ============================================================================
-- Mason Compatibility Shim
-- ============================================================================
-- Creates a compatibility layer for mason-lspconfig.mappings module.
--
-- PROBLEM:
--   LazyVim's LSP config calls: require("mason-lspconfig.mappings").get_mason_map()
--   But mason-lspconfig v1.32.0 has mappings as a directory (mappings/server.lua,
--   mappings/filetype.lua) without an init.lua, so the require fails.
--
-- SOLUTION:
--   This shim creates the expected module structure by loading the submodules
--   and providing the get_mason_map() function that LazyVim expects.
--
-- WHEN TO REMOVE:
--   When LazyVim updates to properly support newer mason-lspconfig versions.
--   Check: https://github.com/LazyVim/LazyVim/issues/6039
-- ============================================================================

return {
  {
    "neovim/nvim-lspconfig",
    priority = 1000, -- Load early to set up the shim before LazyVim needs it
    init = function()
      -- Only create the shim if the mappings module doesn't exist
      local ok = pcall(require, "mason-lspconfig.mappings")
      if not ok then
        -- Try to load the submodules
        local has_server, server = pcall(require, "mason-lspconfig.mappings.server")

        if has_server then
          -- Create the compatibility module
          package.loaded["mason-lspconfig.mappings"] = {
            server = server,
            -- Provide the get_mason_map function that LazyVim expects
            get_mason_map = function()
              return {
                lspconfig_to_package = server.lspconfig_to_package or {},
                package_to_lspconfig = server.package_to_lspconfig or {},
              }
            end,
          }
        end
      end
    end,
  },
}
