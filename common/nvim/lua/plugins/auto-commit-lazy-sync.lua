-- Auto-commit plugin for lazy-lock.json changes
-- Robust version with proper error handling and debouncing

local M = {}

-- Prevent multiple loads
if _G.lazy_auto_commit_loaded then
  return {}
end
_G.lazy_auto_commit_loaded = true

-- Load configuration with validation
local function load_config()
  local config_ok, user_config = pcall(require, "config.lazy-auto-commit")
  local default_config = {
    enabled = true,
    auto_commit = false,
    auto_push = true,
    auto_pull = true,
    silent_pull_skip = true,
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
  
  if config_ok and type(user_config) == "table" then
    -- Merge user config with defaults
    return vim.tbl_deep_extend("force", default_config, user_config)
  end
  
  return default_config
end

local config = load_config()

-- Utility: Safe shell command execution
local function execute_command(cmd, cwd)
  if cwd then
    cmd = string.format("cd %s && %s", vim.fn.shellescape(cwd), cmd)
  end
  
  local output = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error
  
  return exit_code == 0, output, exit_code
end

-- Find the dotfiles directory
local function find_dotfiles_dir()
  for _, path in ipairs(config.dotfiles_paths) do
    if vim.fn.isdirectory(path) == 1 then
      -- Check for setup-dotfiles.yml as a marker
      if vim.fn.filereadable(path .. "/setup-dotfiles.yml") == 1 then
        return path
      end
      -- Also check for .git directory as fallback
      if vim.fn.isdirectory(path .. "/.git") == 1 then
        return path
      end
    end
  end
  return nil
end

-- Check if we're in a git repository
local function is_git_repo(path)
  if not path then return false end
  local git_dir = path .. "/.git"
  return vim.fn.isdirectory(git_dir) == 1 or vim.fn.filereadable(git_dir) == 1
end

-- Check if lazy-lock.json has changes
local function has_lock_changes(dotfiles_dir)
  if not dotfiles_dir then return false end
  
  local lazy_lock_path = dotfiles_dir .. "/common/nvim/lazy-lock.json"
  
  -- Check if file exists
  if vim.fn.filereadable(lazy_lock_path) == 0 then
    return false
  end
  
  -- Check git status for the specific file
  local success, output = execute_command(
    "git status --porcelain common/nvim/lazy-lock.json 2>/dev/null",
    dotfiles_dir
  )
  
  if not success then
    return false
  end
  
  -- Check if there are any changes (output should be non-empty)
  return output and output:match("%S") ~= nil
end

-- Create commit and optionally push
local function commit_and_push(dotfiles_dir, push)
  if not dotfiles_dir then
    return false, "No dotfiles directory found"
  end
  
  local lazy_lock_path = "common/nvim/lazy-lock.json"
  local timestamp = os.date("%Y-%m-%d at %H:%M")
  
  -- Create commit message
  local commit_msg = string.format(
    "chore: update neovim plugin versions\n\n" ..
    "Updated plugin lockfile on %s\n\n" ..
    "🤖 Generated with LazyVim auto-commit\n\n" ..
    "Co-Authored-By: Claude <noreply@anthropic.com>",
    timestamp
  )
  
  -- Stage the file
  local success, output = execute_command(
    string.format("git add %s", vim.fn.shellescape(lazy_lock_path)),
    dotfiles_dir
  )
  
  if not success then
    return false, "Failed to stage changes: " .. output
  end
  
  -- Create commit
  success, output = execute_command(
    string.format("git commit -m %s", vim.fn.shellescape(commit_msg)),
    dotfiles_dir
  )
  
  if not success then
    return false, "Failed to commit: " .. output
  end
  
  -- Push if requested
  if push then
    success, output = execute_command("git push", dotfiles_dir)
    if not success then
      return false, "Commit successful but push failed: " .. output
    end
  end
  
  return true, output
end

-- Show diff of changes
local function get_changes_summary(dotfiles_dir)
  if not dotfiles_dir then
    return "Could not determine dotfiles directory"
  end
  
  -- Try to get diff stat first
  local success, output = execute_command(
    "git diff --stat common/nvim/lazy-lock.json 2>/dev/null",
    dotfiles_dir
  )
  
  if success and output:match("%S") then
    return output
  end
  
  -- Check staged changes if no unstaged changes
  success, output = execute_command(
    "git diff --cached --stat common/nvim/lazy-lock.json 2>/dev/null",
    dotfiles_dir
  )
  
  if success and output:match("%S") then
    return "Staged changes:\n" .. output
  end
  
  return "No changes detected"
end

-- User confirmation dialog (async safe)
local function confirm_commit(dotfiles_dir)
  if not dotfiles_dir then
    vim.notify("No dotfiles directory found", vim.log.levels.ERROR)
    return
  end
  
  local changes = get_changes_summary(dotfiles_dir)
  
  -- Schedule UI operations to be safe
  vim.schedule(function()
    vim.ui.select(
      { "Yes, commit and push", "No, skip" },
      {
        prompt = "Commit plugin updates?\n\n" .. changes .. "\n",
        format_item = function(item)
          return item
        end,
      },
      function(choice)
        if not choice then
          -- User cancelled (pressed Esc)
          vim.notify(config.messages.skipped, vim.log.levels.INFO)
          return
        end
        
        if choice:match("^Yes") then
          vim.notify("Committing plugin updates...", vim.log.levels.INFO)
          
          -- Run commit in background to avoid blocking
          vim.defer_fn(function()
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
          end, 100)
        else
          vim.notify(config.messages.skipped, vim.log.levels.INFO)
        end
      end
    )
  end)
end

-- Main handler function with built-in debouncing
local handle_lazy_event_timer = nil
local function handle_lazy_event()
  -- Cancel any pending timer
  if handle_lazy_event_timer then
    vim.fn.timer_stop(handle_lazy_event_timer)
    handle_lazy_event_timer = nil
  end
  
  -- Set a new timer to run the actual handler
  handle_lazy_event_timer = vim.fn.timer_start(1500, function()
    handle_lazy_event_timer = nil
    
    if not config.enabled then
      return
    end
    
    local dotfiles_dir = find_dotfiles_dir()
    if not dotfiles_dir then
      return -- Silently exit if not in a dotfiles directory
    end
    
    if not is_git_repo(dotfiles_dir) then
      return -- Not a git repository
    end
    
    -- Check for changes in lazy-lock.json
    if not has_lock_changes(dotfiles_dir) then
      -- Don't notify when there are no changes
      return
    end
    
    -- Either auto-commit or ask user
    if config.auto_commit then
      vim.notify("Auto-committing plugin updates...", vim.log.levels.INFO)
      vim.defer_fn(function()
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
      end, 100)
    else
      confirm_commit(dotfiles_dir)
    end
  end)
end

-- Set up autocmds with proper grouping
local augroup = vim.api.nvim_create_augroup("LazyAutoCommit", { clear = true })

vim.api.nvim_create_autocmd("User", {
  pattern = { "LazySync", "LazyUpdate", "LazyInstall" },
  group = augroup,
  callback = function(ev)
    -- Just call the handler, it has its own debouncing
    handle_lazy_event()
  end,
  desc = "Auto-commit lazy-lock.json changes",
})

-- Commands to control the plugin (protected against duplicates)
if not _G.lazy_auto_commit_commands_created then
  _G.lazy_auto_commit_commands_created = true
  
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
  
  vim.api.nvim_create_user_command("LazyAutoCommitPullNow", function()
    local dotfiles_dir = find_dotfiles_dir()
    if not dotfiles_dir then
      vim.notify("No dotfiles directory found", vim.log.levels.ERROR)
      return
    end
    
    vim.notify("Pulling latest dotfiles changes...", vim.log.levels.INFO)
    
    vim.defer_fn(function()
      -- Force a pull without checking for local changes
      local success, output = execute_command("git pull --no-rebase --ff-only 2>&1", dotfiles_dir)
      
      if success then
        if output:match("Already up to date") then
          vim.notify("Already up to date", vim.log.levels.INFO)
        elseif output:match("Fast%-forward") then
          vim.notify(config.messages.pull_success, vim.log.levels.INFO)
          vim.cmd("Lazy reload")
        else
          vim.notify("Git pull: " .. vim.trim(output), vim.log.levels.INFO)
        end
      else
        vim.notify("Pull failed: " .. vim.trim(output), vim.log.levels.ERROR)
      end
    end, 100)
  end, { desc = "Manually pull latest dotfiles changes" })
  
  vim.api.nvim_create_user_command("LazyAutoCommitStatus", function()
    local status_lines = {
      "LazyAutoCommit Status:",
      "  Enabled: " .. tostring(config.enabled),
      "  Auto-commit: " .. tostring(config.auto_commit),
      "  Auto-push: " .. tostring(config.auto_push),
      "  Auto-pull: " .. tostring(config.auto_pull),
    }
    
    local dotfiles_dir = find_dotfiles_dir()
    if dotfiles_dir then
      table.insert(status_lines, "  Dotfiles: " .. dotfiles_dir)
      
      if has_lock_changes(dotfiles_dir) then
        table.insert(status_lines, "  Changes: pending")
      else
        table.insert(status_lines, "  Changes: none")
      end
    else
      table.insert(status_lines, "  Dotfiles: not found")
    end
    
    vim.notify(table.concat(status_lines, "\n"), vim.log.levels.INFO)
  end, { desc = "Show LazyAutoCommit status" })
end

-- Auto-pull function for startup
local function auto_pull_on_startup()
  if not config.enabled or not config.auto_pull then
    return
  end
  
  local dotfiles_dir = find_dotfiles_dir()
  if not dotfiles_dir or not is_git_repo(dotfiles_dir) then
    return
  end
  
  -- Run git pull
  vim.defer_fn(function()
    -- First check if there are any local changes that would prevent pulling
    local has_changes, status_output = execute_command("git status --porcelain 2>/dev/null", dotfiles_dir)
    
    if has_changes and status_output:match("%S") then
      -- There are local changes, check if they're significant
      local diff_success, diff_output = execute_command("git diff --stat 2>/dev/null", dotfiles_dir)
      
      -- Only skip pull if there are actual uncommitted changes (not just untracked files)
      if diff_success and diff_output:match("%S") then
        -- Skip pull when there are unstaged changes
        if not config.silent_pull_skip then
          vim.notify("Auto-pull skipped: uncommitted changes in dotfiles", vim.log.levels.INFO)
        end
        return
      end
    end
    
    -- Check if we need to pull at all
    local fetch_success, fetch_output = execute_command("git fetch --dry-run 2>&1", dotfiles_dir)
    if fetch_success and not fetch_output:match("%S") then
      -- Nothing to fetch, skip pull silently
      return
    end
    
    -- Try to pull with rebase=false to avoid the rebase error
    local success, output = execute_command("git pull --no-rebase --ff-only 2>&1", dotfiles_dir)
    
    if success then
      if output:match("Already up to date") then
        -- Don't notify if already up to date
      elseif output:match("Fast%-forward") then
        vim.notify(config.messages.pull_success, vim.log.levels.INFO)
        -- Reload lazy-lock.json if it was updated
        vim.cmd("Lazy reload")
      else
        vim.notify("Git pull: " .. vim.trim(output), vim.log.levels.INFO)
      end
    else
      -- Conditions that should always be silent (not really errors)
      local always_silent = {
        "Already up to date",
        "No remote",
        "No upstream",
        "no tracking information",
      }
      
      -- Conditions related to local changes (honor silent_pull_skip config)
      local change_related = {
        "You have unstaged changes",
        "cannot pull with rebase",
        "Please commit or stash",
        "Your local changes",
        "would be overwritten",
      }
      
      local should_notify = true
      local is_change_related = false
      
      -- Check if it's an always-silent condition
      for _, condition in ipairs(always_silent) do
        if output:match(condition) then
          should_notify = false
          break
        end
      end
      
      -- Check if it's a change-related condition
      if should_notify then
        for _, condition in ipairs(change_related) do
          if output:match(condition) then
            is_change_related = true
            should_notify = not config.silent_pull_skip
            break
          end
        end
      end
      
      -- Notify based on configuration
      if should_notify then
        if is_change_related then
          vim.notify("Auto-pull skipped: " .. vim.trim(output), vim.log.levels.INFO)
        else
          vim.notify(config.messages.pull_failure .. ": " .. vim.trim(output), vim.log.levels.WARN)
        end
      end
    end
  end, 100)
end

-- Set up auto-pull on startup
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup,
  once = true, -- Only run once
  callback = function()
    -- Delay to not interfere with startup
    vim.defer_fn(auto_pull_on_startup, 500)
  end,
  desc = "Auto-pull dotfiles on Neovim startup",
})

-- Return empty spec since we're just setting up autocmds
return {}