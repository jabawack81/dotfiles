# Dotfiles

Dotfiles managed via Ansible for automated multi-machine setup.

## Quick Start

Interactive menu (recommended):
```bash
make
```

Or directly run setup:
```bash
make setup
```

This will:
- Install Ansible if needed
- Create all necessary symlinks
- Install required packages (on Arch Linux)
- Configure shell environment
- Set up all applications

## Quick Commands

**Management Tasks** (via Makefile):
- `make` or `make menu` - Display interactive menu
- `make setup` - Run full ansible setup
- `make dry-run` - Test changes without applying
- `make status` - Show git status and system info
- `make docs` - Display documentation index
- `make validate` - Validate playbook syntax

**Maintenance** (via Makefile):
- `make update-nvim` - Update Neovim plugins
- `make backup` - Create configuration backup
- `make clean` - Remove old backups and cache
- `make sync` - Pull latest changes from remote

**Publishing** (via Makefile):
- `make push-changes` - Commit and push changes

For full list of available commands: `make help`

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

**Configuration**:
- `common/`: Shared configurations across personal machines
- `kyrios/`: Laptop-specific configurations
- `shinkiro/`: Desktop-specific configurations

**Documentation**:
- `docs/`: Comprehensive documentation
  - `ARCHITECTURE.md`: Project architecture overview
  - `ANSIBLE.md`: Ansible playbook documentation
  - `HYPRLAND_CONFIG.md`: Hyprland window manager config
  - `HYPRLAND_MIGRATION.md`: Migration from Hyprland v2 to v3
  - `SETUP.md`: Private config and initial setup
  - `TESTING.md`: Ansible testing and validation guide
  - `REFACTORING.md`: Technical refactoring documentation

**Scripts & Tools**:
- `Makefile`: Interactive task management menu
- `scripts/`: Utility scripts (setup, updates)
- `examples/`: Configuration templates and examples
- `setup-dotfiles.yml`: Ansible playbook
- `private-config/`: Private configuration (submodule)
