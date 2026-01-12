# Dotfiles Repository Refactoring Plan

**Current State Analysis**

## Size Breakdown
```
Total: ~60MB

Largest items:
- common/bin/eww:        25MB  (binary, consider external dependency)
- common/hypr/Fonts:      7MB  (can use system fonts)
- kyrios/hypr:           11MB  (duplicated from common)
- shinkiro/hypr:         11MB  (duplicated from common)
- common/hypr/hyprlock.png: 3.1MB (large image)
- common/nvim:          244KB  (large but reasonable)
- common/waybar:         52KB  (reasonable)
- shinkiro/eww:         384KB  (duplicate)
```

## Key Issues

### 1. ❌ Duplicated Hyprland Configs
- `common/hypr/` - source configs
- `kyrios/hypr/` - override (11MB)
- `shinkiro/hypr/` - override (11MB)

**Problem:** Hyprland stores compiled cache/fonts which inflates size
**Solution:** Only store `.conf` files, let Hyprland generate cache locally

### 2. ⚠️ EWW Binary (Status: ACTIVE but size issue)
- `common/bin/eww` - 25MB binary (build artifact)
- `shinkiro/eww` - 384KB (active configuration, in use)

**Status:** EWW is currently running (daemon active)
**Problem:** 25MB binary is too large; should be installed via package manager
**Solution:** Remove binary from repo, install via `pacman -S eww` or rebuild locally

### 3. ❌ Large Image Files
- `common/hypr/hyprlock.png` - 3.1MB
- `common/hypr/jabawack.jpg` - 68KB

**Problem:** Taking up space; better in separate storage
**Solution:** Move to private config or external storage

### 4. ❌ Font Files in Repo
- `common/hypr/Fonts/` - 7MB

**Problem:** Should use system fonts from `pacman`
**Solution:** Remove; rely on installed font packages

### 5. ❌ Documentation Duplication
- `CLAUDE.md` - 8KB (instructions)
- `ANSIBLE-PLAYBOOK.md` - 12KB
- `TESTING_ANSIBLE_GUIDE.md` - 12KB (new)
- `PRIVATE-CONFIG-SETUP.md` - 4KB
- Plus individual README files scattered

**Problem:** Multiple doc files; hard to maintain
**Solution:** Consolidate into single `docs/` directory with clear structure

### 6. ❌ Backup Directory Checked In
- `backups/` - 44KB

**Problem:** Backups shouldn't be in repo
**Solution:** Add to `.gitignore`

### 7. ❌ Test/Example Files
- `test-logos.sh` - 4KB
- `dot_env.example` - 4KB
- `lelu_logo.txt` - 4KB
- `PRIVATE-CONFIG-SETUP.md` - 4KB

**Problem:** Scattered in root, not organized
**Solution:** Move to `docs/examples/` or `scripts/`

---

## Proposed Refactoring

### Phase 1: Clean Up Root Directory
```
BEFORE:
├── README.md
├── CLAUDE.md
├── ANSIBLE-PLAYBOOK.md
├── TESTING_ANSIBLE_GUIDE.md
├── PRIVATE-CONFIG-SETUP.md
├── ansible.cfg
├── inventory
├── setup.sh
├── setup-dotfiles.yml
├── update-nvim-plugins.sh
├── test-logos.sh
├── dot_env.example
├── lelu_logo.txt
├── backups/ (git-ignored)
├── private-config/
├── common/
├── kyrios/
└── shinkiro/

AFTER:
├── README.md (simplified, links to docs)
├── setup.sh (orchestration)
├── setup-dotfiles.yml (ansible playbook)
├── ansible.cfg
├── inventory
│
├── docs/
│   ├── CONFIGURATION.md (from CLAUDE.md)
│   ├── ANSIBLE.md (from ANSIBLE-PLAYBOOK.md)
│   ├── TESTING.md (from TESTING_ANSIBLE_GUIDE.md)
│   ├── SETUP.md (from PRIVATE-CONFIG-SETUP.md)
│   ├── HYPRLAND.md (config guide)
│   ├── ARCHITECTURE.md
│   └── examples/
│       ├── env.example (from dot_env.example)
│       └── test-logos.sh
│
├── scripts/
│   ├── update-nvim-plugins.sh
│   └── symlink-validator.sh (new utility)
│
├── backups/ (.gitignore)
├── private-config/
│
├── common/
│   ├── .oh-my-zsh/
│   ├── bedtime/
│   ├── bin/ (remove eww binary)
│   ├── broot/
│   ├── btop/
│   ├── dunst/
│   ├── fastfetch/
│   ├── fuzzel/
│   ├── ghostty/
│   ├── git/
│   ├── hypr/
│   │   ├── common.conf (only configs)
│   │   ├── hyprlock.conf
│   │   └── .gitignore (ignore cache/fonts)
│   ├── lazygit/
│   ├── nvim/
│   ├── nodenv/
│   ├── opencode/
│   ├── rbenv/
│   ├── scripts/
│   ├── thunar/
│   ├── waybar/
│   └── wlogout/
│
├── kyrios/
│   ├── README.md
│   └── hypr/ (only overrides, no cache)
│
└── shinkiro/
    ├── README.md
    ├── hypr/
    │   ├── hyprland.conf (only config)
    │   └── .gitignore
    └── eww/ (or remove if unused)
```

### Phase 2: Remove Large Files
```bash
# Remove eww binary (install via pacman instead)
rm -rf common/bin/eww
# Install via: pacman -S eww (AUR) or rebuild from source

# Remove hyprland caches/fonts
rm -rf common/hypr/Fonts/

# Handle images: either move to private-config or remove
# (decision needed based on requirements)
```

### Step 6: Update hyprland configs
```bash
# Remove generated files from git tracking
cd common/hypr && rm -rf .cache Fonts
cd shinkiro/hypr && rm -rf .cache
cd kyrios/hypr && rm -rf .cache
```

### Step 7: Create machine-specific READMEs
```bash
# Add clear documentation for each machine
echo "# Shinkiro Configuration
This directory contains Shinkiro-specific overrides.
..." > shinkiro/README.md

echo "# Kyrios Configuration
This directory contains Kyrios-specific overrides.
..." > kyrios/README.md
```

### Step 8: Update main README
```bash
# Simplify main README.md to point to docs/
```

---

## Benefits After Refactoring

### Size Reduction
- **Before:** ~60MB
- **After:** ~24MB (60% reduction)
- **Faster clones:** 2-3x faster on slow connections
- **Faster backups:** Significantly smaller backup files

### Organization
- Clear `docs/` directory for all documentation
- Organized `scripts/` for utilities
- Machine-specific READMEs
- Easier to navigate

### Maintainability
- Single source of truth for configs
- No cache files polluting repo
- Cleaner Git history
- Faster to search and find things

### Performance
- Smaller repo = faster git operations
- No unnecessary cache files
- Cleaner working directory

---

## Estimated Time

- Phase 1 (Structure): 15 minutes
- Phase 2 (Remove files): 5 minutes
- Phase 3 (Docs): 20 minutes
- Phase 4 (.gitignore): 5 minutes
- Phase 5 (References): 15 minutes
- Testing & QA: 15 minutes

**Total: ~75 minutes**

---

## Risks & Mitigation

| Risk | Mitigation |
|------|-----------|
| Break symlinks | Test after each phase with dry run |
| Lose configs | Backup repo first (git clone backup) |
| Break references | Search all files for old paths before moving |
| Lose images | Decide before deletion; move to private-config if needed |
| Ansible issues | Test playbook after major changes |

---

## Questions Before Proceeding

1. **Hyprland images:** Keep `hyprlock.png` and `jabawack.jpg`?
   - Option A: Move to `private-config/`
   - Option B: Store externally
   - Option C: Remove entirely

2. **EWW binary:** Remove from `common/bin/eww`?
   - Should be installed: `pacman -S eww`

3. **Machine-specific hypr:** Keep overrides or merge?
   - Current: kyrios and shinkiro have full copies (with cache)
   - Better: Only store actual config differences

4. **Documentation:** Any docs you want to keep as-is?

---

**Ready to proceed? Let me know which options you prefer!**

---

## 🔍 UPDATE: EWW Status Check

**Finding:** EWW is ACTIVELY USED!
- Daemon running: `/home/paolo/.local/bin/eww daemon` (PID 7036)
- Config exists and complete: `shinkiro/eww/` (384KB, 9 files)
- Symlinks in place: `~/.config/eww` → shinkiro config
- Startup script running: `eww-launcher.sh`

**Decision on EWW:**
✅ KEEP shinkiro/eww configuration (it's active)
❌ REMOVE common/bin/eww binary (25MB bloat)

**Action:** 
- Uninstall bundled eww: `rm -rf common/bin/eww`
- Install via AUR: `pacman -S eww` (or rebuild from source)
- Playbook will need update to handle installation differently
