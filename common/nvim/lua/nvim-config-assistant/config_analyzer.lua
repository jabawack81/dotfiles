local M = {}

local function read_file(path)
  local file = io.open(path, "r")
  if not file then return nil end
  local content = file:read("*all")
  file:close()
  return content
end

local function get_keymaps()
  local keymaps = {}
  local modes = {"n", "i", "v", "x", "s", "o", "t"}
  
  for _, mode in ipairs(modes) do
    local maps = vim.api.nvim_get_keymap(mode)
    for _, map in ipairs(maps) do
      if map.lhs and map.rhs then
        table.insert(keymaps, string.format("%s mode: %s -> %s", mode, map.lhs, map.rhs or map.callback and "<function>" or ""))
      end
    end
  end
  
  return keymaps
end

local function get_lsp_servers()
  local servers = {}
  local clients = vim.lsp.get_active_clients()
  
  for _, client in ipairs(clients) do
    table.insert(servers, client.name)
  end
  
  return servers
end

local function get_loaded_plugins()
  local plugins = {}
  
  -- Check for lazy.nvim
  if vim.fn.exists("*LazyStats") == 1 then
    local lazy_stats = require("lazy").stats()
    table.insert(plugins, string.format("Plugin manager: lazy.nvim (loaded: %d)", lazy_stats.loaded))
  end
  
  -- Get loaded modules
  for name, _ in pairs(package.loaded) do
    if name:match("^[^._]") and not name:match("^vim") then
      table.insert(plugins, name)
    end
  end
  
  return plugins
end

function M.get_context(include_errors)
  local context_parts = {}
  
  -- Basic info
  table.insert(context_parts, "Neovim version: " .. vim.fn.execute("version"):match("NVIM v[^\n]+"))
  
  -- Configuration framework
  local config_path = vim.fn.stdpath("config")
  local lazyvim_json = read_file(config_path .. "/lazyvim.json")
  if lazyvim_json then
    table.insert(context_parts, "Configuration framework: LazyVim")
    
    -- Parse extras
    local ok, json_data = pcall(vim.json.decode, lazyvim_json)
    if ok and json_data.extras then
      table.insert(context_parts, "LazyVim extras: " .. table.concat(json_data.extras, ", "))
    end
  end
  
  -- LSP servers
  local lsp_servers = get_lsp_servers()
  if #lsp_servers > 0 then
    table.insert(context_parts, "Active LSP servers: " .. table.concat(lsp_servers, ", "))
  end
  
  -- Key diagnostics keymaps
  local diagnostic_maps = {
    ["]d"] = "Next diagnostic",
    ["[d"] = "Previous diagnostic",
    ["<leader>cd"] = "Line diagnostics",
    ["<leader>cl"] = "LSP info",
  }
  
  local keymap_info = {}
  for key, desc in pairs(diagnostic_maps) do
    table.insert(keymap_info, string.format("%s: %s", key, desc))
  end
  table.insert(context_parts, "Common diagnostic keymaps:\n" .. table.concat(keymap_info, "\n"))
  
  -- Loaded plugins summary
  local plugins = get_loaded_plugins()
  if #plugins > 5 then
    table.insert(context_parts, string.format("Loaded plugins/modules: %d total", #plugins))
  else
    table.insert(context_parts, "Loaded plugins: " .. table.concat(plugins, ", "))
  end
  
  -- Include error context if requested
  if include_errors then
    local error_context = require("nvim-config-assistant.error_tracker").get_error_context()
    if error_context and error_context ~= "" then
      table.insert(context_parts, "\n" .. error_context)
    end
  end
  
  return table.concat(context_parts, "\n\n")
end

return M