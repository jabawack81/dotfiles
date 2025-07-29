local M = {}

local curl = require("plenary.curl")
local json = vim.json

-- OpenAI API integration
local function query_openai(prompt, config)
  local api_key = vim.env[config.api_key_env]
  if not api_key then
    error("API key not found. Please set " .. config.api_key_env .. " environment variable.")
  end

  local response = curl.post("https://api.openai.com/v1/chat/completions", {
    headers = {
      ["Content-Type"] = "application/json",
      ["Authorization"] = "Bearer " .. api_key,
    },
    body = json.encode({
      model = config.model,
      messages = {
        {
          role = "system",
          content = "You are a helpful Neovim configuration assistant. Answer questions about Neovim configuration, keybindings, and plugin usage. Be concise and specific."
        },
        {
          role = "user",
          content = prompt
        }
      },
      temperature = 0.7,
      max_tokens = 500,
    }),
    timeout = 30000,
  })

  if response.status ~= 200 then
    error("API request failed: " .. (response.body or "Unknown error"))
  end

  local data = json.decode(response.body)
  return data.choices[1].message.content
end

-- Anthropic API integration
local function query_anthropic(prompt, config)
  local api_key = vim.env[config.api_key_env]
  if not api_key then
    error("API key not found. Please set " .. config.api_key_env .. " environment variable.")
  end

  local response = curl.post("https://api.anthropic.com/v1/messages", {
    headers = {
      ["Content-Type"] = "application/json",
      ["x-api-key"] = api_key,
      ["anthropic-version"] = "2023-06-01",
    },
    body = json.encode({
      model = config.model,
      max_tokens = 500,
      messages = {
        {
          role = "user",
          content = prompt
        }
      },
      system = "You are a helpful Neovim configuration assistant. Answer questions about Neovim configuration, keybindings, and plugin usage. Be concise and specific."
    }),
    timeout = 30000,
  })

  if response.status ~= 200 then
    error("API request failed: " .. (response.body or "Unknown error"))
  end

  local data = json.decode(response.body)
  return data.content[1].text
end

-- Main query function
function M.query(prompt, config)
  if config.llm_provider == "openai" then
    return query_openai(prompt, config)
  elseif config.llm_provider == "anthropic" then
    return query_anthropic(prompt, config)
  else
    error("Unknown LLM provider: " .. config.llm_provider)
  end
end

return M