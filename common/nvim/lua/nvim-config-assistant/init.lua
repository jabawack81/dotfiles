local M = {}

local api = vim.api
local fn = vim.fn

-- Default configuration
M.config = {
  llm_provider = "anthropic", -- or "openai"
  api_key_env = "ANTHROPIC_API_KEY", -- or "OPENAI_API_KEY"
  model = "claude-3-opus-20240229", -- or "gpt-4"
  keymaps = {
    open_prompt = "<leader>qa", -- qa for "question assistant"
    open_with_error = "<leader>qe", -- qe for "question error"
  },
  window = {
    width = 80,
    height = 3,
    border = "rounded",
  },
}

-- Setup function
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})
  
  -- Initialize error tracking
  require("nvim-config-assistant.error_tracker").setup()
  
  -- Set up keymaps
  if M.config.keymaps.open_prompt then
    vim.keymap.set("n", M.config.keymaps.open_prompt, function()
      require("nvim-config-assistant.ui").open_prompt()
    end, { desc = "Open config assistant prompt" })
  end
  
  if M.config.keymaps.open_with_error then
    vim.keymap.set("n", M.config.keymaps.open_with_error, function()
      require("nvim-config-assistant.ui").open_prompt_with_error()
    end, { desc = "Open config assistant with error context" })
  end
  
  -- Create user commands
  vim.api.nvim_create_user_command("ConfigAssistant", function()
    require("nvim-config-assistant.ui").open_prompt()
  end, { desc = "Open config assistant prompt" })
  
  vim.api.nvim_create_user_command("ConfigAssistantError", function()
    require("nvim-config-assistant.ui").open_prompt_with_error()
  end, { desc = "Open config assistant with current error" })
  
  vim.api.nvim_create_user_command("ConfigAssistantHealth", function()
    require("nvim-config-assistant.health").check()
  end, { desc = "Check nvim-config-assistant health" })
end

return M