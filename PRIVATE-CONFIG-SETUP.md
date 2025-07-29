# Private Configuration Setup

This guide explains how to set up a private configuration submodule for storing sensitive dotfiles data.

## Why Use a Private Submodule?

- Keeps sensitive data (SSH keys, email addresses, API keys) out of public repositories
- Maintains all the benefits of version control for your private config
- Allows easy updates without exposing secrets
- Works seamlessly with the existing Ansible playbook

## Setup Steps

### 1. Create a Private Repository

Create a new **private** repository on GitHub (or your preferred Git host):
```bash
# Example repository name: dotfiles-private-config
```

### 2. Initialize the Private Config Repository

```bash
# Clone your new private repository
git clone git@github.com:yourusername/dotfiles-private-config.git
cd dotfiles-private-config

# Copy the example configuration
cp /path/to/dotfiles/private-config-example/* .

# Edit config.yml with your actual values
vim config.yml

# Commit and push
git add .
git commit -m "Initial private configuration"
git push origin main
```

### 3. Add as Submodule

From your main dotfiles repository:
```bash
cd /path/to/dotfiles

# Add the private repo as a submodule
git submodule add git@github.com:yourusername/dotfiles-private-config.git private-config

# Commit the submodule addition
git add .gitmodules private-config
git commit -m "Add private configuration submodule"
git push origin main
```

### 4. Setup on New Machines

When cloning your dotfiles on a new machine:
```bash
# Clone with submodules
git clone --recurse-submodules git@github.com:yourusername/dotfiles.git

# Or if already cloned, initialize submodules
git submodule update --init --recursive
```

## Configuration Structure

Your private-config structure:

```
private-config/
├── config.yml                      # Main configuration file
└── logos/                          # Company/organization logos
    ├── default_logo_raw.txt        # Default logo for unknown machines
    ├── paolofabbri_logo_raw.txt    # Logo for PaoloFabbri (work laptop)
    ├── kyrios_logo_raw.txt         # Logo for kyrios (personal laptop)
    └── shinkiro_logo_raw.txt       # Logo for shinkiro (personal desktop)
```

The `config.yml` should contain:

```yaml
# Git Configuration
git_user_name: "Your Name"
git_user_email: "your.email@example.com"

# SSH Signing Key
ssh_signing_key: "ssh-ed25519 AAAAC3Nza..."

# Weather API (optional, for eww widgets)
weather_api_key: "your_api_key"
weather_city_id: "your_city_id"
```

Company logos (like `boxt_logo_raw.txt`) should be ASCII art files with ANSI color codes.

## Usage

The Ansible playbook automatically:
1. Checks if `private-config/config.yml` exists
2. Loads variables from it if found
3. Falls back to defaults (from environment variables) if not found
4. Uses hardcoded fallbacks as last resort

## Updating Configuration

To update your private configuration:
```bash
cd private-config
vim config.yml
git add config.yml
git commit -m "Update configuration"
git push origin main

# Update the submodule reference in main repo
cd ..
git add private-config
git commit -m "Update private config submodule"
git push origin main
```

## Security Best Practices

- ✅ Keep the private repository **private**
- ✅ Use SSH keys for authentication to the private repo
- ✅ Review all values before committing
- ✅ Use `.gitignore` in the private repo if needed
- ❌ Never commit the private config to the public repository
- ❌ Never share the private repository URL publicly

## Troubleshooting

### Submodule Not Loaded
```bash
git submodule update --init --recursive
```

### Private Repository Access Issues
- Ensure your SSH key has access to the private repository
- Check that the repository URL is correct in `.gitmodules`

### Configuration Not Applied
- Verify `private-config/config.yml` exists and is valid YAML
- Check the playbook output for "Private config loaded: true"