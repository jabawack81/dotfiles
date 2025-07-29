# Neovim Keymaps Documentation

This document provides a comprehensive list of all custom keymaps configured in this Neovim setup, organized by functionality.

## Quick Reference

- **Leader key**: `<space>` (LazyVim default)
- **Which-key help**: Press `<leader>?` to see available keymaps in current context

## Core Navigation

### Go-to Commands
- `gd` - Goto Definition (using Telescope)
- `gr` - References (using Telescope)
- `gI` - Goto Implementation (using Telescope)
- `gy` - Goto Type Definition (using Telescope)
- `gD` - Search definition (fallback when LSP fails)
- `K` - Hover information
- `gK` - Signature Help

## LSP Features

### Code Actions (`<leader>c`)
- `<leader>ca` - Code Action (normal and visual mode)
- `<leader>cA` - Source Action (only source code actions)
- `<leader>cr` - Rename symbol
- `<F2>` - Rename symbol (alternative)
- `<leader>cd` - Line Diagnostics (open float)

### LSP Management
- `<leader>cR` - Restart LSP
- `<leader>cI` - LSP Info
- `<leader>cL` - LSP Log

### Workspace
- `<leader>cw` - Add Workspace Folder
- `<leader>cW` - Remove Workspace Folder
- `<leader>cl` - List Workspace Folders

## Diagnostics Navigation

- `]d` - Next Diagnostic
- `[d` - Previous Diagnostic
- `]e` - Next Error
- `[e` - Previous Error
- `]w` - Next Warning
- `[w` - Previous Warning

## AI/Copilot Features (`<leader>a`)

### General Chat
- `<leader>ap` - Prompt actions (with telescope)
- `<leader>ai` - Ask input
- `<leader>aq` - Quick chat
- `<leader>av` - Toggle chat window
- `<leader>al` - Clear buffer and chat history
- `<leader>a?` - Select Models
- `<leader>aa` - Select Agents

### Code Analysis
- `<leader>ae` - Explain code
- `<leader>at` - Generate tests
- `<leader>ar` - Review code
- `<leader>aR` - Refactor code
- `<leader>an` - Better Naming
- `<leader>af` - Fix Diagnostic

### Git Integration
- `<leader>am` - Generate commit message for all changes

### Visual Mode
- `<leader>ap` - Prompt actions (visual selection)
- `<leader>av` - Open in vertical split (visual selection)
- `<leader>ax` - Inline chat (visual selection)

## File Management

### File Explorer (Neo-tree)
- `<leader>fe` - Explorer NeoTree (Root Dir)
- `<leader>fE` - Explorer NeoTree (current working directory)
- `<leader>e` - Explorer NeoTree (Root Dir) [quick access]
- `<leader>E` - Explorer NeoTree (cwd) [quick access]
- `<leader>ge` - Git Explorer
- `<leader>be` - Buffer Explorer

### Within Neo-tree
- `l` - Open file/folder
- `h` - Close node
- `Y` - Copy Path to Clipboard
- `O` - Open with System Application
- `P` - Toggle preview

### File Finding
- `<leader>fp` - Find Plugin File (in lazy.nvim directory)
- `<leader>ff` - Find Files (LazyVim default)
- `<leader>fg` - Find by Grep (LazyVim default)
- `<leader>fb` - Find Buffers (LazyVim default)

## Rails Development

- `<leader>fr` - Rails files picker (Models, Controllers, Views, etc.)
- `<leader>fe` - Engine files
- `<leader>gd` - Go to Ruby class/module definition
- `<leader>gf` - Find file by class name (converts CamelCase to snake_case)

## Utility Features

### Config Assistant
- `<leader>qa` - Config Assistant
- `<leader>qe` - Config Assistant (with errors)

### History
- `<leader>U` - Undo history (using Telescope)

### Help
- `<leader>?` - Show available keymaps (which-key)
- `<C-k>` - Signature Help (insert mode)

## LazyVim Default Keymaps

This configuration extends LazyVim, which provides many default keymaps. Key defaults include:

### Window Management
- `<C-h/j/k/l>` - Navigate between windows
- `<C-Up/Down/Left/Right>` - Resize windows
- `<leader>w` - Window management prefix

### Buffer Management
- `<S-h>` - Previous buffer
- `<S-l>` - Next buffer
- `<leader>bd` - Delete buffer

### Search and Replace
- `<leader>s` - Search prefix
- `<leader>r` - Replace prefix

### Terminal
- `<C-/>` - Toggle terminal
- `<leader>ft` - Terminal (root dir)
- `<leader>fT` - Terminal (cwd)

### UI Toggles
- `<leader>u` - UI toggles prefix
- `<leader>ul` - Toggle line numbers
- `<leader>uw` - Toggle word wrap

## User Commands

### Lazy Auto-commit
- `:LazyAutoCommitToggle` - Toggle automatic commit after plugin sync
- `:LazyAutoCommitAuto` - Toggle automatic commit without confirmation

### Config Assistant
- `:ConfigAssistant` - Open config assistant
- `:ConfigAssistantError` - Open config assistant with errors
- `:ConfigAssistantHealth` - Check config assistant health

## Tips

1. **Discover keymaps**: Use `<leader>?` frequently to discover available keymaps in current context
2. **Which-key delay**: If you pause after pressing `<leader>`, which-key will show available options
3. **Visual mode**: Many keymaps work in both normal and visual mode
4. **Telescope integration**: Many navigation commands use Telescope for a unified search interface
5. **LazyVim docs**: Check [LazyVim keymaps documentation](https://www.lazyvim.org/keymaps) for complete default mappings

## Customization

Custom keymaps can be added in:
- `lua/config/keymaps.lua` - General keymaps
- `lua/plugins/*.lua` - Plugin-specific keymaps in the `keys` section