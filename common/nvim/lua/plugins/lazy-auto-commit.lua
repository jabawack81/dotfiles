-- Automatically commit lazy-lock.json changes after plugin sync
-- This plugin adds an autocmd that runs after Lazy.nvim sync operations

-- Module for handling the auto-commit functionality
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
  },
  messages = {
    success = "✅ Plugin updates committed and pushed successfully!",
    failure = "❌ Failed to commit plugin updates",
    no_changes = "No plugin changes to commit",
    skipped = "Plugin update commit skipped",
  },
}

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

-- Get the lazy-lock.json path in the dotfiles repo
local function get_lazy_lock_path(dotfiles_dir)
  return dotfiles_dir .. "/common/nvim/lazy-lock.json"
end

-- Check if lazy-lock.json has changes
local function has_lock_changes(dotfiles_dir)
  local lazy_lock_path = get_lazy_lock_path(dotfiles_dir)
  
  -- Check if file exists
  if vim.fn.filereadable(lazy_lock_path) == 0 then
    return false
  end
  
  -- Check git status for the specific file
  local handle = io.popen("cd " .. vim.fn.shellescape(dotfiles_dir) .. " && git status --porcelain " .. vim.fn.shellescape("common/nvim/lazy-lock.json") .. " 2>/dev/null")
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
  
  local commit_msg = string.format([[update: neovim plugin versions

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
  local handle = io.popen("cd " .. vim.fn.shellescape(dotfiles_dir) .. " && git diff --stat common/nvim/lazy-lock.json 2>/dev/null")
  if not handle then
    return "Could not get diff"
  end
  
  local result = handle:read("*a")
  handle:close()
  
  return result and result:match("%S") and result or "No changes detected"
end

-- User confirmation dialog
local function confirm_commit(dotfiles_dir)
  local changes = show_changes(dotfiles_dir)
  
  local lines = {
    "Plugin sync completed! Changes detected in lazy-lock.json:",
    "",
    changes,
    "",
    "Would you like to commit and push these changes?",
  }
  
  -- Split changes into lines and add to dialog
  local dialog_lines = {}
  for _, line in ipairs(lines) do
    if line:find("\n") then
      for subline in line:gmatch("[^\n]+") do
        table.insert(dialog_lines, subline)
      end
    else
      table.insert(dialog_lines, line)
    end
  end
  
  -- Create a simple confirmation using vim.ui.select
  vim.ui.select(
    { "Yes, commit and push", "No, skip" },
    {
      prompt = "Commit plugin updates?",
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

-- Main handler function
function M.handle_sync_complete()
  if not config.enabled then
    return
  end
  
  -- Find dotfiles directory
  local dotfiles_dir = find_dotfiles_dir()
  if not dotfiles_dir then
    -- Silently skip if dotfiles not found - user might not want this feature
    return
  end
  
  -- Check if it's a git repo
  if not is_git_repo(dotfiles_dir) then
    return
  end
  
  -- Check if lazy-lock.json has changes
  if not has_lock_changes(dotfiles_dir) then
    return
  end
  
  -- Either auto-commit or ask user
  if config.auto_commit then
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

-- Command to toggle the feature
vim.api.nvim_create_user_command("LazyAutoCommitToggle", function()
  config.enabled = not config.enabled
  vim.notify("Lazy auto-commit " .. (config.enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle automatic commit after plugin sync" })

-- Command to toggle auto-commit mode
vim.api.nvim_create_user_command("LazyAutoCommitAuto", function()
  config.auto_commit = not config.auto_commit
  vim.notify("Lazy auto-commit mode: " .. (config.auto_commit and "automatic" or "prompt"), vim.log.levels.INFO)
end, { desc = "Toggle automatic commit without confirmation" })

-- Plugin spec for LazyVim
return {
  {
    "folke/lazy.nvim",
    opts = function(_, opts)
      -- Add autocmd to handle post-sync actions
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazySync",
        callback = function()
          -- Small delay to ensure lazy-lock.json is written
          vim.defer_fn(function()
            M.handle_sync_complete()
          end, 100)
        end,
        desc = "Handle plugin sync completion",
      })
      
      return opts
    end,
  },
}