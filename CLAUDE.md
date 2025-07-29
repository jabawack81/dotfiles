# CLAUDE.md

Architectural Documentation for AI-Assisted Development

## Session Initialization

When starting a new session, ALWAYS:
1. Run `hostname` to detect which machine we're on
2. Check if it's kyrios (laptop), shinkiro (desktop), or a work machine
3. Adapt responses based on the current environment:
   - **kyrios**: Intel laptop, no AMD GPU tools, limited screen space
   - **shinkiro**: AMD desktop, dual 4K monitors, full GPU capabilities
   - **work machines**: Limited configs, likely macOS, restricted permissions

## Executive Summary

This repository exemplifies a sophisticated approach to dotfiles management, implementing a declarative Infrastructure-as-Code pattern using Ansible. The architecture demonstrates advanced DevOps principles including idempotency, modularity, and environment-specific customization while maintaining DRY principles across heterogeneous systems.

## System Architecture

### Multi-Environment Strategy

The repository implements a hierarchical configuration model supporting three distinct environments:

- **kyrios**: Laptop workstation (Intel architecture)
- **shinkiro**: Desktop development environment (AMD architecture)
- **work**: Restricted configuration subset for non-personal systems

Current machine detection should be performed at session start using `hostname` command.

### Configuration Hierarchy

```
Repository Structure:
├── common/          # Shared baseline configurations
├── kyrios/         # Laptop-specific overrides
├── shinkiro/       # Desktop-specific overrides
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
  - eww widgets configured for larger screen
  - Dual monitor workspace rules

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
- **eww**: Widget system with system monitoring, weather, and app launcher
- **fuzzel**: Application launcher with Nord-inspired styling
- **dunst**: Notification daemon with custom icons
- **wlogout**: Session logout menu
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
- Transitioning to new tools (e.g., wofi → fuzzel)

## Conclusion

This dotfiles repository represents a production-grade approach to personal system configuration, demonstrating deep understanding of:
- Infrastructure as Code principles
- Cross-platform compatibility challenges
- Modern DevOps best practices
- Security-first design patterns

The implementation balances sophistication with maintainability, ensuring long-term sustainability of the configuration management system.