# Neovim Troubleshooting

Lessons learned from debugging LSP, Mason, and plugin issues.

## LSP Server Not Attaching (gd / Go to Definition not working)

### Symptoms
- `gd` gives: `server does not support textDocument/definition`
- `:LspInfo` shows `{}` or only Copilot attached
- `:LspLog` shows no trace of the expected LSP server starting

### Debugging Steps

1. **Check what's attached to the buffer:**
   ```vim
   :lua for _, client in pairs(vim.lsp.get_clients()) do print(client.name, client.server_capabilities.definitionProvider) end
   ```
   - Should show `ts_ls true` (or `vtsls true`) for TypeScript files
   - If only `copilot nil` appears, no real LSP is attached

2. **Check the file type:**
   ```vim
   :set ft?
   ```
   - Should show `typescriptreact` for `.tsx`, `typescript` for `.ts`, etc.

3. **Check LSP logs:**
   ```vim
   :LspLog
   ```

4. **Try starting the server manually:**
   ```vim
   :LspStart ts_ls
   ```

5. **Check Mason installations:**
   ```vim
   :Mason
   ```
   Or from terminal: `ls ~/.local/share/nvim/mason/packages/`

### Common Causes

#### Mason-lspconfig version mismatch (tsserver vs ts_ls)
- `nvim-lspconfig` renamed `tsserver` to `ts_ls` in late 2024
- Older `mason-lspconfig` versions map `typescript-language-server` to `tsserver`
- If your config uses `ts_ls = {}` but mason-lspconfig maps to `tsserver`, auto-attach breaks silently
- **Fix:** Update mason-lspconfig to latest, or manually `:LspStart ts_ls` to verify

#### LazyVim TypeScript extra without vtsls installed
- The `lazyvim.plugins.extras.lang.typescript` extra uses `vtsls` (not `ts_ls`)
- It explicitly disables `ts_ls` when enabled
- If `vtsls` plugin fails to install via Lazy, you end up with NO TypeScript LSP
- **Fix:** Check `lazy-lock.json` for `vtsls` entry; if missing, comment the extra back out
- **Verify:** `ls ~/.local/share/nvim/lazy/ | grep vtsls`

#### Mason version pins causing stale state
- Mason v2.0 (May 2025) restructured internal modules
- Old workaround: pin mason to v1.11.0 and mason-lspconfig to v1.32.0
- These pins prevent auto-attach from working correctly with newer lspconfig
- **Fix:** Remove version pins, keep the compatibility shim (see below)

## Mason Compatibility Shim

**File:** `lua/plugins/mason-workaround.lua`

LazyVim calls `require("mason-lspconfig.mappings").get_mason_map()` but some versions of mason-lspconfig don't have a top-level `mappings` module (it's split into `mappings/server.lua` and `mappings/filetype.lua`).

The shim in `mason-workaround.lua`:
- Checks if `mason-lspconfig.mappings` can be loaded
- If not, loads `mason-lspconfig.mappings.server` and creates the expected module
- Only activates when needed (safe to keep permanently)
- Track: https://github.com/LazyVim/LazyVim/issues/6039

**Do NOT remove this file** until LazyVim stops requiring the old module path.

## Clean Reinstall Procedure

When plugins get into a broken half-updated state:

1. Close all Neovim instances
2. Run: `bash scripts/clean-nvim.sh --force` (or `make clean-nvim`)
3. Open `nvim` — Lazy will reinstall everything fresh
4. Run `:Lazy sync` to ensure lock file is up to date

This wipes `~/.local/share/nvim/lazy/`, `~/.local/share/nvim/mason/`, and `~/.cache/nvim/`.
It does NOT touch config files or `lazy-lock.json`, so pinned versions are preserved.

## LSP Server Configuration

**File:** `lua/plugins/nvim-lspconfig.lua`

Currently configured servers:
- `gopls` — Go (with extensive settings)
- `bashls` — Bash/Zsh
- `ruby_lsp` — Ruby (via rbenv)
- `rubocop` — Ruby linter (via bundler)
- `sqlls` — SQL
- `ts_ls` — TypeScript/JavaScript
- `yamlls` — YAML

### Adding a new LSP server
1. Add to the `servers` table in `nvim-lspconfig.lua`
2. Mason will auto-install it (or install manually with `:Mason`)
3. Open a file of that type — LSP should attach automatically

## Key Files

| File | Purpose |
|------|---------|
| `lua/config/lazy.lua` | LazyVim extras (TypeScript extra commented out) |
| `lua/plugins/nvim-lspconfig.lua` | LSP server configurations |
| `lua/plugins/mason-workaround.lua` | Mason compatibility shim (DO NOT DELETE) |
| `lua/plugins/lsp-keymaps.lua` | Custom LSP keybindings |
| `lua/plugins/disabled.lua` | Disabled plugins list |
| `scripts/clean-nvim.sh` | Plugin/cache cleanup script |
