#!/bin/bash

# Warning about sudo usage
if [ "$EUID" -eq 0 ] && [ -z "$SUDO_USER" ]; then
    echo "ERROR: Do not run this script as root directly!"
    echo "If you need root privileges for package installation, use: sudo -E ./setup.sh"
    exit 1
fi

# Function to check all symlinks in .config and home
check_symlinks() {
    local check_type="$1"
    echo -e "\n=== $check_type Check ==="
    echo "Checking symlinks in ~/.config and ~ ..."
    
    # Check .config directory
    echo -e "\nSymlinks in ~/.config:"
    if [ -d "$HOME/.config" ]; then
        find "$HOME/.config" -type l -print0 2>/dev/null | while IFS= read -r -d '' link; do
            target=$(readlink "$link")
            basename_link=$(basename "$link")
            if [ -e "$link" ]; then
                echo "  ✓ ${link#$HOME/} -> $target"
            else
                # On macOS, some symlinks are expected to be broken (Linux-only configs)
                if [[ "$OSTYPE" == "darwin"* ]] && [[ " hypr waybar wofi dunst wlogout " =~ " $basename_link " ]]; then
                    echo "  ⚠ ${link#$HOME/} -> $target (Linux-only, expected broken on macOS)"
                else
                    echo "  ✗ ${link#$HOME/} -> $target (BROKEN)"
                fi
            fi
        done | sort
    else
        echo "  ~/.config directory doesn't exist"
    fi
    
    # Check specific dotfiles in home directory
    echo -e "\nDotfiles symlinks in ~:"
    for dotfile in .tmux.conf .zshrc .bashrc .vimrc .gitconfig; do
        if [ -L "$HOME/$dotfile" ]; then
            target=$(readlink "$HOME/$dotfile")
            if [ -e "$HOME/$dotfile" ]; then
                echo "  ✓ $dotfile -> $target"
            else
                echo "  ✗ $dotfile -> $target (BROKEN)"
            fi
        elif [ -e "$HOME/$dotfile" ]; then
            echo "  • $dotfile (regular file, not a symlink)"
        fi
    done
    
    # Count symlinks pointing to our dotfiles directory
    local our_links=$(find "$HOME/.config" -type l -print0 2>/dev/null | xargs -0 -I {} readlink {} 2>/dev/null | grep -c "$(pwd)" || echo 0)
    echo -e "\nTotal symlinks pointing to this dotfiles directory: $our_links"
}

# Save current directory
DOTFILES_DIR="$(pwd)"

# Check symlinks before running ansible
check_symlinks "Pre-Setup"

# Check if ansible is installed
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "\nAnsible is not installed. Installing..."
    if [ -f /etc/arch-release ]; then
        sudo pacman -S ansible --noconfirm
    elif [ -f /etc/debian_version ]; then
        sudo apt update && sudo apt install -y ansible
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            echo "Installing ansible via Homebrew..."
            brew install ansible
        else
            echo "Homebrew not found. Please install Homebrew first:"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            exit 1
        fi
    else
        echo "Unsupported distribution. Please install ansible manually."
        exit 1
    fi
fi

# Run the ansible playbook
echo -e "\n=== Running Ansible Playbook ==="
echo "Setting up dotfiles for hostname: $(hostname 2>/dev/null || echo 'unknown')"

# Run the playbook - it's smart enough to handle both root and non-root execution
if [ "$EUID" -eq 0 ]; then
    echo "Running as root with target user: ${SUDO_USER:-$USER}"
    ansible-playbook setup-dotfiles.yml
else
    echo "Running as regular user"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS doesn't need sudo for our playbook
        echo "Note: Running on macOS - no sudo required"
        ansible-playbook setup-dotfiles.yml
    else
        # Linux (Arch) might need sudo for package installation
        echo "Note: For automatic AUR package installation, run: sudo -E ./setup.sh"
        ansible-playbook setup-dotfiles.yml --ask-become-pass
    fi
fi

# Check symlinks after running ansible
check_symlinks "Post-Setup"

# Show what might be missing
echo -e "\n=== Potential Missing Configs ==="
echo "Checking for configs in dotfiles that might not be linked..."

# Define work machine configs (from playbook)
WORK_CONFIGS="btop ghostty nvim lazygit broot"

# Check common directory
if [ -d "$DOTFILES_DIR/common" ]; then
    for dir in "$DOTFILES_DIR/common"/*; do
        if [ -d "$dir" ]; then
            dirname=$(basename "$dir")
            # On macOS (work machines), only check for work configs
            if [[ "$OSTYPE" == "darwin"* ]]; then
                if [[ " $WORK_CONFIGS " =~ " $dirname " ]] && [ ! -L "$HOME/.config/$dirname" ] && [ ! -e "$HOME/.config/$dirname" ]; then
                    echo "  ⚠ common/$dirname is not linked"
                fi
            else
                # On Linux (personal machines), check all configs
                if [ ! -L "$HOME/.config/$dirname" ] && [ ! -e "$HOME/.config/$dirname" ]; then
                    echo "  ⚠ common/$dirname is not linked"
                fi
            fi
        fi
    done
fi

# Check hostname-specific directory
HOSTNAME=$(hostname 2>/dev/null || echo 'unknown')
if [ -d "$DOTFILES_DIR/$HOSTNAME" ]; then
    for dir in "$DOTFILES_DIR/$HOSTNAME"/*; do
        if [ -d "$dir" ]; then
            dirname=$(basename "$dir")
            if [ ! -L "$HOME/.config/$dirname" ] && [ ! -e "$HOME/.config/$dirname" ]; then
                echo "  ⚠ $HOSTNAME/$dirname is not linked"
            fi
        fi
    done
else
    echo "  ℹ No hostname-specific directory found for: $HOSTNAME"
fi

# Check root-level dotfiles
for dotfile in .tmux.conf .zshrc .bashrc .vimrc .gitconfig; do
    if [ -f "$DOTFILES_DIR/$dotfile" ] && [ ! -L "$HOME/$dotfile" ]; then
        echo "  ⚠ $dotfile exists in dotfiles but is not linked"
    fi
done

echo -e "\nSetup complete!"