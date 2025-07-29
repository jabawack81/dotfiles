# Dotfiles

Dotfiles managed via Ansible for automated multi-machine setup.

## Quick Start

```bash
./setup.sh
```

This will:
- Install Ansible if needed
- Create all necessary symlinks
- Install required packages (on Arch Linux)
- Configure shell environment
- Set up all applications

## Quick Commands

- **Setup dotfiles**: `./setup.sh`
- **Update Neovim plugins**: `./update-nvim-plugins.sh` (or use alias `nvu`)
- **Test fastfetch logos**: `./test-logos.sh`

## Machine Profiles

- **kyrios**: Personal Arch Linux laptop (battery monitoring, single display)
- **shinkiro**: Personal Arch Linux desktop (dual 4K displays, GPU monitoring, EWW widgets)
- **Work machines**: Limited configs for non-personal machines

## Manual Steps After Setup

### Neovim
Open neovim and press `<space>l` then `S` to sync all plugins.

**Auto-commit Plugin Updates**: After syncing plugins in LazyVim, you'll be prompted to automatically commit and push the updated `lazy-lock.json`. You can:
- Use `./update-nvim-plugins.sh` (or alias `nvu`) from the terminal
- Or just sync plugins in Neovim and approve the commit prompt
- Toggle with `:LazyAutoCommitToggle` to disable the feature

### Tmux
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
Then open tmux and press `prefix` + `I` to install plugins.

## Repository Structure

- `common/`: Shared configurations across personal machines
- `kyrios/`: Laptop-specific configurations
- `shinkiro/`: Desktop-specific configurations
- `setup.sh`: Main setup script
- `setup-dotfiles.yml`: Ansible playbook
- `CLAUDE.md`: Detailed documentation for AI assistance
