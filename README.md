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
- Install required packages (pacman on Arch Linux, apt on Debian servers)
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

**Security** (via Makefile):
- `make aur-check` - Scan for AUR supply-chain compromise indicators
- `make aur-check LIST=names.txt` - Also match installed AUR packages against a name list

See [docs/AUR_SUPPLY_CHAIN.md](docs/AUR_SUPPLY_CHAIN.md) for what it checks and why.

**Publishing** (via Makefile):
- `make push-changes` - Commit and push changes

For full list of available commands: `make help`

## Machine Profiles

- **kyrios**: Personal Arch Linux laptop (battery monitoring, single display)
- **shinkiro**: Personal Arch Linux desktop (dual 4K displays, GPU monitoring, EWW widgets)
- **lupus**: Arch Linux ThinkPad T470p (hybrid Intel/NVIDIA GPU)
- **virtue**: Debian server. Headless profile, detected by OS family rather than hostname, so any other Debian box gets the same treatment. Installs zsh + oh-my-zsh and Neovim with the LazyVim config, nothing else (no desktop, no version managers, no Claude Code).
- **Work machines**: Limited configs for non-personal machines

### Setting up a Debian server

```bash
sudo apt-get update && sudo apt-get install -y git make
git clone https://github.com/jabawack81/dotfiles.git ~/dotfiles
cd ~/dotfiles
make install-deps   # installs ansible via apt
make setup          # asks for your sudo password once
```

Neovim comes from the official release tarball (apt's is too old for LazyVim), pinned to an exact version with sha256 checksums in `setup-dotfiles.yml`, and lands in `/opt/nvim-<version>` with `/opt/nvim` pointing at it. To upgrade, bump `neovim_release` and both hashes, then re-run `make setup`. The `private-config` submodule is not needed on a server.

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
- `common/`: Shared configurations across personal machines (nvim, tmux, ghostty, btop, etc.)
- `kyrios/`: Laptop-specific configurations (Hyprland, EWW, Waybar)
- `shinkiro/`: Desktop-specific configurations (dual display, GPU monitoring)
- `lupus/`: ThinkPad-specific configurations

**Documentation**:
- `docs/`: Comprehensive documentation
  - `ARCHITECTURE.md`: Project architecture overview
  - `ANSIBLE.md`: Ansible playbook documentation
  - `HYPRLAND_CONFIG.md`: Hyprland window manager config
  - `HYPRLAND_KEYBINDINGS_COMPARISON.md`: Shinkiro vs Lupus keybinding diff
  - `SETUP.md`: Private config and initial setup
  - `TESTING.md`: Ansible testing and validation guide
  - `NEOVIM_TROUBLESHOOTING.md`: LSP and Mason debugging guide

**Scripts & Tools**:
- `Makefile`: Interactive task management menu
- `scripts/`: Utility scripts (setup, updates)
- `examples/`: Configuration templates and examples
- `setup-dotfiles.yml`: Ansible playbook
- `private-config/`: Private configuration (submodule)
