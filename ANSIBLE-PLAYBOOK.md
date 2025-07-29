# Ansible Playbook Documentation

This document describes the `setup-dotfiles.yml` ansible playbook used to configure machines with the appropriate dotfiles and settings.

## Overview

The playbook automatically detects the machine type based on hostname:

- **Personal machines** (kyrios, shinkiro): Arch Linux with full configuration including GUI tools
- **Work machines** (any other hostname): macOS with limited configuration (terminal tools only)

## Machine Detection

The playbook uses hostname to determine both machine type and OS:
- `kyrios` - Personal laptop (always Arch Linux)
- `shinkiro` - Personal desktop (always Arch Linux)
- Any other hostname - Work machine (currently macOS, limited configs)

Since the hostname determines the OS, the playbook only needs to check `is_personal_machine` rather than checking both hostname and OS. Personal machines are the primary target, with work machine support as an additional feature.

## Installation Matrix

### Package Installation

| Package | Personal Linux (kyrios/shinkiro) | Work Linux | macOS |
|---------|----------------------------------|------------|--------|
| zsh | ✅ Auto (pacman) | ✅ Auto | ✅ Pre-installed |
| git | ✅ Auto (pacman) | ❌ Manual | ❌ Manual |
| waybar | ✅ Auto (pacman) | ❌ N/A | ❌ N/A |
| hyprland | ✅ Auto (pacman) | ❌ N/A | ❌ N/A |
| wofi | ✅ Auto (pacman) | ❌ N/A | ❌ N/A |
| dunst | ✅ Auto (pacman) | ❌ N/A | ❌ N/A |
| btop | ✅ Auto (pacman) | ❌ Manual | ❌ Manual (brew) |
| ghostty | ✅ Auto (pacman) | ❌ Manual | ❌ Manual (brew) |
| wlogout | ✅ Auto (pacman) | ❌ N/A | ❌ N/A |
| thunar | ✅ Auto (pacman) | ❌ N/A | ❌ N/A |
| powerline-fonts | ✅ Auto (pacman) | ❌ Manual | ❌ Manual |
| firefox | ✅ Auto (pacman) | ❌ Manual | ❌ Manual (brew cask) |
| obsidian | ✅ Auto (pacman) | ❌ Manual | ❌ Manual (brew cask) |
| discord | ✅ Auto (yay/AUR) | ❌ Manual | ❌ Manual (brew cask) |
| slack-desktop | ✅ Auto (yay/AUR) | ❌ Manual | ❌ Manual (brew cask) |
| 1password-cli | ✅ Auto (yay/AUR) | ❌ Manual | ❌ Manual (brew) |
| yay (AUR helper) | ✅ Auto-built | ❌ N/A | ❌ N/A |
| steam | ✅ Auto (pacman) | ❌ Manual | ❌ N/A |
| tmux | ✅ Auto (pacman) | ❌ Manual | ❌ Manual (brew) |
| rsync | ✅ Auto (pacman) | ❌ Manual | ✅ Pre-installed |
| github-cli | ✅ Auto (pacman) | ❌ Manual | ❌ Manual (brew: gh) |
| neovim | ✅ Auto (pacman) | ❌ Manual | ❌ Manual (brew) |
| lazygit | ✅ Auto (pacman) | ❌ Manual | ❌ Manual (brew) |
| jq | ✅ Auto (pacman) | ❌ Manual | ❌ Manual (brew) |
| ripgrep | ✅ Auto (pacman) | ❌ Manual | ❌ Manual (brew) |
| fzf | ✅ Auto (pacman) | ❌ Manual | ❌ Manual (brew) |
| bat | ✅ Auto (pacman) | ❌ Manual | ❌ Manual (brew) |
| htop | ✅ Auto (pacman) | ❌ Manual | ❌ Manual (brew) |
| telegram-desktop | ✅ Auto (pacman) | ❌ Manual | ❌ Manual (brew cask: telegram) |
| grim | ✅ Auto (pacman) | ❌ N/A | ❌ N/A |
| swww | ✅ Auto (pacman) | ❌ N/A | ❌ N/A |
| playerctl | ✅ Auto (pacman) | ❌ N/A | ❌ N/A |
| pamixer | ✅ Auto (pacman) | ❌ N/A | ❌ N/A |
| pipewire* | ✅ Auto (pacman) | ❌ N/A | ❌ N/A |
| **Machine-Specific** |
| radeontop | ✅ Auto (shinkiro only) | ❌ N/A | ❌ N/A |
| corectrl | ✅ Auto (shinkiro only) | ❌ N/A | ❌ N/A |
| **Development Tools** |
| rbenv | ✅ Auto (pacman) | ✅ Auto (git clone) | ✅ Auto (git clone) |
| ruby-build | ✅ Auto (yay/AUR) | ✅ Auto (git clone) | ✅ Auto (git clone) |
| nodenv | ✅ Auto (git clone) | ✅ Auto (git clone) | ✅ Auto (git clone) |
| node-build | ✅ Auto (git clone) | ✅ Auto (git clone) | ✅ Auto (git clone) |

### Configuration Files Linked

| Configuration | Personal Linux | Work Linux | macOS | Notes |
|--------------|----------------|------------|--------|-------|
| **Shell & Terminal** |
| oh-my-zsh | ✅ | ✅ | ✅ | Installed fresh if missing |
| .zshrc settings | ✅ | ✅ | ✅ | Theme: agnoster, plugins configured |
| .oh-my-zsh/custom/utils.zsh | ✅ | ✅ | ✅ | Custom utilities |
| .oh-my-zsh/custom/ruby_aliases.zsh | ✅ | ✅ | ✅ | Ruby development aliases |
| .oh-my-zsh/custom/bedtime-prompt.zsh | ✅ | ✅ | ✅ | Bedtime reminder in prompt |
| .tmux.conf | ✅ | ✅ | ✅ | Terminal multiplexer config |
| **Desktop Environment** |
| hypr/ | ✅ | ❌ | ❌ | Hyprland compositor config |
| waybar/ | ✅ | ❌ | ❌ | Status bar configuration |
| eww/ | ✅ Machine-specific | ❌ | ❌ | Widget system (shinkiro/kyrios only) |
| wofi/ | ✅ | ❌ | ❌ | Application launcher |
| dunst/ | ✅ | ❌ | ❌ | Notification daemon |
| wlogout/ | ✅ | ❌ | ❌ | Logout menu |
| **Applications** |
| ghostty/ | ✅ | ✅ | ✅ | Terminal emulator |
| nvim/ | ✅ | ✅ | ✅ | Neovim configuration |
| btop/ | ✅ | ✅ | ✅ | System monitor |
| thunar/ | ✅ | ❌ | ❌ | File manager + GTK theme |
| gtk-3.0/gtk.css | ✅ | ❌ | ❌ | GTK3 dark theme |
| **System Services** |
| bedtime/ scripts | ✅ | ❌ | ❌ | Bedtime check scripts |
| systemd bedtime timer | ✅ | ❌ | ❌ | Automated bedtime reminders |

### Legend
- ✅ = Installed/Linked automatically
- ❌ = Not installed/linked
- N/A = Not applicable for this platform
- Manual = Requires manual installation

## Directory Structure

The playbook expects this directory structure:
```
dotfiles/
├── common/           # Shared configs for personal machines
│   ├── hypr/
│   ├── waybar/
│   ├── eww/
│   ├── btop/
│   ├── ghostty/
│   ├── nvim/
│   └── .oh-my-zsh/custom/
├── kyrios/          # Laptop-specific configs
│   ├── hypr/
│   └── waybar/
├── shinkiro/        # Desktop-specific configs
│   ├── hypr/
│   ├── waybar/
│   └── eww/
└── setup-dotfiles.yml
```

## Special Handling

### Hyprland Configuration
- Machine-specific configs source the common configuration
- Uses absolute paths (~/.config/hypr/common.conf) for reliability

### Waybar Configuration
- Modular design with common base and machine-specific overrides
- Common modules shared between machines
- Machine-specific configs for hardware differences

### eww Widget System
- Only configured on machines that have eww directories
- Machine-specific configurations (not in common)

### macOS Compatibility
The playbook automatically skips Linux-specific features on macOS:
- systemd services
- Wayland/X11 tools
- Package management

### Git Configuration with 1Password SSH Signing
The playbook configures Git with your identity and enables SSH commit signing via 1Password on **all machines**.

#### Configuration Options
You can customize git settings using one of these methods (in order of precedence):

1. **Private Configuration Submodule** (Recommended for sensitive data):
   - See `PRIVATE-CONFIG-SETUP.md` for detailed setup instructions
   - Store sensitive values in a private repository as a git submodule
   - Most secure option for public dotfiles repositories

2. **Environment Variables**:
   - `GIT_USER_NAME`: Your git username (default: "Paolo Fabbri")  
   - `GIT_USER_EMAIL`: Your git email (default: "jabawack81@gmail.com")
   - `SSH_SIGNING_KEY`: Your SSH public key for commit signing

3. **Hardcoded Defaults**: Falls back to original values if none of the above are set

#### Configuration
- Sets user name and email (customizable via environment variables)
- Sets default branch to `main`
- Enables SSH commit signing using 1Password
- Configures the correct op-ssh-sign path for each platform

Requirements:
- 1Password desktop app installed
- SSH key added to 1Password
- SSH key added to GitHub as both authentication and signing key

### GitHub CLI with 1Password Integration
The playbook automatically configures the GitHub CLI (`gh`) to use 1Password for secure token storage on **all machines**:
- Sets git protocol to SSH
- Configures OAuth token to use 1Password reference
- Creates the necessary configuration in `~/.config/gh/hosts.yml`
- Works on both personal machines and work machines

Requirements:
- GitHub Personal Access Token stored in 1Password as "GitHub Personal Access Token"
- 1Password CLI installed and signed in (`op signin`)
- On personal machines: 1password-cli is installed automatically via AUR
- On work machines: Install manually with `brew install 1password-cli`

### Development Version Managers
The playbook installs and configures version managers on **all machines**:

#### rbenv (Ruby Version Manager)
- Personal machines: Installed via pacman with ruby-build from AUR
- Work machines: Cloned from GitHub repositories
- Automatically added to `.zshrc` with proper PATH configuration
- Includes `rbenv-default-gems` plugin for auto-installing essential gems
- Default gems include: ruby-lsp, solargraph, rubocop, pry, rails, rspec, bundler

#### nodenv (Node.js Version Manager)
- All machines: Cloned from GitHub with node-build plugin
- Automatically added to `.zshrc` with proper PATH configuration
- Includes `nodenv-default-packages` plugin for auto-installing essential npm packages
- Default packages include: @anthropic/claude-cli, typescript, eslint, prettier, jest, vite, pnpm

After installation, you can:
- Install Ruby: `rbenv install 3.3.0 && rbenv global 3.3.0` (auto-installs default gems)
- Install Node: `nodenv install 20.11.0 && nodenv global 20.11.0` (auto-installs default packages)

### Additional Development Tools (All Machines)
The playbook also installs and configures:

#### pnpm
- Fast, disk-space efficient package manager for Node.js
- Automatically added to PATH
- Use like npm: `pnpm install`, `pnpm run dev`

#### SDKMAN!
- Version manager for JVM-based tools (Java, Kotlin, Scala, Gradle, Maven, etc.)
- Install Java: `sdk install java 21.0.1-tem`
- List versions: `sdk list java`

#### g (Go Version Manager)
- Simple Go version management
- Install Go: `g install latest`
- List versions: `g list`

### Shell Enhancements
- **1Password CLI integration**: Automatically sources plugins if available
- **Common PATH**: Adds `~/.local/bin` to PATH
- **Oh-My-Zsh settings**: 
  - Sets update mode to reminder
  - Enables completion waiting dots for better UX

## Running the Playbook

### Initial Setup
```bash
./setup.sh
```

This script will:
1. Install ansible if needed
2. Run the playbook
3. Show before/after symlink status

### Direct Ansible Run
```bash
ansible-playbook setup-dotfiles.yml
```

### Cleanup Broken Symlinks
```bash
./cleanup-broken-links.sh
```

## Troubleshooting

### Hyprland hotkeys not working
- Check that hyprland.conf properly sources common.conf
- Verify symlinks: `ls -la ~/.config/hypr/`

### Waybar not starting
- Check the waybar-launcher.sh script is executable
- Look for multiple waybar instances: `ps aux | grep waybar`

### Permissions issues
- The playbook uses `become: yes` for system-level tasks
- User-level tasks run without sudo

### macOS issues
- Ensure Xcode Command Line Tools are installed
- Some features are Linux-only and will be skipped

## Adding New Configurations

1. Place common configs in `common/` directory
2. Add machine-specific overrides in `kyrios/` or `shinkiro/`
3. Update `work_configs` list if the config should be available on work machines
4. Run the playbook to create symlinks

## Security Notes

- The playbook never modifies existing user files
- Symlinks can be easily removed without data loss
- Work machines get minimal configuration to avoid conflicts
- No credentials or secrets are stored in the repository