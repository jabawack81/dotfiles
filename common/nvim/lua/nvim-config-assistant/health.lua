local M = {}

local health = vim.health or require("health")
local start = health.start or health.report_start
local ok = health.ok or health.report_ok
local warn = health.warn or health.report_warn
local error = health.error or health.report_error

function M.check()
  start("nvim-config-assistant")
  
  -- Check Neovim version
  if vim.fn.has("nvim-0.7.0") == 1 then
    ok("Neovim version is 0.7.0 or higher")
  else
    error("Neovim version 0.7.0 or higher is required")
  end
  
  -- Check plenary dependency
  local has_plenary = pcall(require, "plenary.curl")
  if has_plenary then
    ok("plenary.nvim is installed")
  else
    error("plenary.nvim is required but not found", {
      "Install with your plugin manager:",
      "  Lazy: { 'nvim-lua/plenary.nvim' }",
      "  Packer: use 'nvim-lua/plenary.nvim'",
    })
  end
  
  -- Check configuration
  local config = require("nvim-config-assistant").config
  if config then
    ok("Configuration loaded")
    
    -- Check API key
    local api_key = vim.env[config.api_key_env]
    if api_key then
      ok(string.format("%s environment variable is set", config.api_key_env))
    else
      warn(string.format("%s environment variable is not set", config.api_key_env), {
        "Set your API key:",
        string.format("  export %s='your-api-key-here'", config.api_key_env),
      })
    end
    
    -- Check LLM provider
    if config.llm_provider == "openai" or config.llm_provider == "anthropic" then
      ok(string.format("LLM provider '%s' is valid", config.llm_provider))
    else
      error(string.format("Invalid LLM provider: %s", config.llm_provider))
    end
  else
    error("Configuration not loaded")
  end
  
  -- Check commands
  if vim.fn.exists(":ConfigAssistant") == 2 then
    ok("Commands are available")
  else
    warn("Commands not registered")
  end
  
  -- Check keymaps
  local keymaps_set = false
  local maps = vim.api.nvim_get_keymap("n")
  for _, map in ipairs(maps) do
    if map.rhs and map.rhs:match("nvim%-config%-assistant") then
      keymaps_set = true
      break
    end
  end
  
  if keymaps_set then
    ok("Keymaps are configured")
  else
    warn("No keymaps detected", {
      "You may need to call setup():",
      "  require('nvim-config-assistant').setup()",
    })
  end
end

return M