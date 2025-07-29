local M = {}

-- Store recent errors
M.errors = {}
M.max_errors = 10

-- Initialize error tracking
function M.setup()
  -- Track vim errors
  vim.api.nvim_create_autocmd("User", {
    pattern = "Error",
    callback = function()
      M.capture_error()
    end,
  })
  
  -- Override vim.notify to capture error notifications
  local original_notify = vim.notify
  vim.notify = function(msg, level, opts)
    if level == vim.log.levels.ERROR then
      M.add_error({
        type = "notification",
        message = msg,
        time = os.time(),
        stack = debug.traceback(),
      })
    end
    return original_notify(msg, level, opts)
  end
  
  -- Track LSP diagnostics
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = function(args)
      local diagnostics = vim.diagnostic.get(args.buf, { severity = vim.diagnostic.severity.ERROR })
      for _, diag in ipairs(diagnostics) do
        M.add_error({
          type = "lsp_diagnostic",
          message = diag.message,
          source = diag.source,
          lnum = diag.lnum + 1,
          col = diag.col + 1,
          bufname = vim.api.nvim_buf_get_name(args.buf),
          time = os.time(),
        })
      end
    end,
  })
end

-- Add error to history
function M.add_error(error_info)
  table.insert(M.errors, 1, error_info)
  
  -- Keep only recent errors
  while #M.errors > M.max_errors do
    table.remove(M.errors)
  end
end

-- Capture current error from messages
function M.capture_error()
  local messages = vim.fn.execute("messages")
  local lines = vim.split(messages, "\n")
  
  -- Look for error patterns in recent messages
  for i = #lines, math.max(1, #lines - 10), -1 do
    local line = lines[i]
    if line:match("^E%d+:") or line:match("Error") or line:match("^Error") then
      M.add_error({
        type = "vim_error",
        message = line,
        time = os.time(),
      })
      break
    end
  end
end

-- Get current error under cursor
function M.get_current_diagnostic_error()
  local diagnostics = vim.diagnostic.get(0, {
    lnum = vim.fn.line(".") - 1,
    severity = vim.diagnostic.severity.ERROR,
  })
  
  if #diagnostics > 0 then
    local diag = diagnostics[1]
    return {
      type = "current_diagnostic",
      message = diag.message,
      source = diag.source,
      lnum = diag.lnum + 1,
      col = diag.col + 1,
      bufname = vim.api.nvim_buf_get_name(0),
    }
  end
  
  return nil
end

-- Get formatted error context
function M.get_error_context()
  local current_error = M.get_current_diagnostic_error()
  local recent_errors = M.errors
  
  local context_parts = {}
  
  if current_error then
    table.insert(context_parts, "Current Error Under Cursor:")
    table.insert(context_parts, string.format("  File: %s:%d:%d", current_error.bufname, current_error.lnum, current_error.col))
    table.insert(context_parts, string.format("  Source: %s", current_error.source or "unknown"))
    table.insert(context_parts, string.format("  Message: %s", current_error.message))
    table.insert(context_parts, "")
  end
  
  if #recent_errors > 0 then
    table.insert(context_parts, "Recent Errors:")
    for i, err in ipairs(recent_errors) do
      if i > 5 then break end -- Show only 5 most recent
      
      local time_str = os.date("%H:%M:%S", err.time)
      table.insert(context_parts, string.format("  [%s] %s: %s", time_str, err.type, err.message))
      
      if err.bufname then
        table.insert(context_parts, string.format("    File: %s:%d:%d", err.bufname, err.lnum or 0, err.col or 0))
      end
    end
  end
  
  return table.concat(context_parts, "\n")
end

return M