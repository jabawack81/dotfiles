return {
  {
    "nvim-config-assistant",
    enabled = true, -- Requires ANTHROPIC_API_KEY environment variable
    dir = vim.fn.stdpath("config") .. "/lua/nvim-config-assistant",
    -- lazy = false, -- Load immediately to ensure setup runs
    event = "VeryLazy", -- Load after startup to avoid freezing
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for HTTP requests
    },
    keys = {
      {
        "<leader>qa",
        function()
          require("nvim-config-assistant.ui").open_prompt()
        end,
        desc = "Config Assistant",
      },
      {
        "<leader>qe",
        function()
          require("nvim-config-assistant.ui").open_prompt_with_error()
        end,
        desc = "Config Assistant (with errors)",
      },
    },
    cmd = { "ConfigAssistant", "ConfigAssistantError", "ConfigAssistantHealth" },
    config = function()
      require("nvim-config-assistant").setup({
        -- Choose your LLM provider: "openai" or "anthropic"
        llm_provider = "anthropic",

        -- Set the appropriate environment variable name for your API key
        api_key_env = "ANTHROPIC_API_KEY", -- or "OPENAI_API_KEY"

        -- Model to use
        -- model = "gpt-4", -- or "gpt-3.5-turbo" for OpenAI
        model = "claude-3-5-sonnet-20241022", -- Latest Claude 3.5 Sonnet

        keymaps = {
          open_prompt = "<leader>qa", -- qa for "question assistant"
          open_with_error = "<leader>qe", -- qe for "question error"
        },

        window = {
          width = 80,
          height = 3,
          border = "rounded",
        },
      })
    end,
  },
}