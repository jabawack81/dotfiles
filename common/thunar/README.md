# Thunar Configuration

This directory contains Thunar file manager theme configurations that match the waybar dark theme style.

## Files

- `gtkrc-2.0`: GTK2 theme configuration for older GTK applications
- `gtk.css`: GTK3/4 theme configuration for modern GTK applications

## Installation

### For GTK2 (older versions):
```bash
mkdir -p ~/.config/Thunar
cp gtkrc-2.0 ~/.config/Thunar/
```

### For GTK3/4 (modern versions):
```bash
mkdir -p ~/.config/gtk-3.0
cp gtk.css ~/.config/gtk-3.0/gtk.css

# Or for application-specific styling:
mkdir -p ~/.config/Thunar
cp gtk.css ~/.config/Thunar/
```

## Color Scheme

The theme uses the same color palette as your waybar configuration:
- Background: #1a1a1a (dark gray)
- Secondary background: #292b2e (medium gray)
- Text: #fdf6e3 (cream)
- Selection: #268bd2 (blue)
- Accent colors matching waybar components

## Usage

After installation, restart Thunar or log out and back in for the changes to take effect. The theme will provide a consistent dark appearance that matches your waybar styling.