#!/bin/bash

# Update Neovim plugins and commit changes automatically
# This script updates lazy-lock.json and commits the changes

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NVIM_CONFIG_DIR="$HOME/.config/nvim"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAZY_LOCK_FILE="$DOTFILES_DIR/common/nvim/lazy-lock.json"

echo -e "${BLUE}🔄 Neovim Plugin Update Script${NC}"
echo "=================================="

# Check if we're in the dotfiles directory
if [[ ! -f "$DOTFILES_DIR/setup-dotfiles.yml" ]]; then
    echo -e "${RED}❌ Error: This script must be run from the dotfiles directory${NC}"
    exit 1
fi

# Check if Neovim is installed
if ! command -v nvim &> /dev/null; then
    echo -e "${RED}❌ Error: Neovim is not installed or not in PATH${NC}"
    exit 1
fi

# Check if the nvim config is symlinked to our dotfiles
if [[ ! -L "$NVIM_CONFIG_DIR" ]]; then
    echo -e "${YELLOW}⚠️  Warning: $NVIM_CONFIG_DIR is not a symlink to dotfiles${NC}"
    echo "   This script assumes your nvim config is managed by dotfiles"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Aborted by user${NC}"
        exit 0
    fi
fi

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo -e "${YELLOW}⚠️  Warning: You have uncommitted changes in the repository${NC}"
    git status --short
    echo
    read -p "Continue with plugin update? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Aborted by user${NC}"
        exit 0
    fi
fi

# Backup current lazy-lock.json
if [[ -f "$LAZY_LOCK_FILE" ]]; then
    echo -e "${BLUE}📦 Creating backup of current lazy-lock.json${NC}"
    cp "$LAZY_LOCK_FILE" "$LAZY_LOCK_FILE.backup.$(date +%Y%m%d_%H%M%S)"
fi

echo -e "${BLUE}🚀 Updating Neovim plugins...${NC}"

# Update plugins using Neovim headless mode
nvim --headless "+Lazy! sync" +qa

# Check if lazy-lock.json was actually updated
if [[ -f "$LAZY_LOCK_FILE" ]]; then
    if git diff --quiet "$LAZY_LOCK_FILE"; then
        echo -e "${YELLOW}ℹ️  No plugin updates were available${NC}"
        echo -e "${GREEN}✅ Plugins are already up to date${NC}"
        exit 0
    fi
else
    echo -e "${RED}❌ Error: lazy-lock.json not found after update${NC}"
    echo "   Expected location: $LAZY_LOCK_FILE"
    exit 1
fi

echo -e "${GREEN}✅ Plugins updated successfully${NC}"

# Show what changed
echo -e "${BLUE}📋 Changes detected:${NC}"
git diff --stat "$LAZY_LOCK_FILE"

echo -e "${BLUE}🔍 Detailed changes:${NC}"
# Show a simplified diff of the plugin versions
git diff "$LAZY_LOCK_FILE" | grep -E '^[+-].*"commit"' | head -20

if git diff "$LAZY_LOCK_FILE" | grep -E '^[+-].*"commit"' | wc -l | grep -q '[2-9][0-9]\|[1-9][0-9][0-9]'; then
    echo "... (showing first 20 changes, there are more)"
fi

echo

# Commit the changes
read -p "Commit and push these changes? (Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}Changes staged but not committed${NC}"
    echo "You can review and commit manually with:"
    echo "  git add common/nvim/lazy-lock.json"
    echo "  git commit -m 'update: neovim plugin versions'"
    echo "  git push"
    exit 0
fi

# Stage the changes
git add "$LAZY_LOCK_FILE"

# Create commit message with timestamp
COMMIT_MSG="update: neovim plugin versions

Updated plugin lockfile on $(date '+%Y-%m-%d at %H:%M')

🤖 Generated with [update-nvim-plugins.sh](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Commit the changes
if git commit -m "$COMMIT_MSG"; then
    echo -e "${GREEN}✅ Changes committed successfully${NC}"
    
    # Push to remote
    echo -e "${BLUE}📤 Pushing to remote repository...${NC}"
    if git push; then
        echo -e "${GREEN}✅ Changes pushed successfully${NC}"
        echo -e "${BLUE}🎉 Plugin update complete!${NC}"
    else
        echo -e "${RED}❌ Failed to push changes${NC}"
        echo "Commit was successful, but push failed. You may need to push manually."
        exit 1
    fi
else
    echo -e "${RED}❌ Failed to commit changes${NC}"
    exit 1
fi

# Clean up old backups (keep last 5)
echo -e "${BLUE}🧹 Cleaning up old backups...${NC}"
find "$DOTFILES_DIR" -name "lazy-lock.json.backup.*" -type f | sort | head -n -5 | xargs -r rm

echo -e "${GREEN}✨ All done!${NC}"