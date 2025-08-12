-- Auto-commit plugin for lazy-lock.json changes
-- This version uses a different approach to hook into Lazy events

local M = {}

-- Load configuration
local config_ok, user_config = pcall(require, "config.lazy-auto-commit")
local config = config_ok and user_config or {
  enabled = true,
  auto_commit = false,
  auto_push = true,
  auto_pull = true,
  dotfiles_paths = {
    vim.fn.expand("~/.dotfiles"),
    vim.fn.expand("~/dotfiles"),
    vim.fn.expand("~/dev/dotfiles"),
    vim.fn.expand("~/code/dotfiles"),
  },
  messages = {
    success = "✅ Plugin updates committed successfully!",
    push_success = "✅ Plugin updates pushed successfully!",
    pull_success = "✅ Pulled latest dotfiles changes",
    failure = "❌ Failed to commit plugin updates",
    push_failure = "❌ Failed to push plugin updates",
    pull_failure = "⚠️ Failed to pull latest changes",
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

-- Create commit and optionally push
local function commit_and_push(dotfiles_dir, push)
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
  }
  
  -- Add push command if requested
  if push then
    table.insert(commands, "git push")
  end
  
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
        
        local success, output = commit_and_push(dotfiles_dir, config.auto_push)
        if success then
          if config.auto_push then
            vim.notify(config.messages.push_success, vim.log.levels.INFO)
          else
            vim.notify(config.messages.success, vim.log.levels.INFO)
          end
        else
          vim.notify(config.messages.failure .. ":\n" .. (output or "Unknown error"), vim.log.levels.ERROR)
        end
      else
        vim.notify(config.messages.skipped, vim.log.levels.INFO)
      end
    end
  )
end

-- Main handler function
local function handle_lazy_event()
  if not config.enabled then
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
    local success, output = commit_and_push(dotfiles_dir, config.auto_push)
    if success then
      if config.auto_push then
        vim.notify(config.messages.push_success, vim.log.levels.INFO)
      else
        vim.notify(config.messages.success, vim.log.levels.INFO)
      end
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

vim.api.nvim_create_user_command("LazyAutoCommitPush", function()
  config.auto_push = not config.auto_push
  vim.notify("Lazy auto-push: " .. (config.auto_push and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle automatic push after commit" })

vim.api.nvim_create_user_command("LazyAutoCommitPull", function()
  config.auto_pull = not config.auto_pull
  vim.notify("Lazy auto-pull on startup: " .. (config.auto_pull and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle automatic pull at Neovim startup" })

-- Auto-pull function for startup
local function auto_pull_on_startup()
  if not config.enabled or not config.auto_pull then
    return
  end
  
  local dotfiles_dir = find_dotfiles_dir()
  if not dotfiles_dir or not is_git_repo(dotfiles_dir) then
    return
  end
  
  -- Run git pull in background
  local handle = io.popen("cd " .. vim.fn.shellescape(dotfiles_dir) .. " && git pull --ff-only 2>&1")
  if handle then
    local output = handle:read("*a")
    local success = handle:close()
    
    if success then
      if output:match("Already up to date") then
        -- Don't notify if already up to date
      elseif output:match("Fast%-forward") then
        vim.notify(config.messages.pull_success, vim.log.levels.INFO)
      else
        vim.notify("Git pull: " .. output, vim.log.levels.INFO)
      end
    else
      -- Only show warning if there was an actual error (not just nothing to pull)
      if not output:match("Already up to date") then
        vim.notify(config.messages.pull_failure .. ": " .. output, vim.log.levels.WARN)
      end
    end
  end
end

-- Set up auto-pull on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Delay slightly to not interfere with startup
    vim.defer_fn(auto_pull_on_startup, 500)
  end,
  desc = "Auto-pull dotfiles on Neovim startup",
})

-- Return empty spec since we're just setting up autocmds
return {}