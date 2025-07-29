-- Configuration for lazy-auto-commit plugin
-- This file allows you to customize the auto-commit behavior

return {
  -- Enable/disable the auto-commit feature entirely
  enabled = true,
  
  -- Skip confirmation dialog and commit automatically
  -- Set to true if you trust the auto-commit completely
  auto_commit = false,
  
  -- Paths to search for your dotfiles repository
  -- The plugin will try these paths in order
  dotfiles_paths = {
    vim.fn.expand("~/.dotfiles"),
    vim.fn.expand("~/dotfiles"),
    vim.fn.expand("~/dev/dotfiles"),
    vim.fn.expand("~/code/dotfiles"),
  },
  
  -- Custom notification messages
  messages = {
    success = "✅ Plugin updates committed and pushed successfully!",
    failure = "❌ Failed to commit plugin updates",
    no_changes = "No plugin changes to commit",
    skipped = "Plugin update commit skipped",
  },
}