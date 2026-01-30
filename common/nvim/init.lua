-- ============================================================================
-- Neovim Configuration Entry Point
-- ============================================================================
-- This is the main entry point for Neovim configuration.
-- It loads BEFORE any plugins, making it the right place for early setup.
--
-- LOAD ORDER:
--   1. This file (init.lua)
--   2. config/lazy.lua (plugin manager setup)
--   3. Plugin specs from lua/plugins/*.lua
--   4. LazyVim defaults and extras
-- ============================================================================

-- ============================================================================
-- Provider Configuration (MUST be set before plugins load)
-- ============================================================================
-- Neovim has built-in "providers" that enable plugins written in other
-- languages (Ruby, Python, Node.js, Perl) to interact with Neovim.
--
-- WHY DISABLE THESE?
--   1. Performance: Each provider spawns an external process
--   2. Crashes: Corrupted provider installations can crash Neovim
--   3. Unused: Most modern plugins are written in Lua, not these languages
--
-- WHAT YOU LOSE BY DISABLING:
--   - Ruby provider: Some old vim plugins written in Ruby won't work
--   - Python provider: Some old vim plugins (like certain completions) won't work
--   - Node provider: Some old vim plugins won't work
--   - Perl provider: Very few plugins use this
--
-- TO RE-ENABLE A PROVIDER:
--   Comment out or delete the corresponding line below, then:
--   1. Ensure the language is installed (ruby, python3, node, perl)
--   2. Install the Neovim bindings:
--      - Ruby: gem install neovim
--      - Python: pip install pynvim
--      - Node: npm install -g neovim
--   3. Restart Neovim
--
-- NOTE: These were disabled to fix crashes caused by corrupted Ruby provider
-- ============================================================================

vim.g.loaded_ruby_provider = 0    -- Disable Ruby provider
vim.g.loaded_perl_provider = 0    -- Disable Perl provider
vim.g.loaded_python3_provider = 0 -- Disable Python 3 provider
vim.g.loaded_node_provider = 0    -- Disable Node.js provider

-- ============================================================================
-- Load Plugin Manager and Configuration
-- ============================================================================
-- This loads lazy.nvim (the plugin manager) and all plugin configurations.
-- See lua/config/lazy.lua for plugin manager setup.
-- See lua/plugins/*.lua for individual plugin configurations.
-- ============================================================================

require("config.lazy")
