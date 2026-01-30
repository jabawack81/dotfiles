#!/bin/bash

# Clean Neovim caches, plugins, and parsers
# LazyVim will automatically reinstall everything on next startup

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration using XDG defaults
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

NVIM_CONFIG_DIR="$HOME/.config/nvim"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Directories to clean
LAZY_DIR="$XDG_DATA_HOME/nvim/lazy"
MASON_DIR="$XDG_DATA_HOME/nvim/mason"
CACHE_DIR="$XDG_CACHE_HOME/nvim"
STATE_DIR="$XDG_STATE_HOME/nvim"

# Parse command line arguments
INCLUDE_STATE=false
FORCE=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --state)
            INCLUDE_STATE=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: clean-nvim.sh [OPTIONS]"
            echo ""
            echo "Clean Neovim caches, plugins, and parsers."
            echo "LazyVim will automatically reinstall everything on next startup."
            echo ""
            echo "Options:"
            echo "  --state     Also delete undo history, swap files, shada (destructive)"
            echo "  --force     Skip confirmation prompts"
            echo "  --dry-run   Show what would be deleted without deleting"
            echo "  -h, --help  Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}🧹 Neovim Cache/Plugin Cleanup Script${NC}"
echo "========================================"

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
    if [[ "$FORCE" = false ]]; then
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Aborted by user${NC}"
            exit 0
        fi
    fi
fi

# Check if Neovim is running
if pgrep -x "nvim" > /dev/null; then
    echo -e "${RED}❌ Error: Neovim is currently running${NC}"
    echo "   Please close all Neovim instances before cleaning"
    exit 1
fi

# Build list of directories to clean
declare -a DIRS_TO_CLEAN
declare -a DIR_DESCRIPTIONS

if [[ -d "$LAZY_DIR" ]]; then
    DIRS_TO_CLEAN+=("$LAZY_DIR")
    DIR_DESCRIPTIONS+=("Plugin installations (lazy.nvim)")
fi

if [[ -d "$MASON_DIR" ]]; then
    DIRS_TO_CLEAN+=("$MASON_DIR")
    DIR_DESCRIPTIONS+=("LSP servers, formatters (mason)")
fi

if [[ -d "$CACHE_DIR" ]]; then
    DIRS_TO_CLEAN+=("$CACHE_DIR")
    DIR_DESCRIPTIONS+=("Cache, treesitter parsers")
fi

if [[ "$INCLUDE_STATE" = true ]] && [[ -d "$STATE_DIR" ]]; then
    DIRS_TO_CLEAN+=("$STATE_DIR")
    DIR_DESCRIPTIONS+=("Undo history, shada, swap files")
fi

# Check if there's anything to clean
if [[ ${#DIRS_TO_CLEAN[@]} -eq 0 ]]; then
    echo -e "${GREEN}✅ Nothing to clean - directories don't exist${NC}"
    exit 0
fi

# Show what will be deleted with sizes
echo ""
echo -e "${BLUE}📁 Directories to delete:${NC}"
echo ""

TOTAL_SIZE=0
for i in "${!DIRS_TO_CLEAN[@]}"; do
    dir="${DIRS_TO_CLEAN[$i]}"
    desc="${DIR_DESCRIPTIONS[$i]}"
    size=$(du -sh "$dir" 2>/dev/null | cut -f1)
    echo -e "  ${YELLOW}$dir${NC}"
    echo -e "     └─ $desc (${GREEN}$size${NC})"
done

echo ""

# Dry run mode - just show what would be deleted
if [[ "$DRY_RUN" = true ]]; then
    echo -e "${BLUE}🔍 Dry run mode - no files will be deleted${NC}"
    echo ""
    echo "The following directories would be removed:"
    for dir in "${DIRS_TO_CLEAN[@]}"; do
        echo "  rm -rf $dir"
    done
    echo ""
    echo -e "${GREEN}✅ Dry run complete${NC}"
    exit 0
fi

# Confirm with user (unless --force)
if [[ "$FORCE" = false ]]; then
    if [[ "$INCLUDE_STATE" = true ]]; then
        echo -e "${RED}⚠️  WARNING: This will delete undo history and swap files!${NC}"
    fi
    read -p "Delete these directories? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Aborted by user${NC}"
        exit 0
    fi
fi

# Delete directories
echo ""
echo -e "${BLUE}🗑️  Deleting directories...${NC}"

for i in "${!DIRS_TO_CLEAN[@]}"; do
    dir="${DIRS_TO_CLEAN[$i]}"
    desc="${DIR_DESCRIPTIONS[$i]}"
    echo -e "  Removing $desc..."
    rm -rf "$dir"
done

echo ""
echo -e "${GREEN}✅ Cleanup complete!${NC}"
echo ""
echo -e "${BLUE}📝 Next steps:${NC}"
echo "   Run 'nvim' to automatically reinstall plugins and LSP servers"
echo "   This may take a few minutes on first launch"
echo ""
echo -e "${GREEN}✨ All done!${NC}"
