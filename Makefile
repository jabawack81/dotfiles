.PHONY: help menu setup dry-run status docs clean sync validate update-nvim backup push-changes git-log view-docs test install-deps

# Color output
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
	@echo "$(BOLD)$(BLUE)╔════════════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(BOLD)$(BLUE)║           DOTFILES MANAGEMENT INTERACTIVE MENU             ║$(RESET)"
	@echo "$(BOLD)$(BLUE)╚════════════════════════════════════════════════════════════╝$(RESET)"
	@echo ""
	@echo "$(BOLD)Setup & Installation:$(RESET)"
	@echo "  $(GREEN)make setup$(RESET)           Run ansible-playbook to setup/install dotfiles"
	@echo "  $(GREEN)make dry-run$(RESET)         Test changes with --check mode before applying"
	@echo "  $(GREEN)make validate$(RESET)        Validate ansible playbook syntax"
	@echo "  $(GREEN)make install-deps$(RESET)    Install build dependencies (for scripts)"
	@echo ""
	@echo "$(BOLD)Status & Information:$(RESET)"
	@echo "  $(GREEN)make status$(RESET)          Show git status and system info"
	@echo "  $(GREEN)make git-log$(RESET)         Show recent git commits"
	@echo "  $(GREEN)make docs$(RESET)            Display documentation index"
	@echo ""
	@echo "$(BOLD)Maintenance:$(RESET)"
	@echo "  $(GREEN)make update-nvim$(RESET)     Update neovim plugins"
	@echo "  $(GREEN)make backup$(RESET)          Create backup of current config"
	@echo "  $(GREEN)make clean$(RESET)           Remove old backups and cache"
	@echo "  $(GREEN)make sync$(RESET)            Pull latest changes from remote"
	@echo ""
	@echo "$(BOLD)Git & Publishing:$(RESET)"
	@echo "  $(GREEN)make push-changes$(RESET)    Commit and push changes to remote"
	@echo ""
	@echo "$(BOLD)Help:$(RESET)"
	@echo "  $(GREEN)make help$(RESET)            Show this menu"
	@echo "  $(GREEN)make view-docs$(RESET)       Open docs in less"
	@echo ""

help: menu

# ============================================================================
# SETUP & INSTALLATION
# ============================================================================

setup:
	@echo "$(BOLD)$(BLUE)Running ansible-playbook...$(RESET)"
	@ansible-playbook $(PLAYBOOK)
	@echo "$(GREEN)✓ Setup complete!$(RESET)"

dry-run:
	@echo "$(BOLD)$(BLUE)Running ansible-playbook in check mode...$(RESET)"
	@ansible-playbook --check $(PLAYBOOK)
	@echo "$(GREEN)✓ Dry run complete! No changes were applied.$(RESET)"

validate:
	@echo "$(BOLD)$(BLUE)Validating ansible playbook syntax...$(RESET)"
	@ansible-playbook --syntax-check $(PLAYBOOK)
	@echo "$(GREEN)✓ Playbook syntax is valid!$(RESET)"

install-deps:
	@echo "$(BOLD)$(BLUE)Checking and installing build dependencies...$(RESET)"
	@command -v git >/dev/null || (echo "Installing git..." && sudo pacman -S --noconfirm git)
	@command -v ansible >/dev/null || (echo "Installing ansible..." && sudo pacman -S --noconfirm ansible)
	@command -v make >/dev/null || (echo "Installing make..." && sudo pacman -S --noconfirm make)
	@echo "$(GREEN)✓ Dependencies installed!$(RESET)"

# ============================================================================
# STATUS & INFORMATION
# ============================================================================

status:
	@echo "$(BOLD)$(BLUE)════════════════════════════════════════════════════$(RESET)"
	@echo "$(BOLD)Git Status:$(RESET)"
	@echo "$(BOLD)════════════════════════════════════════════════════$(RESET)"
	@git status
	@echo ""
	@echo "$(BOLD)$(BLUE)════════════════════════════════════════════════════$(RESET)"
	@echo "$(BOLD)System Information:$(RESET)"
	@echo "$(BOLD)════════════════════════════════════════════════════$(RESET)"
	@echo "Hostname: $$(hostname)"
	@echo "OS: $$(uname -s)"
	@echo "Kernel: $$(uname -r)"
	@echo "User: $$(whoami)"
	@echo "Home: $$HOME"
	@echo ""
	@echo "$(BOLD)$(BLUE)════════════════════════════════════════════════════$(RESET)"
	@echo "$(BOLD)Repository Size:$(RESET)"
	@echo "$(BOLD)════════════════════════════════════════════════════$(RESET)"
	@echo "Git tracked files: $$(git ls-files -z | xargs -0 du -c 2>/dev/null | tail -1 | cut -f1)K"
	@echo "Git object database: $$(du -sh .git 2>/dev/null | cut -f1)"
	@echo "Working directory: $$(du -sh . 2>/dev/null | cut -f1)"

git-log:
	@echo "$(BOLD)$(BLUE)Recent commits:$(RESET)"
	@git log --oneline -10

docs:
	@echo "$(BOLD)$(BLUE)╔════════════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(BOLD)$(BLUE)║           DOCUMENTATION INDEX                             ║$(RESET)"
	@echo "$(BOLD)$(BLUE)╚════════════════════════════════════════════════════════════╝$(RESET)"
	@echo ""
	@echo "$(BOLD)Quick Start:$(RESET)"
	@echo "  README.md                    - Project overview and quick start"
	@echo ""
	@echo "$(BOLD)System Setup:$(RESET)"
	@echo "  $(GREEN)docs/SETUP.md$(RESET)              - Private config and initial setup"
	@echo "  $(GREEN)docs/ANSIBLE.md$(RESET)            - Ansible playbook documentation"
	@echo "  $(GREEN)docs/TESTING.md$(RESET)            - Ansible testing and dry-run guide"
	@echo ""
	@echo "$(BOLD)Hyprland Configuration:$(RESET)"
	@echo "  $(GREEN)docs/HYPRLAND_CONFIG.md$(RESET)     - Complete Hyprland settings guide"
	@echo "  $(GREEN)docs/HYPRLAND_MIGRATION.md$(RESET)  - Migration from Hyprland v2 to v3"
	@echo ""
	@echo "$(BOLD)Project Information:$(RESET)"
	@echo "  $(GREEN)docs/ARCHITECTURE.md$(RESET)        - Project architecture and design"
	@echo "  $(GREEN)docs/REFACTORING.md$(RESET)         - Repository refactoring plan"
	@echo ""
	@echo "$(BOLD)Run $(GREEN)make view-docs$(RESET)$(BOLD) to browse documentation$(RESET)"

view-docs:
	@echo "$(BOLD)$(BLUE)Available documents:$(RESET)"
	@echo ""
	@ls -1 $(DOCS_DIR)/*.md | nl
	@echo ""
	@read -p "Enter document number (or 0 to cancel): " doc_num; \
	if [ "$$doc_num" -gt 0 ] 2>/dev/null; then \
		doc_file=$$(ls -1 $(DOCS_DIR)/*.md | sed -n "$${doc_num}p"); \
		if [ -f "$$doc_file" ]; then \
			less "$$doc_file"; \
		else \
			echo "$(RED)Invalid selection$(RESET)"; \
		fi; \
	fi

# ============================================================================
# MAINTENANCE
# ============================================================================

update-nvim:
	@echo "$(BOLD)$(BLUE)Updating neovim plugins...$(RESET)"
	@if [ -f scripts/update-nvim-plugins.sh ]; then \
		bash scripts/update-nvim-plugins.sh; \
		echo "$(GREEN)✓ Neovim plugins updated!$(RESET)"; \
	else \
		echo "$(RED)✗ Script not found: scripts/update-nvim-plugins.sh$(RESET)"; \
	fi

backup:
	@echo "$(BOLD)$(BLUE)Creating configuration backup...$(RESET)"
	@mkdir -p backups
	@backup_dir="backups/$$(date +%s)"; \
	mkdir -p $$backup_dir; \
	cp -r ~/.config $$backup_dir/ 2>/dev/null || true; \
	cp -r ~/.zshrc $$backup_dir/ 2>/dev/null || true; \
	echo "$(GREEN)✓ Backup created at: $$backup_dir$(RESET)"

clean:
	@echo "$(BOLD)$(BLUE)Cleaning up old backups and cache...$(RESET)"
	@find backups -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \; 2>/dev/null || true
	@find . -name "*.swp" -delete 2>/dev/null || true
	@find . -name "*.swo" -delete 2>/dev/null || true
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete!$(RESET)"

sync:
	@echo "$(BOLD)$(BLUE)Syncing with remote repository...$(RESET)"
	@git fetch origin
	@git status
	@echo ""
	@echo "$(YELLOW)To merge changes, run: git merge origin/main$(RESET)"

# ============================================================================
# GIT & PUBLISHING
# ============================================================================

push-changes:
	@echo "$(BOLD)$(BLUE)Current git status:$(RESET)"
	@git status --short
	@echo ""
	@read -p "$(BOLD)Enter commit message (or press Enter to cancel): $(RESET)" msg; \
	if [ -n "$$msg" ]; then \
		git add -A; \
		git commit -m "$$msg"; \
		echo "$(BOLD)$(BLUE)Pushing to remote...$(RESET)"; \
		git push origin main; \
		echo "$(GREEN)✓ Changes pushed!$(RESET)"; \
	else \
		echo "$(YELLOW)Cancelled.$(RESET)"; \
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
