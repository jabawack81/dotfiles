# Testing Ansible Playbook - Dry Run Guide

**System:** Shinkiro (Desktop PC)  
**Ansible Version:** 2.20+  
**Playbook:** `setup-dotfiles.yml`

This guide explains how to safely test the Ansible playbook without making any changes to your system.

---

## Quick Start

**Run a complete dry run with diff output:**

```bash
cd ~/dotfiles
ansible-playbook setup-dotfiles.yml --check --diff -v
```

This will show:
- ✅ All changes that would be made
- ✅ File differences
- ✅ All tasks executed
- ✅ Make ZERO actual changes

---

## Dry Run Methods

### 1. Basic Check Mode

```bash
ansible-playbook setup-dotfiles.yml --check
```

**Output:** Shows which tasks would run and their status  
**Verbosity:** Low - only summary  
**Use:** Quick overview of what would happen  

**Example Output:**
```
TASK [Ensure required packages are installed] **
changed: [localhost]
```

---

### 2. Check Mode + Verbose

```bash
ansible-playbook setup-dotfiles.yml --check -v
```

**Output:** Detailed info about each task  
**Verbosity:** Medium  
**Use:** See what each task does and status  

**Example Output:**
```
TASK [Ensure required packages are installed] **
changed: [localhost] => {
    "changed": true,
    "msg": "sudo pacman -S zsh git neovim lazygit..."
}
```

---

### 3. Check Mode + Extra Verbose

```bash
ansible-playbook setup-dotfiles.yml --check -vv
```

**Output:** Much more detail about variables, conditions  
**Verbosity:** High  
**Use:** Debug complex logic or variable substitution  

---

### 4. Check Mode + Debug Level

```bash
ansible-playbook setup-dotfiles.yml --check -vvv
```

**Output:** Extremely detailed (full Python object dumps)  
**Verbosity:** Maximum  
**Use:** Deep debugging of Ansible internals  

---

### 5. Diff Output (Most Useful)

```bash
ansible-playbook setup-dotfiles.yml --check --diff
```

**Output:** Shows actual file changes (like `git diff`)  
**Use:** See exact changes before applying  

**Example Output:**
```
--- before: /home/paolo/.config/nvim/init.lua
+++ after: /home/paolo/.config/nvim/init.lua
@@ -1,5 +1,8 @@
 {
   "lua_dev": {
-    "enabled": true
+    "enabled": true,
+    "new_option": "value",
+    "debug": false
   }
 }
```

---

### 6. Diff + Verbose (Recommended)

```bash
ansible-playbook setup-dotfiles.yml --check --diff -v
```

**Combines:**
- Diff output (file changes)
- Verbose output (task details)
- Check mode (no actual changes)

**Best for:** Understanding exactly what will happen before executing

---

### 7. List Tasks Only

```bash
ansible-playbook setup-dotfiles.yml --list-tasks
```

**Output:** All tasks without executing them  
**Use:** See what the playbook will do (quick overview)  

**Example Output:**
```
playbook: setup-dotfiles.yml

  play #1 (localhost): Setup dotfiles based on hostname   TAGS: []
    tasks:
      1. Gathering Facts                                TAGS: []
      2. Check if private config exists                 TAGS: []
      3. Load private configuration                     TAGS: []
      4. Set private config loaded flag                 TAGS: []
      5. Display execution context                      TAGS: []
      ...
```

---

### 8. List Hosts Only

```bash
ansible-playbook setup-dotfiles.yml --list-hosts
```

**Output:** Shows which hosts would be targeted  
**Use:** Verify the playbook targets the right systems  

**Example Output:**
```
  hosts (1):
    localhost
```

---

## Advanced Testing

### Test with Specific Variables

If your playbook needs variables (hostname, user, etc.):

```bash
# Override hostname
ansible-playbook setup-dotfiles.yml --check --diff -v -e "hostname=shinkiro"

# Set multiple variables
ansible-playbook setup-dotfiles.yml --check --diff -v \
  -e "hostname=shinkiro" \
  -e "target_user=paolo"
```

---

### Test Specific Tags Only

If your playbook has tags:

```bash
# Run only tasks with 'symlinks' tag
ansible-playbook setup-dotfiles.yml --check --diff -v --tags symlinks

# Skip certain tags
ansible-playbook setup-dotfiles.yml --check --diff -v --skip-tags packages
```

---

### Test with Increased Forks

For faster execution with multiple systems:

```bash
# Use 10 parallel processes (default is 5)
ansible-playbook setup-dotfiles.yml --check --diff -v -f 10
```

---

## Understanding Dry Run Output

### Status Indicators

- **`ok`** - Task executed, no changes needed
- **`changed`** - Task would make changes
- **`skipped`** - Task was skipped (condition not met)
- **`failed`** - Task would fail (potential error)

### Example Full Output

```
TASK [Create symlink for nvim config] *****
--- before
+++ after
@@ -1,4 +1,4 @@
 {
   "src": "/home/paolo/dotfiles/common/nvim",
-  "state": "absent"
+  "state": "link"
 }

changed: [localhost] => {
    "changed": true,
    "dest": "/home/paolo/.config/nvim",
    "src": "/home/paolo/dotfiles/common/nvim"
}
```

**Interpretation:**
- Symlink does NOT currently exist (`state: absent`)
- Playbook WOULD create it (`state: link`)
- Destination: `~/.config/nvim`
- Source: `~/dotfiles/common/nvim`

---

## Your Playbook Structure

Your `setup-dotfiles.yml` is organized as:

```
Setup dotfiles based on hostname
├── Detect system (hostname)
├── Load private configuration
├── Create backup directory
├── For Personal Machines (kyrios/shinkiro):
│   ├── Install required packages
│   ├── Create symlinks for configs
│   ├── Configure GUI tools (waybar, hyprland, etc.)
│   ├── Setup version managers (rbenv, nodenv, etc.)
│   └── Miscellaneous setup
└── For Work Machines:
    ├── Install minimal packages
    ├── Setup terminal tools only
    └── Skip GUI configs
```

---

## Testing Strategy

### 1. First Time Testing (Recommended)

```bash
# See all tasks that will run
ansible-playbook setup-dotfiles.yml --list-tasks

# See complete dry run with diffs
ansible-playbook setup-dotfiles.yml --check --diff -v 2>&1 | tee dry-run.log

# Review the log
cat dry-run.log | less
```

---

### 2. Check Specific Sections

```bash
# If your playbook has tags, test each section
ansible-playbook setup-dotfiles.yml --check --diff -v --tags packages
ansible-playbook setup-dotfiles.yml --check --diff -v --tags symlinks
ansible-playbook setup-dotfiles.yml --check --diff -v --tags shell
```

---

### 3. Before Actual Execution

```bash
# Final verification
ansible-playbook setup-dotfiles.yml --check --diff

# If satisfied, run for real
ansible-playbook setup-dotfiles.yml
```

---

## Common Issues in Dry Run

### ⚠️ Check Mode Limitations

Some Ansible modules have limitations in check mode:

1. **Commands/Shell modules** - Don't actually execute
   - Won't know if the command would succeed
   - May show "would have run if not in check mode"

2. **File creation** - Difficult to predict exact permissions
   - Assume default permissions will apply

3. **Package installation** - May not catch all dependencies
   - Actual run might install additional packages

### Solution

Always review the actual run on a test system if possible, or be careful with destructive operations.

---

## Real Execution (After Dry Run)

Once you're confident from the dry run:

```bash
# Run the actual playbook (no --check flag)
ansible-playbook setup-dotfiles.yml

# With verbose output to see progress
ansible-playbook setup-dotfiles.yml -v

# If something goes wrong, backups are in ./backups/
ls -la backups/
```

---

## Backup Strategy

Your playbook automatically creates backups:

```
backups/
├── 1768255927/     # Timestamp-based backup directory
│   ├── .config/
│   │   ├── nvim/
│   │   ├── waybar/
│   │   └── ...
│   └── other_files/
└── 1768255928/     # Another backup from another run
    └── ...
```

**To restore from backup:**

```bash
# If something goes wrong
cp -r backups/1768255927/* ~/

# Or restore specific config
cp -r backups/1768255927/.config/nvim ~/.config/
```

---

## Dry Run Checklist

Before running the actual playbook:

- [ ] Run `ansible-playbook setup-dotfiles.yml --list-tasks`
- [ ] Run `ansible-playbook setup-dotfiles.yml --check --diff -v`
- [ ] Review all changes that would be made
- [ ] Check file diffs for any unexpected modifications
- [ ] Verify correct hostname detected
- [ ] Ensure private config is loaded (if needed)
- [ ] Look for any `failed` status indicators
- [ ] Check that all critical tasks show `changed: true`

---

## Troubleshooting Dry Runs

### Issue: Tasks Show as "Skipped"

**Cause:** Conditional logic excluded them  
**Check:** Look for `skipping:` message - shows the false condition

```
skipping: [localhost] => {"false_condition": "is_personal_machine"}
```

**Solution:** Verify your variables match expected values

---

### Issue: "Command would have run if not in check mode"

**Cause:** Shell/command module can't predict output  
**What to do:** Trust it will work, or test the command manually first

```bash
# Test the command manually
/path/to/the/command --arg value
```

---

### Issue: File Diffs Show Unexpected Changes

**Cause:** Template variables different than expected  
**Check:** Review variable values in output

```bash
# See all variables used
ansible-playbook setup-dotfiles.yml --check -v | grep "changed:"
```

---

## Tips & Best Practices

1. **Save output to file for review:**
   ```bash
   ansible-playbook setup-dotfiles.yml --check --diff -v > dry-run.txt 2>&1
   cat dry-run.txt | less
   ```

2. **Count changes that would be made:**
   ```bash
   ansible-playbook setup-dotfiles.yml --check -v 2>&1 | grep -c "changed:"
   ```

3. **Look for errors before they happen:**
   ```bash
   ansible-playbook setup-dotfiles.yml --check -v 2>&1 | grep -i error
   ```

4. **Keep dry run logs for reference:**
   ```bash
   mkdir -p dry-run-logs
   ansible-playbook setup-dotfiles.yml --check --diff -v > dry-run-logs/run-$(date +%s).log
   ```

5. **Use tags to test sections safely:**
   ```bash
   # Test only symlink creation
   ansible-playbook setup-dotfiles.yml --check --diff -v --tags symlinks
   
   # Then test only package installation
   ansible-playbook setup-dotfiles.yml --check --diff -v --tags packages
   ```

---

## Summary

**Quick Dry Run Command:**
```bash
cd ~/dotfiles && ansible-playbook setup-dotfiles.yml --check --diff -v
```

**What it does:**
- Shows ALL changes that would be made
- Displays file diffs
- Lists all tasks
- Makes ZERO actual changes
- Safe to run as many times as needed

**Next Step:** Once satisfied, remove `--check` to run for real

---

**Created:** January 2026  
**System:** Shinkiro (Desktop - Arch Linux)
