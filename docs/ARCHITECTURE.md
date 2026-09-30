# CLAUDE.md

Architectural Documentation for AI-Assisted Development

## Session Initialization

When starting a new session, ALWAYS:
1. Run `hostname` to detect which machine we're on
2. Check if it's kyrios (laptop), shinkiro (desktop), barbatos (ThinkPad T470p), virtue (Debian server), or a work machine
3. Adapt responses based on the current environment:
   - **kyrios**: Intel laptop, no AMD GPU tools, limited screen space
   - **shinkiro**: AMD desktop, dual 4K monitors, full GPU capabilities
   - **barbatos**: ThinkPad T470p, Intel+NVIDIA 940MX hybrid, legacy NVIDIA 580xx driver, fingerprint reader
   - **virtue** (and any Debian host): Headless server, shell + Neovim + dev toolchain, no desktop
   - **work machines**: Limited configs, likely macOS, restricted permissions

## Executive Summary

This repository exemplifies a sophisticated approach to dotfiles management, implementing a declarative Infrastructure-as-Code pattern using Ansible. The architecture demonstrates advanced DevOps principles including idempotency, modularity, and environment-specific customization while maintaining DRY principles across heterogeneous systems.

## System Architecture

### Multi-Environment Strategy

The repository implements a hierarchical configuration model supporting four distinct environments:

- **kyrios**: Laptop workstation (Intel architecture)
- **shinkiro**: Desktop development environment (AMD architecture)
- **barbatos**: ThinkPad T470p (Intel + NVIDIA hybrid)
- **virtue**: Headless Debian server, detected by OS family; shell and editor only
- **work**: Restricted configuration subset for non-personal systems

Current machine detection should be performed at session start using `hostname` command.

### Configuration Hierarchy

```
Repository Structure:
├── common/          # Shared baseline configurations
├── kyrios/         # Laptop-specific overrides
├── shinkiro/       # Desktop-specific overrides
├── barbatos/       # ThinkPad T470p overrides
├── tasks/          # Playbook task files (barbatos.yml = /etc-level hardware setup)
├── setup.sh        # Intelligent orchestration wrapper
└── setup-dotfiles.yml  # Ansible playbook with advanced logic
```

## Technical Implementation

### Ansible Automation Framework

The playbook implements several advanced patterns:

1. **Dynamic Environment Detection**: Automatically identifies system characteristics and applies appropriate configurations
2. **Idempotent Operations**: All tasks are designed for safe repeated execution
3. **Conditional Logic**: Machine-specific packages and configurations based on hostname and hardware
4. **Error Recovery**: Graceful handling of missing dependencies and permission issues

### Version Management Integration

The system automatically provisions and configures multiple language version managers:

- **rbenv/nodenv**: Git-based installation with automatic latest stable version selection
- **SDKMAN**: JVM ecosystem management with proper shell integration
- **g**: Go version management with workspace configuration
- **pnpm**: High-performance Node.js package management

### Advanced Waybar Configuration

The Waybar implementation showcases several sophisticated patterns:

1. **Dynamic Module Loading**: Hardware-specific modules (battery for laptop, GPU temp for desktop)
2. **Intelligent Service Discovery**: Auto-detection of hwmon devices for temperature monitoring
3. **Network Interface Abstraction**: Pattern matching for modern predictable interface names
4. **Environment Wrapper Scripts**: Ensuring proper PATH resolution for interpreted languages

### Hyprland Window Manager Integration

Custom configuration demonstrating:

- **Modular Configuration**: Machine configs source common base via absolute paths
- **Dynamic Key Bindings**: Hardware-specific adjustments
- **Advanced Animations**: Custom bezier curves for smooth transitions
- **Workspace Rules**: Persistent workspace configurations

## Security Architecture

### Git Commit Signing

Integrated 1Password SSH signing ensures:
- Cryptographic proof of authorship
- Hardware-backed key storage
- Seamless CI/CD integration

### Permission Management

- Minimal sudo usage with targeted privilege escalation
- Automated ownership correction for root-executed tasks
- Secure handling of user credentials

## Development Workflow

### Continuous Integration Mindset

1. **Atomic Commits**: Each change represents a complete, tested feature
2. **Conventional Commits**: Standardized commit messages for automated changelog generation
3. **Idempotent Testing**: Run `./setup.sh` multiple times without side effects

### Troubleshooting Framework

Built-in diagnostic capabilities:
- Symlink verification pre/post execution
- Automatic backup creation with timestamps
- Detailed error logging and recovery suggestions

## Machine-Specific Configurations

### kyrios (Laptop)
- **Hardware**: ThinkPad with Intel CPU/GPU
- **Display**: Single 1920x1080 screen
- **Special configs**:
  - Battery module in waybar
  - No GPU temperature monitoring (Intel integrated)
  - Power management optimizations
  - Network manager applet for WiFi

### shinkiro (Desktop)
- **Hardware**: AMD CPU and GPU
- **Display**: Dual 4K monitors (3840x2160 @ 1.5x scale = 2560x1440 effective)
- **Special configs**:
  - GPU temperature monitoring (AMD)
  - No battery module in waybar
  - Dual monitor workspace rules

### barbatos (ThinkPad T470p)
- **Hardware**: ThinkPad T470p, Intel HD 630 iGPU + NVIDIA GeForce 940MX dGPU (Maxwell), Validity fingerprint reader
- **Display**: Single 1920x1080 panel; dock monitors on DP-4/DP-5 forced to 1080p60 (the 940MX can't drive 4K smoothly)
- **OS**: Vanilla Arch Linux + Hyprland (was `lupus` on Omarchy until Sep 2026)
- **Network**: iwd + systemd-networkd + systemd-resolved with per-boot MAC randomisation (not NetworkManager)
- **Special configs** (`tasks/barbatos.yml` for /etc, `barbatos/` for user configs):
  - NVIDIA legacy driver (nvidia-580xx-dkms from AUR — Maxwell is not supported by nvidia-open, which the playbook removes)
  - EnvyControl mode set by `barbatos_gpu_mode` (default `hybrid`: desktop on Intel, `prime-run` for the dGPU; `integrated` powers it off — the 940MX has no RTD3, so in hybrid it never sleeps)
  - Suspend handled by a system-sleep hook that removes the GPU from the PCI bus (the nvidia-suspend/resume services are disabled on purpose)
  - `cursor.no_hardware_cursors = true`; the global NVIDIA GL/VA env vars are intentionally not set
  - Lid switch turns the panel off and stops the fingerprint daemon (`barbatos/hypr/lid.sh`)
  - Fingerprint via python-validity + open-fprintd, pam_fprintd first for sudo/su/hyprlock/sddm/polkit
  - ThinkPad fan control (`thinkpad_acpi fan_control=1`) feeding the waybar fan module

### Debian Servers (virtue)
- **OS**: Debian (any host where `ansible_facts['os_family'] == 'Debian'`)
- **Installed**: zsh + oh-my-zsh, Neovim from the official release tarball (`/opt/nvim`), lazygit, tmux, LazyVim build deps, and the standard dev toolchain (rbenv, nodenv, pnpm, SDKMAN, g)
- **Linked**: `nvim` config and `.tmux.conf`
- **Skipped**: desktop, Claude Code

### Work Machines
- **OS**: Typically macOS
- **Restrictions**: Limited to terminal tools (ghostty, nvim, btop, broot, lazygit)
- **No access to**: Wayland tools, system services, GUI customizations

## Configured Applications

### Terminal User Interface (TUI) Tools

All TUI applications are configured with the Nord theme for visual consistency:

- **btop**: System resource monitor with Nord theme
- **neovim**: Modal text editor with LazyVim and Nord colorscheme
- **lazygit**: Git TUI with custom Nord theme configuration
- **broot**: File browser with custom Nord theme and cross-platform verbs
- **ghostty**: GPU-accelerated terminal with Nord theme and transparency
- **fastfetch**: Modern system info tool with hostname-specific logos stored in private submodule

### Wayland Desktop Components

Personal machines include:
- **Hyprland**: Tiling compositor with modular machine-specific configs
- **waybar**: Status bar with machine-specific modules (battery for laptop, GPU temp for desktop)
- **quickshell**: QML desktop shell — bar, notifications, OSD, workspace overview, omni menu
- **caelestia-shell**: third bar option, vendored at `common/caelestia-shell` (GPL-3,
  v2.5.0) with settings in `common/caelestia/shell.json`. Its QML plugin is compiled
  from that same tree by `make caelestia-build`, so QML and plugin cannot drift;
  `make caelestia-update TAG=…` re-syncs upstream. `Super+Shift+W` cycles
  waybar → quickshell → caelestia
- **shell-action.sh**: dispatches the panel keybinds (launcher, overview, DND) to
  whichever shell is running, so the same keys work in every bar on every machine
- **hyprlauncher**: Application launcher (Hypr ecosystem) with dark theme via hyprtoolkit
- **dunst**: Notification daemon with custom icons
- **wlogout**: Session logout menu
- **hypridle**: Idle management daemon (screen off, lock, suspend)
- **hyprsunset**: Blue-light filter
- **grimblast**: Screenshot tool (Hypr ecosystem wrapper around grim+slurp)
- **bedtime reminder**: Systemd timer for healthy sleep habits (school nights only)

### Development Tools

- **GitHub CLI**: Integrated with 1Password for secure authentication
- **Language version managers**: rbenv, nodenv, SDKMAN, g (Go)
- **Shell**: Zsh with Oh-My-Zsh and agnoster theme

## Performance Optimizations

### Parallel Task Execution

Where possible, the playbook leverages Ansible's parallel execution capabilities for:
- Package installation
- Symlink creation
- Configuration file generation

### Caching Strategies

- Version manager build caches
- Package manager caches preserved across runs
- Intelligent change detection to skip unnecessary operations

## Future Architecture Considerations

### Extensibility Points

The architecture is designed for easy extension:
- New machine profiles via simple directory addition
- Package lists maintained as YAML arrays
- Modular task organization for easy maintenance

### Migration Path

Clean migration strategy for:
- Moving between machines
- Upgrading system components
- Transitioning to new tools (e.g., wofi → hyprlauncher)

## Conclusion

This dotfiles repository represents a production-grade approach to personal system configuration, demonstrating deep understanding of:
- Infrastructure as Code principles
- Cross-platform compatibility challenges
- Modern DevOps best practices
- Security-first design patterns

The implementation balances sophistication with maintainability, ensuring long-term sustainability of the configuration management system.