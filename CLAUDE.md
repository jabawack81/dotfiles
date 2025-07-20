# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository that manages configuration files for multiple machines using Ansible instead of stow (despite what the outdated README says). The repository supports three different machine profiles:
- **kyrios**: Personal Arch Linux laptop
- **shinkiro**: Personal Arch Linux desktop  
- **work machine**: Any other hostname (limited configs for work environments)

## Key Architecture

### Configuration Structure
- **common/**: Shared configurations used across personal machines
- **kyrios/**: Laptop-specific configs (e.g., battery monitor in waybar)
- **shinkiro/**: Desktop-specific configs (e.g., temperature monitoring, multiple displays)

### Modular Configuration Pattern
Both Hyprland and Waybar use a modular configuration approach:
- Machine-specific configs include/source common configs
- Hyprland: `source = ./common.conf` in machine-specific configs
- Waybar: `"include": ["~/.config/waybar/modules.jsonc"]` in machine-specific configs

## Setup and Deployment

### Primary Setup Command
```bash
./setup.sh
```
This script:
1. Shows pre-setup symlink status
2. Installs Ansible if needed
3. Runs the Ansible playbook
4. Shows post-setup symlink status
5. Lists any missing configurations

### Manual Symlink Cleanup
```bash
./cleanup-broken-links.sh  # Interactive cleanup of broken symlinks
```

## Development Workflow

### Adding New Configurations
1. Decide if config is common or machine-specific
2. Place in appropriate directory (common/, kyrios/, or shinkiro/)
3. Update `setup-dotfiles.yml` if special handling is needed

### Testing Changes
Run `./setup.sh` to apply configuration changes. The script is idempotent and safe to run multiple times.

### Machine-Specific Customizations
- Desktop (shinkiro): Includes temperature monitoring, media player widgets, network status
- Laptop (kyrios): Includes battery monitor, simpler waybar without temperature sensors
- Work machines: Only get ghostty, nvim, and btop configs

## Important Technical Details

### Symlink Creation
- Common configs are symlinked from `common/` to `~/.config/`
- Machine-specific configs override or extend common ones
- Special handling for:
  - Hyprland: Machine-specific directory with symlink to common.conf
  - Waybar: Common modules.jsonc and style.css with machine-specific config
  - Thunar/GTK: Files go to both `~/.config/gtk-3.0/` and `~/.config/Thunar/`

### Oh-My-Zsh Configuration
- Custom helpers in `common/.oh-my-zsh/custom/` (utils.zsh, ruby_aliases.zsh)
- Theme and plugins configured via Ansible (not by linking .zshrc)
- Theme: agnoster
- Plugins: git, zsh-autosuggestions, zsh-syntax-highlighting

### Package Management
Ansible installs packages only on personal Arch machines. Work machines (especially macOS) require manual installation via homebrew.

## Common Issues and Solutions

### Waybar fails to link
This happens when individual waybar files are already symlinked. The playbook will show a failure but the configuration is actually correct.

### GTK theme not applying
Run Thunar with: `GTK_THEME=Adwaita:dark thunar`

### Hyprland config errors
Check that the relative path in `source = ./common.conf` resolves correctly from the symlinked location.