.PHONY: help menu setup dry-run status docs clean sync validate update-nvim clean-nvim backup push-changes git-log view-docs test install-deps

# Ensure bash is used for shell commands (needed for echo -e)
SHELL := /bin/bash

# Color output (use with printf or echo -e)
BOLD    := \033[1m
BLUE    := \033[34m
GREEN   := \033[32m
YELLOW  := \033[33m
RED     := \033[31m
RESET   := \033[0m

# Project variables
DOTFILES_DIR := $(shell pwd)
PLAYBOOK := setup-dotfiles.yml
DOCS_DIR := docs

# Default target - show interactive menu
.DEFAULT_GOAL := menu

# ============================================================================
# MENU & HELP
# ============================================================================

menu:
	@clear
	@echo -e "$(BOLD)$(BLUE)╔════════════════════════════════════════════════════════════╗$(RESET)"
	@echo -e "$(BOLD)$(BLUE)║           DOTFILES MANAGEMENT INTERACTIVE MENU             ║$(RESET)"
	@echo -e "$(BOLD)$(BLUE)╚════════════════════════════════════════════════════════════╝$(RESET)"
	@echo ""
	@echo -e "$(BOLD)Setup & Installation:$(RESET)"
	@echo -e "  $(GREEN)make setup$(RESET)           Run ansible-playbook to setup/install dotfiles"
	@echo -e "  $(GREEN)make dry-run$(RESET)         Test changes with --check mode before applying"
	@echo -e "  $(GREEN)make validate$(RESET)        Validate ansible playbook syntax"
	@echo -e "  $(GREEN)make install-deps$(RESET)    Install build dependencies (for scripts)"
	@echo ""
	@echo -e "$(BOLD)Status & Information:$(RESET)"
	@echo -e "  $(GREEN)make status$(RESET)          Show git status and system info"
	@echo -e "  $(GREEN)make git-log$(RESET)         Show recent git commits"
	@echo -e "  $(GREEN)make docs$(RESET)            Display documentation index"
	@echo ""
	@echo -e "$(BOLD)Maintenance:$(RESET)"
	@echo -e "  $(GREEN)make update-nvim$(RESET)     Update neovim plugins"
	@echo -e "  $(GREEN)make clean-nvim$(RESET)      Clean neovim (interactive options)"
	@echo -e "  $(GREEN)make backup$(RESET)          Create backup of current config"
	@echo -e "  $(GREEN)make clean$(RESET)           Remove old backups and cache"
	@echo -e "  $(GREEN)make sync$(RESET)            Pull latest changes from remote"
	@echo ""
	@echo -e "$(BOLD)Git & Publishing:$(RESET)"
	@echo -e "  $(GREEN)make push-changes$(RESET)    Commit and push changes to remote"
	@echo ""
	@echo -e "$(BOLD)Help:$(RESET)"
	@echo -e "  $(GREEN)make help$(RESET)            Show this menu"
	@echo -e "  $(GREEN)make view-docs$(RESET)       Open docs in less"
	@echo ""

help: menu

# ============================================================================
# SETUP & INSTALLATION
# ============================================================================

setup:
	@echo -e "$(BOLD)$(BLUE)Running ansible-playbook...$(RESET)"
	@ansible-playbook -K $(PLAYBOOK)
	@echo -e "$(GREEN)✓ Setup complete!$(RESET)"

dry-run:
	@echo -e "$(BOLD)$(BLUE)Running ansible-playbook in check mode...$(RESET)"
	@ansible-playbook --check -K $(PLAYBOOK)
	@echo -e "$(GREEN)✓ Dry run complete! No changes were applied.$(RESET)"

validate:
	@echo -e "$(BOLD)$(BLUE)Validating ansible playbook syntax...$(RESET)"
	@ansible-playbook --syntax-check $(PLAYBOOK)
	@echo -e "$(GREEN)✓ Playbook syntax is valid!$(RESET)"

install-deps:
	@echo -e "$(BOLD)$(BLUE)Checking and installing build dependencies...$(RESET)"
	@command -v git >/dev/null || (echo "Installing git..." && sudo pacman -S --noconfirm git)
	@command -v ansible >/dev/null || (echo "Installing ansible..." && sudo pacman -S --noconfirm ansible)
	@command -v make >/dev/null || (echo "Installing make..." && sudo pacman -S --noconfirm make)
	@echo -e "$(GREEN)✓ Dependencies installed!$(RESET)"

# ============================================================================
# STATUS & INFORMATION
# ============================================================================

status:
	@echo -e "$(BOLD)$(BLUE)════════════════════════════════════════════════════$(RESET)"
	@echo -e "$(BOLD)Git Status:$(RESET)"
	@echo -e "$(BOLD)════════════════════════════════════════════════════$(RESET)"
	@git status
	@echo ""
	@echo -e "$(BOLD)$(BLUE)════════════════════════════════════════════════════$(RESET)"
	@echo -e "$(BOLD)System Information:$(RESET)"
	@echo -e "$(BOLD)════════════════════════════════════════════════════$(RESET)"
	@echo "Hostname: $$(hostname)"
	@echo "OS: $$(uname -s)"
	@echo "Kernel: $$(uname -r)"
	@echo "User: $$(whoami)"
	@echo "Home: $$HOME"
	@echo ""
	@echo -e "$(BOLD)$(BLUE)════════════════════════════════════════════════════$(RESET)"
	@echo -e "$(BOLD)Repository Size:$(RESET)"
	@echo -e "$(BOLD)════════════════════════════════════════════════════$(RESET)"
	@echo "Git tracked files: $$(git ls-files -z | xargs -0 du -c 2>/dev/null | tail -1 | cut -f1)K"
	@echo "Git object database: $$(du -sh .git 2>/dev/null | cut -f1)"
	@echo "Working directory: $$(du -sh . 2>/dev/null | cut -f1)"

git-log:
	@echo -e "$(BOLD)$(BLUE)Recent commits:$(RESET)"
	@git log --oneline -10

docs:
	@echo -e "$(BOLD)$(BLUE)╔════════════════════════════════════════════════════════════╗$(RESET)"
	@echo -e "$(BOLD)$(BLUE)║           DOCUMENTATION INDEX                             ║$(RESET)"
	@echo -e "$(BOLD)$(BLUE)╚════════════════════════════════════════════════════════════╝$(RESET)"
	@echo ""
	@echo -e "$(BOLD)Quick Start:$(RESET)"
	@echo "  README.md                    - Project overview and quick start"
	@echo ""
	@echo -e "$(BOLD)System Setup:$(RESET)"
	@echo -e "  $(GREEN)docs/SETUP.md$(RESET)              - Private config and initial setup"
	@echo -e "  $(GREEN)docs/ANSIBLE.md$(RESET)            - Ansible playbook documentation"
	@echo -e "  $(GREEN)docs/TESTING.md$(RESET)            - Ansible testing and dry-run guide"
	@echo ""
	@echo -e "$(BOLD)Hyprland Configuration:$(RESET)"
	@echo -e "  $(GREEN)docs/HYPRLAND_CONFIG.md$(RESET)     - Complete Hyprland settings guide"
	@echo ""
	@echo -e "$(BOLD)Project Information:$(RESET)"
	@echo -e "  $(GREEN)docs/ARCHITECTURE.md$(RESET)        - Project architecture and design"
	@echo ""
	@echo -e "$(BOLD)Run $(GREEN)make view-docs$(RESET)$(BOLD) to browse documentation$(RESET)"

view-docs:
	@echo -e "$(BOLD)$(BLUE)Available documents:$(RESET)"
	@echo ""
	@ls -1 $(DOCS_DIR)/*.md | nl
	@echo ""
	@read -p "Enter document number (or 0 to cancel): " doc_num; \
	if [ "$$doc_num" -gt 0 ] 2>/dev/null; then \
		doc_file=$$(ls -1 $(DOCS_DIR)/*.md | sed -n "$${doc_num}p"); \
		if [ -f "$$doc_file" ]; then \
			less "$$doc_file"; \
		else \
			echo -e "$(RED)Invalid selection$(RESET)"; \
		fi; \
	fi

# ============================================================================
# MAINTENANCE
# ============================================================================

update-nvim:
	@echo -e "$(BOLD)$(BLUE)Updating neovim plugins...$(RESET)"
	@if [ -f scripts/update-nvim-plugins.sh ]; then \
		bash scripts/update-nvim-plugins.sh; \
		echo -e "$(GREEN)✓ Neovim plugins updated!$(RESET)"; \
	else \
		echo -e "$(RED)✗ Script not found: scripts/update-nvim-plugins.sh$(RESET)"; \
	fi

clean-nvim:
	@echo -e "$(BOLD)$(BLUE)Neovim Cleanup Options:$(RESET)"
	@echo ""
	@echo "  1) Dry run        - Preview what would be deleted"
	@echo "  2) Standard clean - Plugins, mason, cache (reinstallable)"
	@echo "  3) Full clean     - Also delete undo history, swap files"
	@echo "  0) Cancel"
	@echo ""
	@read -p "Select option [0-3]: " choice; \
	case $$choice in \
		1) bash scripts/clean-nvim.sh --dry-run ;; \
		2) bash scripts/clean-nvim.sh ;; \
		3) bash scripts/clean-nvim.sh --state ;; \
		0) echo -e "$(YELLOW)Cancelled.$(RESET)" ;; \
		*) echo -e "$(RED)Invalid option$(RESET)" ;; \
	esac

backup:
	@echo -e "$(BOLD)$(BLUE)Creating configuration backup...$(RESET)"
	@mkdir -p backups
	@backup_dir="backups/$$(date +%s)"; \
	mkdir -p $$backup_dir; \
	cp -r ~/.config $$backup_dir/ 2>/dev/null || true; \
	cp -r ~/.zshrc $$backup_dir/ 2>/dev/null || true; \
	echo -e "$(GREEN)✓ Backup created at: $$backup_dir$(RESET)"

clean:
	@echo -e "$(BOLD)$(BLUE)Cleaning up old backups and cache...$(RESET)"
	@find backups -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \; 2>/dev/null || true
	@find . -name "*.swp" -delete 2>/dev/null || true
	@find . -name "*.swo" -delete 2>/dev/null || true
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@echo -e "$(GREEN)✓ Cleanup complete!$(RESET)"

sync:
	@echo -e "$(BOLD)$(BLUE)Syncing with remote repository...$(RESET)"
	@git fetch origin
	@git status
	@echo ""
	@echo -e "$(YELLOW)To merge changes, run: git merge origin/main$(RESET)"

# ============================================================================
# GIT & PUBLISHING
# ============================================================================

push-changes:
	@echo -e "$(BOLD)$(BLUE)Current git status:$(RESET)"
	@git status --short
	@echo ""
	@read -p "Enter commit message (or press Enter to cancel): " msg; \
	if [ -n "$$msg" ]; then \
		git add -A; \
		git commit -m "$$msg"; \
		echo -e "$(BOLD)$(BLUE)Pushing to remote...$(RESET)"; \
		git push origin main; \
		echo -e "$(GREEN)✓ Changes pushed!$(RESET)"; \
	else \
		echo -e "$(YELLOW)Cancelled.$(RESET)"; \
	fi

# ============================================================================
# UTILITY TARGETS
# ============================================================================

.PHONY: list-tasks
list-tasks:
	@echo "Available tasks:"
	@grep "^[a-z-]*:" Makefile | sed 's/:.*//g' | sort | uniq

# Print variables for debugging
print-vars:
	@echo "DOTFILES_DIR: $(DOTFILES_DIR)"
	@echo "PLAYBOOK: $(PLAYBOOK)"
	@echo "DOCS_DIR: $(DOCS_DIR)"
	@echo "SHELL: $(SHELL)"
