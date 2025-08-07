-- Auto-commit plugin for lazy-lock.json changes
-- This version uses a different approach to hook into Lazy events

local M = {}

-- Load configuration
local config_ok, user_config = pcall(require, "config.lazy-auto-commit")
local config = config_ok and user_config or {
  enabled = true,
  auto_commit = false,
  dotfiles_paths = {
    vim.fn.expand("~/.dotfiles"),
    vim.fn.expand("~/dotfiles"),
    vim.fn.expand("~/dev/dotfiles"),
    vim.fn.expand("~/code/dotfiles"),
  },
  messages = {
    success = "✅ Plugin updates committed and pushed successfully!",
    failure = "❌ Failed to commit plugin updates",
    no_changes = "No plugin changes to commit",
    skipped = "Plugin update commit skipped",
  },
}

-- Test that plugin is loading
vim.notify("Auto-commit plugin loaded successfully!", vim.log.levels.INFO)

-- Find the dotfiles directory
local function find_dotfiles_dir()
  for _, path in ipairs(config.dotfiles_paths) do
    if vim.fn.isdirectory(path) == 1 and vim.fn.filereadable(path .. "/setup-dotfiles.yml") == 1 then
      return path
    end
  end
  return nil
end

-- Check if we're in a git repository
local function is_git_repo(path)
  local git_dir = path .. "/.git"
  return vim.fn.isdirectory(git_dir) == 1 or vim.fn.filereadable(git_dir) == 1
end

-- Check if lazy-lock.json has changes
local function has_lock_changes(dotfiles_dir)
  local lazy_lock_path = dotfiles_dir .. "/common/nvim/lazy-lock.json"
  
  -- Check if file exists
  if vim.fn.filereadable(lazy_lock_path) == 0 then
    return false
  end
  
  -- Check git status for the specific file
  local handle = io.popen("cd " .. vim.fn.shellescape(dotfiles_dir) .. " && git status --porcelain common/nvim/lazy-lock.json 2>/dev/null")
  if not handle then
    return false
  end
  
  local result = handle:read("*a")
  handle:close()
  
  return result and result:match("%S") ~= nil
end

-- Create commit and push
local function commit_and_push(dotfiles_dir)
  local lazy_lock_path = "common/nvim/lazy-lock.json"
  local timestamp = os.date("%Y-%m-%d at %H:%M")
  
  local commit_msg = string.format([[chore: update neovim plugin versions

Updated plugin lockfile on %s

🤖 Generated with LazyVim auto-commit

Co-Authored-By: Claude <noreply@anthropic.com>]], timestamp)
  
  -- Change to dotfiles directory and run git commands
  local commands = {
    "cd " .. vim.fn.shellescape(dotfiles_dir),
    "git add " .. vim.fn.shellescape(lazy_lock_path),
    "git commit -m " .. vim.fn.shellescape(commit_msg),
    "git push"
  }
  
  local full_command = table.concat(commands, " && ")
  
  -- Run the command
  local handle = io.popen(full_command .. " 2>&1")
  if not handle then
    return false, "Failed to execute git commands"
  end
  
  local output = handle:read("*a")
  local success = handle:close()
  
  return success, output
end

-- Show diff of changes
local function show_changes(dotfiles_dir)
  local handle = io.popen("cd " .. vim.fn.shellescape(dotfiles_dir) .. " && git diff common/nvim/lazy-lock.json 2>/dev/null")
  if not handle then
    return "Could not get diff"
  end
  
  local result = handle:read("*a")
  handle:close()
  
  if result and result:match("%S") then
    -- Try to get just the summary
    local summary_handle = io.popen("cd " .. vim.fn.shellescape(dotfiles_dir) .. " && git diff --stat common/nvim/lazy-lock.json 2>/dev/null")
    if summary_handle then
      local summary = summary_handle:read("*a")
      summary_handle:close()
      return summary
    end
    return "Changes detected"
  else
    return "No changes detected"
  end
end

-- User confirmation dialog
local function confirm_commit(dotfiles_dir)
  local changes = show_changes(dotfiles_dir)
  
  vim.ui.select(
    { "Yes, commit and push", "No, skip" },
    {
      prompt = "Commit plugin updates?\n\n" .. changes .. "\n",
      format_item = function(item)
        return item
      end,
    },
    function(choice)
      if choice and choice:match("^Yes") then
        vim.notify("Committing plugin updates...", vim.log.levels.INFO)
        
        local success, output = commit_and_push(dotfiles_dir)
        if success then
          vim.notify(config.messages.success, vim.log.levels.INFO)
        else
          vim.notify(config.messages.failure .. ":\n" .. (output or "Unknown error"), vim.log.levels.ERROR)
        end
      else
        vim.notify(config.messages.skipped, vim.log.levels.INFO)
      end
    end
  )
end

-- Check if we're in work hours (9:00-18:00 on weekdays)
local function is_work_hours()
  local hour = tonumber(os.date("%H"))
  local day = tonumber(os.date("%w")) -- 0 = Sunday, 6 = Saturday
  
  -- Check if it's a weekday (Monday-Friday)
  if day >= 1 and day <= 5 then
    -- Check if it's between 9:00 and 18:00
    if hour >= 9 and hour < 18 then
      return true
    end
  end
  return false
end

-- Main handler function
local function handle_lazy_event()
  if not config.enabled then
    return
  end
  
  -- Skip during work hours
  if is_work_hours() then
    vim.notify("⏰ Skipping auto-commit during work hours (9:00-18:00)", vim.log.levels.INFO)
    return
  end
  
  local dotfiles_dir = find_dotfiles_dir()
  if not dotfiles_dir then
    return
  end
  
  if not is_git_repo(dotfiles_dir) then
    return
  end
  
  if not has_lock_changes(dotfiles_dir) then
    vim.notify("No changes to lazy-lock.json", vim.log.levels.INFO)
    return
  end
  
  -- Either auto-commit or ask user
  if config.auto_commit then
    vim.notify("Auto-committing plugin updates...", vim.log.levels.INFO)
    local success, output = commit_and_push(dotfiles_dir)
    if success then
      vim.notify(config.messages.success, vim.log.levels.INFO)
    else
      vim.notify(config.messages.failure .. ":\n" .. (output or "Unknown error"), vim.log.levels.ERROR)
    end
  else
    confirm_commit(dotfiles_dir)
  end
end

-- Set up the autocmd immediately when the plugin loads
vim.api.nvim_create_autocmd("User", {
  pattern = { "LazySync", "LazyUpdate", "LazyInstall" },
  callback = function(ev)
    -- Delay to ensure lazy-lock.json is written
    vim.defer_fn(handle_lazy_event, 1000)
  end,
  desc = "Auto-commit lazy-lock.json changes",
})

-- Commands to control the plugin
vim.api.nvim_create_user_command("LazyAutoCommitToggle", function()
  config.enabled = not config.enabled
  vim.notify("Lazy auto-commit " .. (config.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle automatic commit after plugin sync" })

vim.api.nvim_create_user_command("LazyAutoCommitAuto", function()
  config.auto_commit = not config.auto_commit
  vim.notify("Lazy auto-commit mode: " .. (config.auto_commit and "automatic" or "prompt"), vim.log.levels.INFO)
end, { desc = "Toggle automatic commit without confirmation" })

-- Return empty spec since we're just setting up autocmds
return {}