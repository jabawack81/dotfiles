-- Temporary fix for mason-lspconfig.mappings issue
return {
  {
    "neovim/nvim-lspconfig",
    priority = 1000,
    init = function()
      -- Create a compatibility layer for the missing mappings module before LazyVim tries to use it
      local ok = pcall(require, "mason-lspconfig.mappings")
      if not ok then
        local server = require("mason-lspconfig.mappings.server")
        local filetype = require("mason-lspconfig.mappings.filetype")
        local language = require("mason-lspconfig.mappings.language")
        
        package.loaded["mason-lspconfig.mappings"] = {
          server = server,
          filetype = filetype,
          language = language,
          -- Add compatibility function that LazyVim expects
          get_mason_map = function()
            return {
              lspconfig_to_package = server.lspconfig_to_package or {},
              package_to_lspconfig = server.package_to_lspconfig or {},
            }
          end,
        }
      end
    end,
  },
}