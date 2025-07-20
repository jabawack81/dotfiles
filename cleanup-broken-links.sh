#!/bin/bash

CONFIG_DIR="$HOME/.config"
BROKEN_LINKS=()
VALID_LINKS=()

echo "Checking for symlinks in $CONFIG_DIR..."
echo "========================================="

# Find all symlinks in .config directory
while IFS= read -r -d '' link; do
    if [ -L "$link" ]; then
        # Check if the symlink target exists
        if [ -e "$link" ]; then
            VALID_LINKS+=("$link")
        else
            BROKEN_LINKS+=("$link")
        fi
    fi
done < <(find "$CONFIG_DIR" -type l -print0 2>/dev/null)

# Report valid links
if [ ${#VALID_LINKS[@]} -gt 0 ]; then
    echo -e "\nValid symlinks found:"
    for link in "${VALID_LINKS[@]}"; do
        target=$(readlink -f "$link" 2>/dev/null || readlink "$link")
        echo "  ✓ $link -> $target"
    done
fi

# Report and handle broken links
if [ ${#BROKEN_LINKS[@]} -gt 0 ]; then
    echo -e "\nBroken symlinks found:"
    for link in "${BROKEN_LINKS[@]}"; do
        target=$(readlink "$link")
        echo "  ✗ $link -> $target (BROKEN)"
    done
    
    echo -e "\nDo you want to delete these broken symlinks? [y/N]"
    read -r response
    
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        for link in "${BROKEN_LINKS[@]}"; do
            echo "Removing broken symlink: $link"
            rm "$link"
        done
        echo "Broken symlinks removed."
    else
        echo "Broken symlinks kept."
    fi
else
    echo -e "\nNo broken symlinks found in $CONFIG_DIR"
fi

echo -e "\nSummary:"
echo "  Valid symlinks: ${#VALID_LINKS[@]}"
echo "  Broken symlinks: ${#BROKEN_LINKS[@]}"