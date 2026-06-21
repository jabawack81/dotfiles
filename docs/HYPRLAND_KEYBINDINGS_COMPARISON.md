# Hyprland Keybindings: Shinkiro vs Lupus

Side-by-side comparison of Hyprland keybindings between the two machines, so you can decide what to align.

| Machine  | Config source                                                        |
|----------|----------------------------------------------------------------------|
| Shinkiro | This repo: `common/hypr/common.conf` + `shinkiro/hypr/hyprland.conf` |
| Lupus    | Omarchy defaults (`~/.local/share/omarchy/default/hypr/bindings/`)   |

Omarchy bindings reflect the `basecamp/omarchy` repo (`dev` branch) at the time this doc was written. If your installed Omarchy version differs, verify with `omarchy-menu-keybindings` (Super + K).

User-level overrides on lupus go in `.conf` files sourced *after* the Omarchy defaults (later source wins), not in a Lua file. The dotfiles-tracked overrides live in `lupus/hypr/bindings.conf`, sourced from `~/.config/hypr/hyprland.conf`; the `source =` line is wired up by the lupus task in `tasks/desktop.yml`. To replace an Omarchy default, add an `unbind = SUPER, X` before the new `bindd = ...`. (Earlier revisions of this doc described a `~/.config/hypr/bindings.lua` / `hl.unbind` / `o.bind` system — that mechanism does not exist on this Omarchy version.)

---

## 1. Applications & utilities

| Action                  | Shinkiro               | Lupus (Omarchy)                  | Status         | Plan                                                                                                                                                                                    |
|-------------------------|------------------------|----------------------------------|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Terminal                | `Super + Q`            | `Super + Return`                 | **Conflict**   | align to `Super + Return` for muscle memory, less collision risk                                                                                                                        |
| Browser                 | `Super + F`            | `Super + Shift + B` / `+ Return` | **Conflict**   | align to `Super + Shift + B` for muscle memory, less collision risk                                                                                                                     |
| File manager            | `Super + E` (thunar)   | `Super + Shift + F` (nautilus)   | **Conflict**   | align to `Super + Shift + F` for muscle memory, less collision risk                                                                                                                     |
| App launcher / menu     | `Super + R`            | `Super + Space` (walker)         | **Conflict**   | ✅ **Applied**: drop hyprlauncher on shinkiro; `Super + Space` already opens quickshell:omni — promote it to the primary launcher on both machines (omni for shinkiro, walker for lupus) |
| Editor                  | —                      | `Super + Shift + N`              | Lupus only     |                                                                                                                                                                                         |
| Discord                 | `Super + D`            | —                                | Shinkiro only  |                                                                                                                                                                                         |
| Steam                   | `Super + G`            | —                                | Shinkiro only  |                                                                                                                                                                                         |
| Telegram                | `Super + T`            | —                                | Shinkiro only  | ✅ **Applied**: remove the Telegram binding from shinkiro (rarely used) — frees `Super + T` for Toggle floating                                                                          |
| Toggle floating         | `Super + V`            | `Super + T`                      | **Conflict**   | ✅ **Applied**: align to `Super + T` on shinkiro (Telegram binding removed, no longer blocks)                                                                                            |
| Lock screen             | `Super + L` (hyprlock) | `Super + Ctrl + L`               | **Conflict**   | ✅ **Applied**: align to `Super + Ctrl + L` — `Super + L` left unbound on shinkiro for now (could later mirror Omarchy's "toggle workspace layout")                                      |
| Show keybinding help    | `Super + Shift + /`    | `Super + K`                      | Both, diff key | align to `Super + K` for muscle memory, less collision risk                                                                                                                             |
| Emoji picker            | —                      | `Super + Ctrl + E`               | Lupus only     |                                                                                                                                                                                         |
| Audio / BT / Wifi menus | —                      | `Super + Ctrl + A/B/W`           | Lupus only     |                                                                                                                                                                                         |
| Color picker            | —                      | `Super + Print`                  | Lupus only     |                                                                                                                                                                                         |
| Zoom in / reset         | —                      | `Super + Ctrl + Z` / `+ Alt + Z` | Lupus only     | align to `Super + Ctrl + Z` for muscle memory, less collision risk                                                                                                                      |

Notes:

- `Super + V` is the worst conflict — on shinkiro it toggles floating, on Omarchy it pastes via universal-paste (synthetic Shift+Insert). If you align, decide which behavior you want where.
- `Super + L` collides with Omarchy's "toggle workspace layout". Locking lives on `Super + Ctrl + L` on Omarchy.
- `Super + G` collides with Omarchy's "toggle window grouping". Steam launching from this key is shinkiro-only.

---

## 2. Window focus & movement

| Action                                            | Shinkiro                            | Lupus (Omarchy)                                              | Status        | Plan                                                                                                                                    |
|---------------------------------------------------|-------------------------------------|--------------------------------------------------------------|---------------|-----------------------------------------------------------------------------------------------------------------------------------------|
| Focus left/right/up/down                          | `Super + Arrow`                     | `Super + Arrow`                                              | **Same** ✓    |                                                                                                                                         |
| Swap window left/right/up/down                    | —                                   | `Super + Shift + Arrow`                                      | Lupus only    |                                                                                                                                         |
| Move window to workspace 1-10                     | `Super + Shift + 1-0`               | `Super + Shift + 1-0`                                        | **Same** ✓    |                                                                                                                                         |
| Move window to next/prev workspace (same monitor) | `Super + Ctrl + Shift + Left/Right` | —                                                            | Shinkiro only | ✅ **Applied**: port to lupus using plain `movetoworkspace, r+1`/`r-1` (shinkiro parity script doesn't apply to a single-monitor laptop) |
| Toggle window split (dwindle)                     | `Super + J`                         | `Super + J`                                                  | **Same** ✓    |                                                                                                                                         |
| Pseudo window                                     | `Super + P`                         | `Super + P`                                                  | **Same** ✓    |                                                                                                                                         |
| Kill / close active window                        | `Super + C`                         | `Super + W`                                                  | **Conflict**  | align to `Super + W` for muscle memory, less collision risk                                                                             |
| Close ALL windows                                 | —                                   | `Ctrl + Alt + Delete`                                        | Lupus only    | align to `Ctrl + Alt + Delete` for muscle memory, no collision risk                                                                     |
| Exit Hyprland                                     | `Super + M`                         | —                                                            | Shinkiro only |                                                                                                                                         |
| Fullscreen                                        | —                                   | `Super + F`                                                  | Lupus only    |                                                                                                                                         |
| Tiled fullscreen                                  | —                                   | `Super + Ctrl + F`                                           | Lupus only    |                                                                                                                                         |
| Maximize (full width)                             | —                                   | `Super + Alt + F`                                            | Lupus only    |                                                                                                                                         |
| Pop window out (float + pin)                      | —                                   | `Super + O`                                                  | Lupus only    |                                                                                                                                         |
| Move/resize with mouse                            | `Super + LMB` / `RMB`               | `Super + LMB` / `RMB`                                        | **Same** ✓    |                                                                                                                                         |
| Resize window (keyboard)                          | —                                   | `Super + [`/`]` (+ Shift/Alt/Ctrl for direction & magnitude) | Lupus only    | ✅ **Applied**: port to shinkiro; GB layout on both machines so the `[`/`]` symbols line up — will verify keycodes when applying         |

Notes:

- `Super + C` (shinkiro close) collides with Omarchy's universal-copy. If aligning to one, shinkiro's `Super + C` is the dangerous one to add to lupus.
- `Super + F` is a real conflict: shinkiro launches browser, Omarchy toggles fullscreen.

---

## 3. Workspaces

| Action                                     | Shinkiro                               | Lupus (Omarchy)                            | Status        | Plan                                                                                                                                                                                                                                 |
|--------------------------------------------|----------------------------------------|--------------------------------------------|---------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Switch to workspace 1-10                   | `Super + 1-0`                          | `Super + 1-0` (keycode-based, layout-safe) | **Same** ✓    |                                                                                                                                                                                                                                      |
| Cycle workspace on **current monitor**     | `Super + Ctrl + Left/Right`            | —                                          | Shinkiro only | ⏭ **Skipped**: keeping Omarchy's group-nav on `Super + Ctrl + Left/Right` is more valuable than the workspace cycling muscle memory; will use `Super + Tab` instead on both machines                                                 |
| Cycle workspace on current monitor (mouse) | `Super + Ctrl + Scroll`                | —                                          | Shinkiro only | align to `Super + Ctrl + Scroll` for muscle memory, no collision risk                                                                                                                                                                |
| Next / previous workspace (any monitor)    | —                                      | `Super + Tab` / `Super + Shift + Tab`      | Lupus only    | ✅ **Applied**: align to `Super + Tab` / `Super + Shift + Tab` on shinkiro — ⚠️ requires moving quickshell:overview off `Super + Tab` (pick a new key when applying; e.g. `Super + Shift + Tab` if you don't need previous-workspace) |
| Last (former) workspace                    | —                                      | `Super + Ctrl + Tab`                       | Lupus only    | align to `Super + Ctrl + Tab` for muscle memory, no collision risk                                                                                                                                                                   |
| Scroll through workspaces                  | `Super + Scroll`                       | `Super + Scroll`                           | **Same** ✓    |                                                                                                                                                                                                                                      |
| New empty workspace on current monitor     | `Super + N` (parity-aware on shinkiro) | —                                          | Shinkiro only | ✅ **Applied**: port to lupus using plain `workspace, emptym` (no parity script needed on single-monitor laptop)                                                                                                                      |
| Move workspace to another monitor          | —                                      | `Super + Shift + Alt + Arrow`              | Lupus only    | ✅ **Applied**: port to shinkiro — mostly moot on lupus laptop unless docked, but harmless to have everywhere                                                                                                                         |
| Toggle special workspace (scratchpad)      | `Super + S`                            | `Super + S`                                | **Same** ✓    |                                                                                                                                                                                                                                      |
| Move window to scratchpad                  | `Super + Shift + S`                    | `Super + Alt + S`                          | **Conflict**  | ✅ **Applied**: align to `Super + Shift + S` on lupus — leave Omarchy's `Super + Alt + S` in place as a redundant secondary binding (no need to unbind)                                                                               |

Notes:

- **This is the binding you mentioned.** Shinkiro's "switch workspace with arrows" is `Super + Ctrl + Left/Right`. On Omarchy, that combo is already taken by *Move grouped window focus left/right* — you'd need to `hl.unbind()` it before rebinding.
- Shinkiro's workspaces are wired to specific monitors (odd=DP-2, even=DP-3) plus a `new-workspace-on-monitor.sh` helper. Lupus is a laptop, so monitor-aware workspace logic is largely moot unless docked.

---

## 4. Window grouping (Omarchy only)

Omarchy has a full window-grouping system that shinkiro doesn't use:

| Action                     | Lupus (Omarchy)                       |
|----------------------------|---------------------------------------|
| Toggle grouping            | `Super + G`                           |
| Move window out of group   | `Super + Alt + G`                     |
| Move into group on side    | `Super + Alt + Arrow`                 |
| Next / previous in group   | `Super + Alt + Tab` / `+ Shift + Tab` |
| Group focus left/right     | `Super + Ctrl + Left/Right`           |
| Jump to grouped window 1-5 | `Super + Alt + 1-5`                   |

**The `Super + Ctrl + Left/Right` line is what collides with shinkiro's workspace cycling.**

---

## 5. Window switching across the system

| Action                          | Shinkiro        | Lupus (Omarchy)         |
|---------------------------------|-----------------|-------------------------|
| Cycle next/prev window          | —               | `Alt + Tab` / `+ Shift` |
| Bring active window to top      | —               | `Alt + Tab`             |
| Focus next/prev monitor         | —               | `Ctrl + Alt + Tab`      |
| Workspace overview (quickshell) | `Super + Tab`   | —                       |
| Omni / command palette          | `Super + Space` | —                       |

Notes:

- `Super + Tab` is the biggest behavioral split: shinkiro uses it for the quickshell overview, Omarchy uses it for "next workspace".
- `Super + Space` is shinkiro's quickshell palette; on Omarchy it launches the walker app launcher. **Functionally similar role**, different implementations.

---

## 6. Screenshots

| Action                       | Shinkiro                        | Lupus (Omarchy)                           |
|------------------------------|---------------------------------|-------------------------------------------|
| Screenshot (default)         | `Print` → copy area (grimblast) | `Print` → omarchy-capture                 |
| Screenshot whole screen      | `Shift + Print` → copy screen   | —                                         |
| Save screenshot area to file | `Super + Print` → save area     | `Super + Print` → color picker (conflict) |
| Screen recording             | —                               | `Alt + Print` (menu)                      |
| OCR from screenshot          | —                               | `Super + Ctrl + Print`                    |

Both use `Print` as the primary key but invoke different tools; the menus differ.

---

## 7. Media keys

Functionally identical between machines — only the underlying tool changes.

| Action                              | Shinkiro                             | Lupus (Omarchy)                            |
|-------------------------------------|--------------------------------------|--------------------------------------------|
| Volume up/down/mute                 | `XF86Audio*` → pamixer / wpctl       | `XF86Audio*` → swayosd-client              |
| Mic mute                            | `XF86AudioMicMute`                   | `XF86AudioMicMute`                         |
| Brightness up/down                  | `XF86MonBrightness*` → brightnessctl | `XF86MonBrightness*` → omarchy             |
| Brightness min/max                  | —                                    | `Shift + XF86MonBrightness*`               |
| Precise volume/brightness (1% step) | —                                    | `Alt + XF86*`                              |
| Play/Pause/Next/Prev                | `XF86Audio*` → playerctl             | `XF86Audio*` → swayosd+playerctl           |
| Stop                                | `XF86AudioStop` (shinkiro extra)     | —                                          |
| Keyboard backlight                  | —                                    | `XF86KbdBrightness*` / `XF86KbdLightOnOff` |
| Touchpad toggle                     | —                                    | `XF86TouchpadToggle`                       |

---

## 8. Status bar / notifications / system menus (Omarchy only)

Shinkiro has none of these — they're entirely Omarchy features:

| Action                           | Lupus (Omarchy)                   |
|----------------------------------|-----------------------------------|
| Toggle waybar                    | `Super + Shift + Space`           |
| Move waybar (top/bot/left/right) | `Super + Shift + Ctrl + Arrow`    |
| Theme menu                       | `Super + Shift + Ctrl + Space`    |
| Background switcher              | `Super + Ctrl + Space`            |
| Toggle window transparency       | `Super + Backspace`               |
| Toggle gaps                      | `Super + Shift + Backspace`       |
| Dismiss notifications            | `Super + ,` / `Super + Shift + ,` |
| Toggle idle lock                 | `Super + Ctrl + I`                |
| Toggle nightlight                | `Super + Ctrl + N`                |
| System / power / hardware menus  | `Super + Esc`, `+ Ctrl + H/O/C`   |
| Reminders                        | `Super + Ctrl + R` (menu)         |

The shinkiro equivalent for some of these (bar toggle, palette) lives on `Super + Shift + B` (toggle waybar↔quickshell), `Super + Tab` (overview), `Super + Space` (omni menu).

---

## 9. Lupus-specific (laptop / lid)

Not really "keybindings", but in the same config:

- `switch:on:Lid Switch` → omarchy: stops internal monitor + fingerprint; dotfiles overrides this in `monitors.conf`
- `switch:off:Lid Switch` → reverse

---

## Cheat sheet: what to copy, what to leave

| Shinkiro binding                                        | Recommendation for lupus                                                                |
|---------------------------------------------------------|-----------------------------------------------------------------------------------------|
| `Super + Ctrl + Left/Right` → switch ws                 | Port if you use it muscle-memory. Requires `hl.unbind` of group nav first.              |
| `Super + Ctrl + Scroll` → switch ws                     | Same as above; small but cheap to add.                                                  |
| `Super + Ctrl + Shift + Left/Right` → move window to ws | Port together with the above for symmetry. Conflicts nothing on Omarchy.                |
| `Super + N` → new empty ws on monitor                   | Port; Omarchy has no equivalent.                                                        |
| `Super + Q` → terminal                                  | Don't port — `Super + Return` is the Omarchy idiom, less collision risk.                |
| `Super + R` → menu                                      | Don't port — `Super + Space` (walker) is the Omarchy idiom.                             |
| `Super + L` → lock                                      | Don't port — Omarchy uses `Super + Ctrl + L`. Easier to retrain shinkiro than fight it. |
| `Super + V` → toggle floating                           | **Don't port** — would break clipboard paste on lupus.                                  |
| `Super + C` → kill window                               | **Don't port** — would break clipboard copy on lupus.                                   |
| `Super + Tab` → overview                                | Skip; quickshell isn't installed on lupus.                                              |
| `Super + Space` → omni menu                             | Skip; walker fills the same role on lupus.                                              |

---

## How to apply a port on lupus

Lupus parity bindings are tracked in `lupus/hypr/bindings.conf` and sourced from `~/.config/hypr/hyprland.conf` *after* the Omarchy defaults, so they override on conflict. The `source =` line is wired up idempotently by the lupus task in `tasks/desktop.yml`, so a fresh `setup-dotfiles.yml` run picks it up.

To add another port, append to `lupus/hypr/bindings.conf`. If the chord is already bound by an Omarchy default, `unbind` it first. Example for the workspace cycling case:

```conf
# Remove Omarchy's group-nav on these chords first
unbind = SUPER CTRL, LEFT
unbind = SUPER CTRL, RIGHT

# Shinkiro-style workspace cycling on current monitor
bindd = SUPER CTRL, LEFT,  Previous workspace (current monitor), workspace, m-1
bindd = SUPER CTRL, RIGHT, Next workspace (current monitor),     workspace, m+1
```

After editing, validate with `hyprctl reload` then `hyprctl configerrors` (Hyprland auto-reloads on save, but this confirms it parsed cleanly).
