#!/bin/bash

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
            if [ -e "$link" ]; then
                echo "  ✓ ${link#$HOME/} -> $target"
            else
                echo "  ✗ ${link#$HOME/} -> $target (BROKEN)"
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
    else
        echo "Unsupported distribution. Please install ansible manually."
        exit 1
    fi
fi

# Run the ansible playbook
echo -e "\n=== Running Ansible Playbook ==="
echo "Setting up dotfiles for hostname: $(cat /etc/hostname 2>/dev/null || echo 'unknown')"
ansible-playbook setup-dotfiles.yml --ask-become-pass

# Check symlinks after running ansible
check_symlinks "Post-Setup"

# Show what might be missing
echo -e "\n=== Potential Missing Configs ==="
echo "Checking for configs in dotfiles that might not be linked..."

# Check common directory
if [ -d "$DOTFILES_DIR/common" ]; then
    for dir in "$DOTFILES_DIR/common"/*; do
        if [ -d "$dir" ]; then
            dirname=$(basename "$dir")
            if [ ! -L "$HOME/.config/$dirname" ] && [ ! -e "$HOME/.config/$dirname" ]; then
                echo "  ⚠ common/$dirname is not linked"
            fi
        fi
    done
fi

# Check hostname-specific directory
HOSTNAME=$(cat /etc/hostname 2>/dev/null || echo 'unknown')
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