local M = {}

local api = vim.api
local fn = vim.fn

local function create_float_window(config)
  local width = config.window.width
  local height = config.window.height
  
  -- Calculate window position (centered)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  -- Create buffer
  local buf = api.nvim_create_buf(false, true)
  
  -- Window options
  local opts = {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = config.window.border,
  }
  
  -- Create window
  local win = api.nvim_open_win(buf, true, opts)
  
  -- Set window options
  api.nvim_win_set_option(win, "winhl", "Normal:Normal")
  api.nvim_win_set_option(win, "cursorline", false)
  
  return buf, win
end

local function create_result_window(config, result)
  local lines = vim.split(result, "\n")
  local max_width = 0
  for _, line in ipairs(lines) do
    max_width = math.max(max_width, #line)
  end
  
  local width = math.min(max_width + 4, math.floor(vim.o.columns * 0.8))
  local height = math.min(#lines + 2, math.floor(vim.o.lines * 0.8))
  
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  
  local opts = {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = config.window.border,
  }
  
  local win = api.nvim_open_win(buf, true, opts)
  
  -- Set buffer as readonly
  api.nvim_buf_set_option(buf, "modifiable", false)
  api.nvim_buf_set_option(buf, "buftype", "nofile")
  
  -- Add keymaps to close
  api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
  api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })
  
  return buf, win
end

function M.open_prompt(include_errors)
  local config = require("nvim-config-assistant").config
  local buf, win = create_float_window(config)
  
  -- Set prompt
  api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
  
  -- Set buffer options
  api.nvim_buf_set_option(buf, "buftype", "prompt")
  fn.prompt_setprompt(buf, "❯ ")
  
  -- Start insert mode
  vim.cmd("startinsert!")
  
  -- Set up callback
  fn.prompt_setcallback(buf, function(text)
    -- Close prompt window
    api.nvim_win_close(win, true)
    
    if text and text ~= "" then
      -- Show loading message
      vim.notify("Querying assistant...", vim.log.levels.INFO)
      
      -- Query in async
      vim.schedule(function()
        local ok, result = pcall(function()
          -- Pass include_errors flag to config analyzer
          local config_context = require("nvim-config-assistant.config_analyzer").get_context(include_errors)
          local full_prompt = string.format([[
Current Neovim Configuration Context:
%s

User Question: %s

Please provide a helpful answer based on the user's configuration.]], config_context, text)
          
          if config.llm_provider == "openai" then
            return require("nvim-config-assistant.llm").query(full_prompt, config)
          elseif config.llm_provider == "anthropic" then
            return require("nvim-config-assistant.llm").query(full_prompt, config)
          else
            error("Unknown LLM provider: " .. config.llm_provider)
          end
        end)
        
        if ok then
          create_result_window(config, result)
        else
          -- Show full error with stack trace
          vim.notify("nvim-config-assistant error: " .. tostring(result), vim.log.levels.ERROR)
          -- Also print to messages for debugging
          print("Full error details: " .. tostring(result))
        end
      end)
    end
  end)
  
  -- Add interrupt handler
  api.nvim_buf_set_keymap(buf, "i", "<C-c>", "<Esc>:close<CR>", { noremap = true, silent = true })
end

-- Open prompt with error context
function M.open_prompt_with_error()
  M.open_prompt(true)
end

return M