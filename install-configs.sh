#!/bin/bash

# Dotfiles installation script with hostname-based configuration
# Automatically detects system hostname and applies appropriate configs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get hostname
HOSTNAME=$(hostname)

# Check if hostname config exists
if [[ ! -d "$SCRIPT_DIR/$HOSTNAME" ]]; then
    echo -e "${RED}Error: No configuration found for hostname '$HOSTNAME'${NC}"
    echo -e "${YELLOW}Available configurations:${NC}"
    for dir in "$SCRIPT_DIR"/*; do
        if [[ -d "$dir" && "$(basename "$dir")" != "thunar" ]]; then
            echo -e "  - $(basename "$dir")"
        fi
    done
    exit 1
fi

CONFIG_DIR="$SCRIPT_DIR/$HOSTNAME"
echo -e "${BLUE}Using configuration for hostname: $HOSTNAME${NC}"

# Function to create symlink with checks
create_symlink() {
    local source="$1"
    local target="$2"
    local config_name="$3"
    
    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    # Check if target exists
    if [[ -L "$target" ]]; then
        # It's a symlink, check if it points to the right place
        if [[ "$(readlink "$target")" == "$source" ]]; then
            echo -e "${GREEN}✓ $config_name already correctly linked${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠ $config_name symlink exists but points to wrong location${NC}"
            echo -e "  Current: $(readlink "$target")"
            echo -e "  Expected: $source"
            read -p "Replace symlink? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                rm "$target"
            else
                echo -e "${YELLOW}Skipping $config_name${NC}"
                return 0
            fi
        fi
    elif [[ -f "$target" || -d "$target" ]]; then
        # It's a regular file/directory
        echo -e "${YELLOW}⚠ $config_name exists as regular file/directory${NC}"
        echo -e "  Path: $target"
        read -p "Backup and replace with symlink? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            mv "$target" "$target.backup.$(date +%Y%m%d_%H%M%S)"
            echo -e "${BLUE}Backed up original to $target.backup.$(date +%Y%m%d_%H%M%S)${NC}"
        else
            echo -e "${YELLOW}Skipping $config_name${NC}"
            return 0
        fi
    fi
    
    # Create the symlink
    ln -s "$source" "$target"
    echo -e "${GREEN}✓ Created symlink for $config_name${NC}"
}

# Function to install Oh My Zsh plugins
install_oh_my_zsh_plugins() {
    echo -e "${BLUE}Installing Oh My Zsh plugins...${NC}"
    
    # Check if Oh My Zsh is installed
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo -e "${YELLOW}Oh My Zsh not found. Skipping plugin installation.${NC}"
        return 0
    fi
    
    # zsh-syntax-highlighting
    if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
        echo -e "${BLUE}Installing zsh-syntax-highlighting...${NC}"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
        echo -e "${GREEN}✓ zsh-syntax-highlighting installed${NC}"
    else
        echo -e "${GREEN}✓ zsh-syntax-highlighting already installed${NC}"
    fi
    
    # zsh-autosuggestions
    if [[ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
        echo -e "${BLUE}Installing zsh-autosuggestions...${NC}"
        git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
        echo -e "${GREEN}✓ zsh-autosuggestions installed${NC}"
    else
        echo -e "${GREEN}✓ zsh-autosuggestions already installed${NC}"
    fi
}

# Function to install Thunar theme
install_thunar_theme() {
    echo -e "${BLUE}Installing Thunar theme...${NC}"
    
    local thunar_dir="$CONFIG_DIR/thunar"
    
    if [[ ! -d "$thunar_dir" ]]; then
        echo -e "${YELLOW}Thunar configuration not found for $HOSTNAME. Skipping.${NC}"
        return 0
    fi
    
    # GTK3 theme
    if [[ -f "$thunar_dir/gtk.css" ]]; then
        create_symlink "$thunar_dir/gtk.css" "$HOME/.config/gtk-3.0/gtk.css" "Thunar GTK3 theme"
    fi
    
    # GTK2 theme (for older systems)
    if [[ -f "$thunar_dir/gtkrc-2.0" ]]; then
        create_symlink "$thunar_dir/gtkrc-2.0" "$HOME/.gtkrc-2.0.thunar" "Thunar GTK2 theme"
    fi
}

# Function to install Hyprland config
install_hyprland_config() {
    echo -e "${BLUE}Installing Hyprland configuration...${NC}"
    
    if [[ -f "$CONFIG_DIR/hypr/hyprland.conf" ]]; then
        create_symlink "$CONFIG_DIR/hypr/hyprland.conf" "$HOME/.config/hypr/hyprland.conf" "Hyprland config"
    fi
    
    if [[ -f "$CONFIG_DIR/hypr/hyprlock.conf" ]]; then
        create_symlink "$CONFIG_DIR/hypr/hyprlock.conf" "$HOME/.config/hypr/hyprlock.conf" "Hyprlock config"
    fi
    
    # Copy fonts if they exist
    if [[ -d "$CONFIG_DIR/hypr/Fonts" ]]; then
        echo -e "${BLUE}Installing fonts...${NC}"
        mkdir -p "$HOME/.local/share/fonts"
        cp -r "$CONFIG_DIR/hypr/Fonts/"* "$HOME/.local/share/fonts/"
        fc-cache -f
        echo -e "${GREEN}✓ Fonts installed and cache updated${NC}"
    fi
    
    # Copy wallpapers/images
    if [[ -f "$CONFIG_DIR/hypr/hyprlock.png" ]]; then
        mkdir -p "$HOME/.config/hypr"
        cp "$CONFIG_DIR/hypr/hyprlock.png" "$HOME/.config/hypr/"
        echo -e "${GREEN}✓ Hyprlock wallpaper copied${NC}"
    fi
    
    if [[ -f "$CONFIG_DIR/hypr/jabawack.jpg" ]]; then
        mkdir -p "$HOME/.config/hypr"
        cp "$CONFIG_DIR/hypr/jabawack.jpg" "$HOME/.config/hypr/"
        echo -e "${GREEN}✓ Wallpaper copied${NC}"
    fi
}

# Function to install Waybar config
install_waybar_config() {
    echo -e "${BLUE}Installing Waybar configuration...${NC}"
    
    if [[ -f "$CONFIG_DIR/waybar/config" ]]; then
        create_symlink "$CONFIG_DIR/waybar/config" "$HOME/.config/waybar/config" "Waybar config"
    fi
    
    if [[ -f "$CONFIG_DIR/waybar/style.css" ]]; then
        create_symlink "$CONFIG_DIR/waybar/style.css" "$HOME/.config/waybar/style.css" "Waybar style"
    fi
}

# Main installation function
main() {
    echo -e "${BLUE}=== Dotfiles Installation Script ===${NC}"
    echo -e "${BLUE}Hostname: $HOSTNAME${NC}"
    echo -e "${BLUE}Config directory: $CONFIG_DIR${NC}"
    echo

    # Install Oh My Zsh plugins
    install_oh_my_zsh_plugins
    echo

    # Install Thunar theme
    install_thunar_theme
    echo

    # Install Hyprland config
    install_hyprland_config
    echo

    # Install Waybar config
    install_waybar_config
    echo

    echo -e "${GREEN}=== Installation Complete ===${NC}"
    echo -e "${YELLOW}Note: You may need to restart applications or log out/in for changes to take effect.${NC}"
}

# Run main function
main "$@"