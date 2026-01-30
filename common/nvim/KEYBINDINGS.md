# Neovim Keybindings Cheatsheet

> **Tip:** Press `<leader>` (Space) and wait to see all available keybinding groups in which-key.

## Table of Contents

> **Navigation tip:** Use `/` to search for a section (e.g., `/Copilot`, `/LSP`)

- [General](#general)
- [Navigation](#navigation)
- [LSP (Code Intelligence)](#lsp-code-intelligence)
- [Copilot (AI Suggestions)](#copilot-ai-suggestions)
- [Copilot Chat (AI Conversations)](#copilot-chat-ai-conversations)
- [Search (Telescope)](#search-telescope)
- [Git](#git)
- [File Explorer (Neo-tree)](#file-explorer-neo-tree)
- [Buffers & Windows](#buffers--windows)
- [Diagnostics](#diagnostics)
- [Comments](#comments)
- [Rails Navigation](#rails-navigation)

---

## General

| Key                | Action                              | Mode |
|--------------------|-------------------------------------|------|
| `<Space>`          | Leader key (shows which-key menu)   | n    |
| `<Esc>`            | Clear search highlight              | n    |
| `u`                | Undo                                | n    |
| `<C-r>`            | Redo                                | n    |
| `.`                | Repeat last command                 | n    |
| `<leader>qq`       | Quit all                            | n    |
| `<leader>fn`       | New file                            | n    |
| `<leader>xl`       | Location list                       | n    |
| `<leader>xq`       | Quickfix list                       | n    |

---

## Navigation

### Basic Movement

| Key                | Action                              |
|--------------------|-------------------------------------|
| `h` `j` `k` `l`    | Left / Down / Up / Right            |
| `w` / `b`          | Next / Previous word                |
| `e`                | End of word                         |
| `0` / `$`          | Start / End of line                 |
| `gg` / `G`         | Start / End of file                 |
| `{` / `}`          | Previous / Next paragraph           |
| `%`                | Jump to matching bracket            |
| `<C-d>` / `<C-u>`  | Half page down / up                 |
| `<C-f>` / `<C-b>`  | Full page down / up                 |
| `zz`               | Center cursor on screen             |

### Jump to Character (Flash)

| Key                | Action                              |
|--------------------|-------------------------------------|
| `s`                | Flash jump (type 2 chars)           |
| `S`                | Flash treesitter                    |
| `f` / `F`          | Find char forward / backward        |
| `t` / `T`          | Till char forward / backward        |

---

## LSP (Code Intelligence)

> Requires LSP server attached. Check with `:LspInfo`

### Navigation

| Key                | Action                              |
|--------------------|-------------------------------------|
| `gd`               | Go to definition                    |
| `gr`               | Find references                     |
| `gI`               | Go to implementation                |
| `gy`               | Go to type definition               |
| `gD`               | Go to declaration                   |
| `K`                | Hover documentation                 |
| `gK`               | Signature help                      |
| `<C-k>`            | Signature help (insert mode)        |

### Code Actions

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>ca`       | Code action                         |
| `<leader>cA`       | Source action (organize imports)    |
| `<leader>cr`       | Rename symbol                       |
| `<F2>`             | Rename symbol                       |
| `<leader>cf`       | Format document                     |

### Diagnostics (Errors/Warnings)

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>cd`       | Line diagnostics (floating window)  |
| `]d` / `[d`        | Next / Previous diagnostic          |
| `]e` / `[e`        | Next / Previous error               |
| `]w` / `[w`        | Next / Previous warning             |

### LSP Management

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>cI`       | LSP info                            |
| `<leader>cR`       | Restart LSP                         |
| `<leader>cL`       | LSP log                             |

### Workspace

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>cw`       | Add workspace folder                |
| `<leader>cW`       | Remove workspace folder             |
| `<leader>cl`       | List workspace folders              |

---

## Copilot (AI Suggestions)

> Inline ghost text suggestions as you type

### Insert Mode

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<C-j>`            | Accept suggestion                   |
| `<M-CR>`           | Open suggestions panel              |

### Normal Mode (`<leader>cp`)

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>cpt`      | Toggle auto-trigger                 |
| `<leader>cpp`      | Open panel                          |
| `<leader>cps`      | Next suggestion                     |
| `<leader>cpS`      | Previous suggestion                 |
| `<leader>cpd`      | Dismiss suggestion                  |

### Panel Mode (when panel is open)

| Key                | Action                              |
|--------------------|-------------------------------------|
| `[[` / `]]`        | Previous / Next suggestion          |
| `<C-y>`            | Accept suggestion                   |
| `gr`               | Refresh suggestions                 |

---

## Copilot Chat (AI Conversations)

> All keybindings under `<leader>a` (AI group)

### Quick Actions

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>ap`       | Show all prompts (Telescope)        |
| `<leader>ai`       | Ask custom question                 |
| `<leader>aq`       | Quick chat about buffer             |
| `<leader>av`       | Toggle chat window                  |

### Code Actions (select code first)

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>ae`       | Explain code                        |
| `<leader>at`       | Generate tests                      |
| `<leader>ar`       | Review code                         |
| `<leader>aR`       | Refactor code                       |
| `<leader>an`       | Better naming suggestions           |
| `<leader>af`       | Fix diagnostic error                |

### Git

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>am`       | Generate commit message             |

### Chat Management

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>al`       | Clear chat history                  |
| `<leader>a?`       | Select AI model                     |
| `<leader>aa`       | Select AI agent                     |

### Visual Mode

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>av`       | Chat about selection (vsplit)       |
| `<leader>ax`       | Inline chat (floating)              |

### Inside Chat Window

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<Tab>`            | Complete @mentions or /commands     |
| `<CR>`             | Submit message (normal mode)        |
| `<C-CR>`           | Submit message (insert mode)        |
| `q`                | Close chat                          |
| `<C-c>`            | Close chat (insert mode)            |
| `<C-x>`            | Reset chat                          |
| `<C-y>`            | Accept code diff                    |
| `g?`               | Show help                           |

---

## Search (Telescope)

> All under `<leader>s` (search) or `<leader>f` (find)

### Find Files

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>ff`       | Find files                          |
| `<leader>fr`       | Recent files                        |
| `<leader>fb`       | Buffers                             |
| `<leader>fg`       | Git files                           |
| `<leader><space>`  | Find files (root)                   |

### Search Content

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>sg`       | Grep (live search)                  |
| `<leader>sw`       | Search word under cursor            |
| `<leader>ss`       | Document symbols                    |
| `<leader>sS`       | Workspace symbols                   |

### Search Special

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>st`       | TODO comments                       |
| `<leader>sT`       | TODO/FIX/FIXME                      |
| `<leader>sd`       | Diagnostics                         |
| `<leader>sh`       | Help tags                           |
| `<leader>sk`       | Keymaps                             |
| `<leader>sc`       | Commands                            |
| `<leader>s"`       | Registers                           |
| `<leader>sm`       | Marks                               |

---

## Git

### Git Actions (`<leader>g`)

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>gg`       | Lazygit                             |
| `<leader>gG`       | Lazygit (cwd)                       |
| `<leader>gb`       | Git blame line                      |
| `<leader>gB`       | Git browse                          |
| `<leader>gf`       | Git file history                    |
| `<leader>gl`       | Git log                             |
| `<leader>gL`       | Git log (cwd)                       |

### Git Hunks (changes)

| Key                | Action                              |
|--------------------|-------------------------------------|
| `]h` / `[h`        | Next / Previous hunk                |
| `<leader>ghs`      | Stage hunk                          |
| `<leader>ghr`      | Reset hunk                          |
| `<leader>ghp`      | Preview hunk                        |
| `<leader>ghb`      | Blame line                          |

---

## File Explorer (Neo-tree)

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>e`        | Toggle explorer (root)              |
| `<leader>E`        | Toggle explorer (cwd)               |
| `<leader>fe`       | Explorer (root)                     |
| `<leader>fE`       | Explorer (cwd)                      |

### Inside Neo-tree

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<CR>` / `o`       | Open file                           |
| `s`                | Open in split                       |
| `v`                | Open in vsplit                      |
| `a`                | Add file/folder                     |
| `d`                | Delete                              |
| `r`                | Rename                              |
| `c`                | Copy                                |
| `m`                | Move                                |
| `y`                | Copy name                           |
| `Y`                | Copy path                           |
| `q`                | Close explorer                      |
| `?`                | Show help                           |

---

## Buffers & Windows

### Buffers

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>bb`       | Switch buffer                       |
| `<leader>bd`       | Delete buffer                       |
| `<leader>bD`       | Delete buffer (force)               |
| `<S-h>` / `<S-l>`  | Previous / Next buffer              |
| `[b` / `]b`        | Previous / Next buffer              |

### Windows

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<C-h/j/k/l>`      | Navigate windows                    |
| `<leader>-`        | Split horizontal                    |
| `<leader>\|`       | Split vertical                      |
| `<leader>wd`       | Close window                        |
| `<C-Up/Down/...>`  | Resize window                       |

### Tabs

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader><tab>l`   | Last tab                            |
| `<leader><tab>f`   | First tab                           |
| `<leader><tab><tab>` | New tab                           |
| `<leader><tab>d`   | Close tab                           |
| `<leader><tab>]`   | Next tab                            |
| `<leader><tab>[`   | Previous tab                        |

---

## Diagnostics

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>xx`       | Trouble diagnostics                 |
| `<leader>xX`       | Buffer diagnostics                  |
| `<leader>cs`       | Symbols outline                     |
| `<leader>xL`       | Location list                       |
| `<leader>xQ`       | Quickfix list                       |

---

## Comments

| Key                | Action                              |
|--------------------|-------------------------------------|
| `gc`               | Toggle comment (motion)             |
| `gcc`              | Toggle comment (line)               |
| `gbc`              | Toggle block comment                |
| `gc` (visual)      | Toggle comment                      |

### TODO Comments

| Key                | Action                              |
|--------------------|-------------------------------------|
| `]t` / `[t`        | Next / Previous TODO                |
| `<leader>st`       | Search TODOs                        |

---

## Rails Navigation

> Custom keybindings for Rails projects

| Key                | Action                              |
|--------------------|-------------------------------------|
| `<leader>fr`       | Rails files picker                  |
| `<leader>fe`       | Engine files                        |
| `<leader>gd`       | Go to class definition              |
| `<leader>gf`       | Find file by class name             |
| `gD`               | Search definition (fallback)        |

---

## Useful Commands

| Command            | Action                              |
|--------------------|-------------------------------------|
| `:Mason`           | Manage LSP servers, linters         |
| `:Lazy`            | Manage plugins                      |
| `:LspInfo`         | Show attached LSP servers           |
| `:LspRestart`      | Restart LSP                         |
| `:Copilot auth`    | Authenticate with Copilot           |
| `:checkhealth`     | Check Neovim health                 |
| `:TSInstall <lang>`| Install treesitter parser           |
| `:TSUpdate`        | Update all parsers                  |
| `:Keybindings`     | Show this cheatsheet                |

---

## Plugin List

| Plugin             | Purpose                             |
|--------------------|-------------------------------------|
| LazyVim            | Base configuration                  |
| lazy.nvim          | Plugin manager                      |
| mason.nvim         | LSP/linter/formatter installer      |
| nvim-lspconfig     | LSP configuration                   |
| telescope.nvim     | Fuzzy finder                        |
| neo-tree.nvim      | File explorer                       |
| copilot.lua        | AI code suggestions                 |
| CopilotChat.nvim   | AI chat interface                   |
| gitsigns.nvim      | Git integration                     |
| which-key.nvim     | Keybinding hints                    |
| flash.nvim         | Jump navigation                     |
| treesitter         | Syntax highlighting                 |
| noice.nvim         | UI enhancements                     |
| todo-comments.nvim | TODO highlighting                   |

---

## Links

- LazyVim Documentation: https://www.lazyvim.org/
- Neovim Documentation: https://neovim.io/doc/
- Copilot Chat: https://github.com/CopilotC-Nvim/CopilotChat.nvim
- Mason: https://github.com/mason-org/mason.nvim

---

*Generated for your Neovim config. Press `<leader>hk` to open this cheatsheet!*
