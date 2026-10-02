.PHONY: help menu setup dry-run status docs clean sync validate update-nvim clean-nvim backup push-changes git-log view-docs test install-deps caelestia-update caelestia-build caelestia-verify greeter-deploy greeter-logs greeter-status

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
LOG_DIR := logs

# Run the playbook with output on the terminal AND in a timestamped log.
# Colour is forced so the terminal looks normal through the pipe; the copy
# written to the log has the escape codes stripped. pipefail keeps ansible's
# exit status so a failed run still fails make.
#   $(1) = log name prefix, $(2) = extra ansible-playbook args
# The become password is read once here and checked with `sudo -v` before
# anything runs, so a typo fails in a second instead of minutes into the play.
# It then reaches ansible through a 0600 temp file (removed on exit) rather
# than -K, which would prompt a second time, or -e, which would show in ps.
define run_playbook
	@mkdir -p $(LOG_DIR)
	@log="$(LOG_DIR)/$(1)-$$(date +%Y%m%d-%H%M%S).log"; \
	read -rs -p "BECOME password: " pw; echo; \
	if ! printf '%s\n' "$$pw" | sudo -S -k -v 2>/dev/null; then \
	  echo -e "$(RED)✗ sudo rejected that password, nothing was run$(RESET)"; exit 1; \
	fi; \
	pwfile="$$(mktemp -p "$${XDG_RUNTIME_DIR:-/tmp}" become.XXXXXX)"; \
	chmod 600 "$$pwfile"; printf '%s' "$$pw" > "$$pwfile"; unset pw; \
	trap 'rm -f "$$pwfile"' EXIT; \
	echo -e "$(BOLD)Log: $$log$(RESET)"; \
	set -o pipefail; \
	ANSIBLE_FORCE_COLOR=1 ansible-playbook --become-password-file "$$pwfile" $(2) $(PLAYBOOK) 2>&1 \
	  | tee >(sed -u 's/\x1b\[[0-9;]*[A-Za-z]//g' > "$$log"); \
	status=$$?; \
	echo -e "$(BOLD)Log saved to $$log$(RESET)"; \
	exit $$status
endef

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
	@echo -e "  $(GREEN)make setup$(RESET)           Run ansible-playbook to setup/install dotfiles (logs to logs/)"
	@echo -e "  $(GREEN)make dry-run$(RESET)         Test changes with --check mode before applying (logs to logs/)"
	@echo -e "  $(GREEN)make validate$(RESET)        Validate ansible playbook syntax"
	@echo -e "  $(GREEN)make install-deps$(RESET)    Install build dependencies (for scripts)"
	@echo ""
	@echo -e "$(BOLD)Status & Information:$(RESET)"
	@echo -e "  $(GREEN)make status$(RESET)          Show git status and system info"
	@echo -e "  $(GREEN)make git-log$(RESET)         Show recent git commits"
	@echo -e "  $(GREEN)make docs$(RESET)            Display documentation index"
	@echo ""
	@echo -e "$(BOLD)Security:$(RESET)"
	@echo -e "  $(GREEN)make aur-check$(RESET)       Scan for AUR supply-chain compromise indicators"
	@echo ""
	@echo -e "$(BOLD)Caelestia shell (vendored):$(RESET)"
	@echo -e "  $(GREEN)make caelestia-build$(RESET) Build the QML plugin from the vendored source"
	@echo -e "  $(GREEN)make caelestia-update$(RESET) Re-sync with upstream (TAG=v2.6.0)"
	@echo -e "  $(GREEN)make caelestia-verify$(RESET) Check our changes are additions only"
	@echo ""
	@echo -e "$(BOLD)Greeter (greetd):$(RESET)"
	@echo -e "  $(GREEN)make greeter-deploy$(RESET)  Install to /etc/greetd, verify, restart greetd"
	@echo -e "  $(GREEN)make greeter-logs$(RESET)    Why the last login attempt failed"
	@echo -e "  $(GREEN)make greeter-status$(RESET)  What is deployed, and is it current"
	@echo ""
	@echo -e "$(BOLD)Maintenance:$(RESET)"
	@echo -e "  $(GREEN)make update-nvim$(RESET)     Update neovim plugins"
	@echo -e "  $(GREEN)make clean-nvim$(RESET)      Clean neovim (interactive options)"
	@echo -e "  $(GREEN)make backup$(RESET)          Create backup of current config"
	@echo -e "  $(GREEN)make clean$(RESET)           Remove backups and logs older than 30 days, and cache"
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
	$(call run_playbook,setup,)
	@echo -e "$(GREEN)✓ Setup complete!$(RESET)"

dry-run:
	@echo -e "$(BOLD)$(BLUE)Running ansible-playbook in check mode...$(RESET)"
	$(call run_playbook,dry-run,--check)
	@echo -e "$(GREEN)✓ Dry run complete! No changes were applied.$(RESET)"

validate:
	@echo -e "$(BOLD)$(BLUE)Validating ansible playbook syntax...$(RESET)"
	@ansible-playbook --syntax-check $(PLAYBOOK)
	@echo -e "$(GREEN)✓ Playbook syntax is valid!$(RESET)"

# Arch uses pacman; Debian servers use apt. Anything else is on its own.
ifneq ($(wildcard /etc/debian_version),)
PKG_INSTALL := sudo apt-get install -y
else
PKG_INSTALL := sudo pacman -S --noconfirm
endif

install-deps:
	@echo -e "$(BOLD)$(BLUE)Checking and installing build dependencies...$(RESET)"
	@if [ -f /etc/debian_version ]; then sudo apt-get update -qq; fi
	@command -v git >/dev/null || (echo "Installing git..." && $(PKG_INSTALL) git)
	@command -v ansible >/dev/null || (echo "Installing ansible..." && $(PKG_INSTALL) ansible)
	@command -v make >/dev/null || (echo "Installing make..." && $(PKG_INSTALL) make)
	@echo -e "$(GREEN)✓ Dependencies installed!$(RESET)"

# ============================================================================
# STATUS & INFORMATION
# ============================================================================

# ============================================================================
# VENDORED CAELESTIA SHELL
# ============================================================================

CAELESTIA_DIR := common/caelestia-shell
CAELESTIA_URL := https://github.com/caelestia-dots/shell

# Re-sync the vendored shell against an upstream tag, keeping our own files.
# Local additions live in files matching *Custom* (plus CHANGES-LOCAL.md), so
# they survive the rsync and show up in the summary at the end.
#   make caelestia-update TAG=v2.6.0
caelestia-update:
	@test -n "$(TAG)" || { echo -e "$(RED)Set TAG, e.g. make caelestia-update TAG=v2.6.0$(RESET)"; exit 1; }
	@echo -e "$(BOLD)$(BLUE)Fetching $(TAG) from upstream...$(RESET)"
	@tmp=$$(mktemp -d); 	git clone -q --depth 1 --branch "$(TAG)" $(CAELESTIA_URL) "$$tmp/src" || { rm -rf "$$tmp"; exit 1; }; 	echo -e "$(BOLD)Syncing (local *Custom* files and UPSTREAM are preserved)...$(RESET)"; 	rsync -a --delete 	  --exclude '.git' --exclude 'build/' --exclude 'UPSTREAM' 	  --exclude '*Custom*' --exclude 'CHANGES-LOCAL.md' 	  "$$tmp/src/" "$(CAELESTIA_DIR)/"; 	rev=$$(git -C "$$tmp/src" rev-parse HEAD); 	printf 'Vendored copy of caelestia-dots/shell.\n\n    upstream  %s\n    version   %s\n    commit    %s\n    imported  %s\n\nLicensed GPL-3.0 by its authors; see LICENSE in this directory. Local\nchanges live in files named *Custom* or listed in CHANGES-LOCAL.md so that\n`make caelestia-update` can show them against a fresh upstream checkout.\n\nUpdate with: make caelestia-update  (see the Makefile)\n' 	  "$(CAELESTIA_URL)" "$(TAG)" "$$rev" "$$(date -I)" > $(CAELESTIA_DIR)/UPSTREAM; 	rm -rf "$$tmp"
	@echo ""
	@echo -e "$(BOLD)$(YELLOW)Review before committing:$(RESET)"
	@git status --short $(CAELESTIA_DIR) | head -30
	@echo ""
	@echo -e "$(BOLD)Our local files (re-check they still fit upstream):$(RESET)"
	@find $(CAELESTIA_DIR) -name '*Custom*' | sed 's/^/  /'
	@echo -e "$(YELLOW)Then rebuild: make caelestia-build$(RESET)"

# Build the QML plugin from the vendored source. Everything it needs is in
# the official repos except libcava; nothing is installed system-wide, the
# launcher points QML_IMPORT_PATH at the build output.
# VERSION/GIT_REVISION are passed explicitly: upstream derives them with
# `git describe` against its own repo, which finds nothing here. They come
# from the UPSTREAM file written at import time.
caelestia-build:
	@echo -e "$(BOLD)$(BLUE)Building the caelestia plugin...$(RESET)"
	@ver=$$(awk '/^ *version/ {print $$2}' $(CAELESTIA_DIR)/UPSTREAM); 	rev=$$(awk '/^ *commit/ {print $$2}' $(CAELESTIA_DIR)/UPSTREAM); 	cmake -S $(CAELESTIA_DIR) -B $(CAELESTIA_DIR)/build -G Ninja 	  -DCMAKE_BUILD_TYPE=Release 	  -DVERSION="$$ver" -DGIT_REVISION="$$rev" 	  -DDISTRIBUTOR="jabawack81/dotfiles (vendored)" >/dev/null
	@cmake --build $(CAELESTIA_DIR)/build
	@echo -e "$(GREEN)✓ Built into $(CAELESTIA_DIR)/build/qml$(RESET)"

# Check the vendored tree against the upstream tag it claims to be. Our
# changes to upstream files must be additions only — a deletion means an
# edit clobbered something, which stays invisible until the shell silently
# drops a component at runtime.
caelestia-verify:
	@$(DOTFILES_DIR)/scripts/caelestia-verify.rb

greeter-deploy:
	@$(DOTFILES_DIR)/scripts/greeter.sh deploy

greeter-logs:
	@$(DOTFILES_DIR)/scripts/greeter.sh logs

greeter-status:
	@$(DOTFILES_DIR)/scripts/greeter.sh status

aur-check:
	@echo -e "$(BOLD)$(BLUE)Scanning for AUR supply-chain indicators...$(RESET)"
	@$(DOTFILES_DIR)/common/scripts/aur-ioc-check.sh $(if $(LIST),--list $(LIST),)

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
	@echo -e "$(BOLD)Security:$(RESET)"
	@echo -e "  $(GREEN)docs/AUR_SUPPLY_CHAIN.md$(RESET)    - AUR compromise checks (make aur-check)"
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
	@echo -e "$(BOLD)$(BLUE)Cleaning up old backups, logs and cache...$(RESET)"
	@find backups -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \; 2>/dev/null || true
	@find $(LOG_DIR) -maxdepth 1 -name "*.log" -mtime +30 -delete 2>/dev/null || true
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
