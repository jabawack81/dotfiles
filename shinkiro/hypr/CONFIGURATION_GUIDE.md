# Hyprland Complete Configuration Guide

**System:** Shinkiro (Desktop PC)  
**Hyprland Version:** v3  
**Last Updated:** January 2026

This guide explains every configuration option in your Hyprland setup, what it does, and how to modify it.

---

## Table of Contents

1. [Program Variables](#program-variables)
2. [Environment Variables](#environment-variables)
3. [General Settings](#general-settings)
4. [Decoration & Visual Effects](#decoration--visual-effects)
5. [Animations](#animations)
6. [Layout Management](#layout-management)
7. [Input Configuration](#input-configuration)
8. [Keybindings](#keybindings)
9. [Window Rules](#window-rules)
10. [Monitor Configuration](#monitor-configuration)
11. [Autostart Programs](#autostart-programs)
12. [Lock Screen (Hyprlock)](#lock-screen-hyprlock)

---

## Program Variables

**File:** `common.conf` (Lines 7-11)

Variables let you define programs once and reuse them throughout the config. This makes it easy to swap applications.

```conf
$terminal = ghostty      # Terminal emulator
$fileManager = thunar    # File manager
$menu = fuzzel           # Application launcher
$browser = firefox       # Web browser
```

### Usage in Keybindings

These variables are referenced throughout the config:
- `$terminal` → Opens Ghostty terminal
- `$fileManager` → Opens Thunar file manager
- `$menu` → Opens Fuzzel application launcher
- `$browser` → Opens Firefox

### How to Change

To use a different terminal, simply modify:
```conf
$terminal = alacritty    # Instead of ghostty
```

---

## Environment Variables

**File:** `common.conf` (Lines 17-18)

Environment variables control system-wide settings that affect how Hyprland and applications interact.

### XCURSOR_SIZE

```conf
env = XCURSOR_SIZE,24
```

**What it does:** Sets the size of your mouse cursor to 24 pixels  
**Values:** 0-128 pixels (typical: 16-48)  
**Why:** Ensures mouse cursor is visible at your screen resolution (dual 4K monitors = 24px is reasonable)

### HYPRCURSOR_SIZE

```conf
env = HYPRCURSOR_SIZE,24
```

**What it does:** Sets the size of Hyprland's native cursor theme  
**Values:** 0-128 pixels  
**Why:** Hyprland can use its own cursor system; this keeps it in sync with XCURSOR_SIZE

---

## General Settings

**File:** `common.conf` (Lines 25-42)

The `general` block controls fundamental window behavior and visual layout.

### gaps_in

```conf
gaps_in = 5
```

**What it does:** Space between windows within a tile group (internal gaps)  
**Values:** 0-100 pixels  
**Current Setting:** 5px between windows  
**Use Cases:**
- Higher values (10-20) for minimalist look
- Lower values (0-5) for compact layouts
- 0 removes gaps entirely

### gaps_out

```conf
gaps_out = 20
```

**What it does:** Space between tiles and screen edges (external gaps)  
**Values:** 0-100 pixels  
**Current Setting:** 20px from edges  
**Use Cases:**
- 20px is common balanced setting
- 0 removes edge gaps
- Higher values (30-50) for floating window feel

**Visual Example:**
```
┌─────────────────────────────┐
│         gaps_out (20px)     │
│ ┌───────────────┬─────────┐ │
│ │               │         │ │
│ │   gaps_in     │ gaps_in │ │
│ │    (5px)      │ (5px)   │ │
│ │               │         │ │
│ └───────────────┴─────────┘ │
│         gaps_out (20px)     │
└─────────────────────────────┘
```

### border_size

```conf
border_size = 2
```

**What it does:** Thickness of window borders (in pixels)  
**Values:** 0-10 pixels  
**Current Setting:** 2px borders  
**Visual Impact:**
- 0 = No visible borders
- 1 = Thin border (minimalist)
- 2-3 = Standard visible border (current)
- 4+ = Thick, prominent borders

### col.active_border

```conf
col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
```

**What it does:** Border color of the focused/active window  
**Format:** `rgba(RRGGBBAA) rgba(RRGGBBAA) angle`  
**Current Colors:**
- `rgba(33ccffee)` = Cyan (#33CCFF) with 93% opacity (238/255)
- `rgba(00ff99ee)` = Green (#00FF99) with 93% opacity
- `45deg` = Gradient angle (diagonal)

**Gradient Result:** Smooth cyan-to-green diagonal gradient on focused window border

**How to Customize:**
```conf
# Solid red border
col.active_border = rgba(ff0000ff)

# Red to blue gradient
col.active_border = rgba(ff0000ff) rgba(0000ffff) 90deg

# Use RGBA: rgba(RED, GREEN, BLUE, ALPHA)
# RED/GREEN/BLUE: 0-255 or 00-FF in hex
# ALPHA: 0-255 (0=transparent, 255=opaque)
```

### col.inactive_border

```conf
col.inactive_border = rgba(595959aa)
```

**What it does:** Border color of unfocused/inactive windows  
**Current Color:** Gray (#595959) with 67% opacity (170/255)  
**Purpose:** Visually distinguish focused vs unfocused windows

### resize_on_border

```conf
resize_on_border = false
```

**What it does:** Allow window resizing by dragging borders/gaps  
**Options:**
- `true` = Click and drag borders to resize (comfortable)
- `false` = Must use keybindings to resize (current)

**Current:** Disabled - use keybindings instead

### allow_tearing

```conf
allow_tearing = false
```

**What it does:** Enables screen tearing for low-latency display updates  
**Options:**
- `true` = Allows tearing (reduces input lag, not smooth)
- `false` = Vsync enabled (smooth, slight input lag)

**Current:** Disabled - prioritizes smooth animation  
**When to Enable:** Only for fast-paced games where input lag matters more than visual smoothness

### layout

```conf
layout = dwindle
```

**What it does:** Default tiling layout algorithm  
**Options:**
- `dwindle` = Recursive binary space partitioning (current) - windows shrink in ratio
- `master` = Master-stack layout (one large window + stack)

**Dwindle Behavior:**
```
Original:        After Split:
┌────────┐       ┌──────┬──┐
│        │  ->   │      │  │
│        │       ├──┬───┤  │
│        │       │  │   │  │
└────────┘       └──┴───┴──┘
```

---

## Decoration & Visual Effects

**File:** `common.conf` (Lines 45-68)

The `decoration` block controls how windows look - corners, shadows, transparency, and blur.

### Window Rounding

```conf
rounding = 10
rounding_power = 2
```

**rounding:** Corner radius in pixels  
- 0 = Sharp square corners
- 10 = Rounded corners (current)
- 15-20 = Very rounded (macOS-like)

**rounding_power:** Curve shape of corners  
- 1 = Linear curve (simple rounding)
- 2 = Quadratic curve (smoother rounding, current)
- 3+ = More pronounced curve

**Visual Examples:**
```
rounding=0, power=1    rounding=10, power=2   rounding=15, power=3
┌──────────┐          ╭──────────╮           ╭────────╮
│          │          │          │           │        │
│          │          │          │           │        │
│          │          │          │           │        │
└──────────┘          ╰──────────╯           ╰────────╯
```

### active_opacity & inactive_opacity

```conf
active_opacity = 1.0
inactive_opacity = 1.0
```

**What it does:** Transparency of focused and unfocused windows  
**Values:** 0.0 (invisible) to 1.0 (fully opaque)  
**Current:** Both at 1.0 = No transparency  

**Practical Examples:**
```conf
# Fade unfocused windows
active_opacity = 1.0
inactive_opacity = 0.85       # Slightly transparent

# Show desktop behind
active_opacity = 0.95
inactive_opacity = 0.7        # Quite transparent

# Fade everything
active_opacity = 0.9
inactive_opacity = 0.8
```

**Performance Impact:** Transparency has minimal impact on AMD GPUs (Shinkiro)

### Shadow Configuration

```conf
shadow {
    enabled = true
    range = 4
    render_power = 3
    color = rgba(1a1a1aee)
}
```

**enabled:** Turn shadows on/off

**range:** Size of shadow blur (pixels)  
- 4 = Subtle shadow (current)
- 1-2 = Very subtle
- 8-15 = Prominent shadow

**render_power:** Shadow darkness/intensity  
- 1 = Light shadow
- 3 = Medium shadow (current)
- 5+ = Dark shadow

**color:** Shadow color  
- `rgba(1a1a1aee)` = Very dark gray (#1A1A1A) at 93% opacity
- Use darker colors for prominent shadows
- Use lighter colors for subtle shadows

**Visual Example:**
```
range=4, power=1:     range=8, power=3:      range=12, power=5:
╭─────────╮         ╭──────────╮            ╭──────────╮
│ Window  │ ·       │ Window   │ ··        │ Window   │ ···
╰─────────╯ ·       ╰──────────╯ ··       ╰──────────╯ ···
    ·                   ··                      ···
```

### Blur Configuration

```conf
blur {
    enabled = true
    size = 3
    passes = 1
    vibrancy = 0.1696
}
```

**enabled:** Turn blur on/off (great for layered UI)

**size:** Blur kernel size  
- 1-5 = Subtle blur (current: 3)
- 5-10 = Moderate blur
- 10+ = Heavy blur (performance cost)

**passes:** Number of blur iterations  
- 1 = Single blur pass (current, fast)
- 2-3 = Multiple passes (smoother, slower)
- 4+ = Heavy blur (noticeable performance hit)

**vibrancy:** Color saturation boost of blurred area  
- 0.0 = No saturation increase (neutral blur)
- 0.1696 = 17% boost (current, subtle)
- 0.5 = Strong color saturation
- Higher = More vibrant colors behind blur

**Use Cases:**
- Blur on panels (waybar) for visual separation
- Blur on notifications for layering effect
- Disable on EWW widgets (handled separately in window rules)

---

## Animations

**File:** `common.conf` (Lines 71-98)

Animations control how visual elements move and transition. They make the UI feel responsive.

### Global Animation Flag

```conf
enabled = yes, please :)
```

**What it does:** Master switch for all animations  
**Note:** The phrase "yes, please :)" is a fun Hyprland easter egg for `true`

### Custom Bezier Curves

Bezier curves define animation easing (how smooth/fast animations feel).

```conf
bezier = easeOutQuint,0.23,1,0.32,1
bezier = easeInOutCubic,0.65,0.05,0.36,1
bezier = linear,0,0,1,1
bezier = almostLinear,0.5,0.5,0.75,1.0
bezier = quick,0.15,0,0.1,1
```

**Format:** `bezier = name, x1, y1, x2, y2`

**Current Curves:**

1. **easeOutQuint** - Starts fast, ends slow (snappy animation)
   - Good for: Window opening
   - Feels: Responsive and natural

2. **easeInOutCubic** - Slow start, fast middle, slow end
   - Good for: Window transitions
   - Feels: Smooth and deliberate

3. **linear** - Constant speed
   - Good for: Simple continuous motion
   - Feels: Mechanical, uniform

4. **almostLinear** - Nearly constant with slight ease
   - Good for: Workspace transitions
   - Feels: Almost linear but slightly smoothed

5. **quick** - Very fast start, smooth end
   - Good for: Border color changes
   - Feels: Snappy and responsive

**How to Visualize:**
```
easeOutQuint:        linear:              easeInOutCubic:
┃  ─┐                ┃ ╱                  ┃   ╱─╲
┃ ╱  ╲               ┃╱                   ┃ ╱     ╲
┃╱    ╲              ┃                    ┃╱       ╲
```

### Animation Definitions

```conf
animation = global, 1, 10, default
```

**Format:** `animation = type, enabled, speed, curve [, param]`

- **Type:** What animates (global, border, windows, etc.)
- **Enabled:** 1 = on, 0 = off
- **Speed:** 1-100 (higher = faster)
- **Curve:** Name from bezier definitions above
- **Param:** Optional extra parameters

### Specific Animations Explained

```conf
animation = border, 1, 5.39, easeOutQuint
```
**What:** Border color change animation  
**Speed:** 5.39 (moderate)  
**Curve:** easeOutQuint (snappy)  
**Result:** Smooth, responsive border color transitions when focusing windows

```conf
animation = windows, 1, 4.79, easeOutQuint
```
**What:** Window move/resize animation  
**Speed:** 4.79  
**Curve:** easeOutQuint  
**Result:** Windows smoothly glide when repositioned

```conf
animation = windowsIn, 1, 4.1, easeOutQuint, popin 87%
```
**What:** Windows appearing animation  
**Speed:** 4.1  
**Curve:** easeOutQuint  
**Extra:** `popin 87%` - Pops in from 87% scale  
**Result:** New windows gracefully pop into view

```conf
animation = fadeIn, 1, 1.73, almostLinear
animation = fadeOut, 1, 1.46, almostLinear
```
**What:** Fade in/out animations  
**Speed:** 1.73 (fade in), 1.46 (fade out)  
**Curve:** almostLinear (smooth)  
**Result:** Transparent overlays fade smoothly

```conf
animation = workspaces, 1, 1.94, almostLinear, fade
animation = workspacesIn, 1, 1.21, almostLinear, fade
animation = workspacesOut, 1, 1.94, almostLinear, fade
```
**What:** Workspace switching animations  
**Speed:** ~1.9  
**Curve:** almostLinear  
**Extra:** `fade` - Switch workspaces with fade effect  
**Result:** Smooth, seamless workspace transitions with fade

**Performance Impact:**
- Disabling animations saves CPU/GPU
- AMD GPU (Shinkiro): Handles these easily
- All animations are smooth at 60+ FPS

---

## Layout Management

**File:** `common.conf` (Lines 101-109)

### Dwindle Layout

```conf
dwindle {
    pseudotile = true
    preserve_split = true
}
```

**pseudotile:** Allow windows to behave like floating windows while tiled  
- `true` = Can resize while maintaining tile layout
- `false` = Fixed tile sizes  
**Current:** Enabled - Press `Super+P` to toggle

**preserve_split:** Keep split ratios when new windows open  
- `true` = Splits maintain their proportions (current)
- `false` = Reset splits for new windows

**Example (preserve_split = true):**
```
Step 1: Split window    Step 2: Add 3rd window    Result:
┌───────┬───────┐       ┌───────┬───────┐        ┌───────┬───────┐
│       │       │  -->  │       │ ┌─────┤  -->   │       │ ┌─┬───┤
│       │       │       │       │ │  3  │        │       │1│2│ 3 │
└───────┴───────┘       └───────┴─┴─────┘        └───────┴─┴─┴───┘
```

### Master Layout

```conf
master {
    new_status = master
}
```

**new_status:** What status new windows get  
- `master` = New windows become master (current)
- `slave` = New windows join stack
- `insert` = New windows inserted at focus position

**Master Layout Visual:**
```
┌──────────────┐
│   Master     │  1 large window
│   (Large)    │  + stack of smaller
├────┬────┬───┤
│ S1 │ S2 │S3 │  windows
└────┴────┴───┘
```

---

## Input Configuration

**File:** `common.conf` (Lines 122-136)

Controls how Hyprland responds to keyboard and mouse input.

### Keyboard Layout

```conf
kb_layout = gb
```

**What it does:** Sets keyboard layout  
**Current:** GB (British)  
**Common Values:**
- `gb` = British English
- `us` = United States
- `de` = German
- `fr` = French
- See `localectl list-x11-keymap-layouts` for all

**Other keyboard settings (commented out):**
```conf
#kb_variant =        # e.g., "dvorak", "colemak"
#kb_model =          # e.g., "pc104"
#kb_options =        # e.g., "caps:escape" (remap Caps Lock)
#kb_rules =          # Advanced keyboard rules
```

### Mouse Behavior

```conf
follow_mouse = 1
```

**What it does:** Focus follows mouse movement  
**Values:**
- `0` = Click to focus only
- `1` = Focus follows mouse movement (current)
- `2` = Focus follows mouse but doesn't change on movement while typing

**Current:** Enabled - window focuses when mouse moves over it

### Sensitivity

```conf
sensitivity = 0
```

**What it does:** Mouse cursor acceleration/deceleration  
**Range:** -1.0 to 1.0  
**Current:** 0 = No modification (raw input)  
**Examples:**
```conf
sensitivity = -0.5    # Slower movement
sensitivity = 0       # No change (current)
sensitivity = 0.5     # Faster movement
```

### Touchpad Configuration

```conf
touchpad {
    natural_scroll = false
}
```

**natural_scroll:** Reverse scroll direction  
- `true` = Scroll direction matches finger direction (macOS style)
- `false` = Traditional scroll (current)

**Current:** Disabled - traditional scrolling

---

## Keybindings

**File:** `common.conf` (Lines 143-214)

Keybindings control all keyboard shortcuts. Format: `bind = MODIFIERS, KEY, action, param`

### Modifier Variables

```conf
$mainMod = SUPER
```

**What it does:** Define main modifier key  
**Current:** SUPER (Windows key)  
**Other Modifiers:**
- `SHIFT`
- `CTRL` or `CONTROL`
- `ALT`
- `SUPER` (Windows/Command key)
- Combine with `+`: `SUPER SHIFT`

### Application Launch Bindings

```conf
bind = $mainMod, Q, exec, $terminal    # Super+Q = Open Terminal
bind = $mainMod, E, exec, $fileManager # Super+E = Open File Manager
bind = $mainMod, F, exec, $browser     # Super+F = Open Firefox
bind = $mainMod, R, exec, $menu        # Super+R = Open App Launcher
```

**What they do:** Launch applications

**Quick Reference:**
| Key | Action | Command |
|-----|--------|---------|
| Super+Q | Terminal | ghostty |
| Super+E | File Manager | thunar |
| Super+F | Browser | firefox |
| Super+R | App Launcher | fuzzel |
| Super+D | Discord | discord |
| Super+G | Steam | steam |
| Super+T | Telegram | telegram |
| Super+L | Lock Screen | hyprlock |

### Window Management Bindings

```conf
bind = $mainMod, C, killactive,        # Super+C = Close Window
bind = $mainMod, V, togglefloating,    # Super+V = Float/Tile Window
bind = $mainMod, P, pseudo,            # Super+P = Pseudotile Mode
bind = $mainMod, J, togglesplit,       # Super+J = Toggle Split Direction
```

**killactive:** Close the focused window gracefully

**togglefloating:** Switch between floating and tiled modes

**pseudo:** Enable pseudotile on current window (resizable while tiled)

**togglesplit:** Switch between vertical and horizontal splits

### Window Navigation

```conf
bind = $mainMod, left, movefocus, l    # Super+Left Arrow = Focus Left Window
bind = $mainMod, right, movefocus, r   # Super+Right Arrow = Focus Right Window
bind = $mainMod, up, movefocus, u      # Super+Up Arrow = Focus Up Window
bind = $mainMod, down, movefocus, d    # Super+Down Arrow = Focus Down Window
```

**What they do:** Move focus to adjacent windows

**Direction Parameters:**
- `l` = left
- `r` = right
- `u` = up
- `d` = down

### Workspace Switching

```conf
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
... (1-9) ...
bind = $mainMod, 0, workspace, 10
```

**What they do:** Switch to workspace 1-10

**Workspace Concept:**
```
Workspace 1:     Workspace 2:      Workspace 3:
┌────────────┐   ┌────────────┐   ┌────────────┐
│  Work      │   │  Chat      │   │  Gaming    │
│  Docs      │   │  Messages  │   │  Streaming │
└────────────┘   └────────────┘   └────────────┘
```

### Moving Windows to Workspaces

```conf
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
... (1-9) ...
bind = $mainMod SHIFT, 0, movetoworkspace, 10
```

**What they do:** Move focused window to workspace 1-10

**Example Usage:**
- Super+Shift+1 = Move current window to workspace 1

### Special Workspace (Scratchpad)

```conf
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic
```

**What it does:** Hidden workspace for temporary windows

**Usage:**
- Super+S = Toggle scratchpad visibility
- Super+Shift+S = Move window to scratchpad

**Use Case:**
```
Regular Workspaces:    Scratchpad:
1. Work               - Floating terminal
2. Chat              - Notes window
3. Games             - Music player
                      Hidden until needed
```

### Mouse Wheel Workspace Switching

```conf
bind = $mainMod, mouse_down, workspace, e+1    # Super+Scroll Down = Next Workspace
bind = $mainMod, mouse_up, workspace, e-1      # Super+Scroll Up = Previous Workspace
```

**What they do:** Navigate workspaces with mouse wheel

**`e+1`** and **`e-1`:**
- `e` = Current workspace number
- `e+1` = Next workspace
- `e-1` = Previous workspace

### Mouse Window Management

```conf
bindm = $mainMod, mouse:272, movewindow         # Super+LMB = Move Window
bindm = $mainMod, mouse:273, resizewindow       # Super+RMB = Resize Window
```

**bindm:** Mouse binding (drag-based)

**mouse:272:** Left Mouse Button (LMB)  
**mouse:273:** Right Mouse Button (RMB)

**Usage:**
- Super+Click and drag = Move window
- Super+Right-click and drag = Resize window

### Multimedia Keys

```conf
bindel = ,XF86AudioRaiseVolume, exec, pamixer -i 5      # Volume Up
bindel = ,XF86AudioLowerVolume, exec, pamixer -d 5      # Volume Down
bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bindel = ,XF86MonBrightnessUp, exec, brightnessctl s 10%+
bindel = ,XF86MonBrightnessDown, exec, brightnessctl s 10%-
```

**bindel:** Key binding with repeat (hold key for continuous action)

**What they do:**
- Volume Up/Down: Adjust volume ±5%
- Mute: Toggle audio mute
- Brightness Up/Down: Adjust brightness ±10%

**Tools Used:**
- `pamixer` - PulseAudio mixer
- `wpctl` - Wayland audio control
- `brightnessctl` - Brightness control

```conf
bindl = , XF86AudioNext, exec, playerctl next              # Media Next
bindl = , XF86AudioPause, exec, playerctl play-pause       # Play/Pause
bindl = , XF86AudioPlay, exec, playerctl play-pause        # Play
bindl = , XF86AudioPrev, exec, playerctl previous          # Media Previous
bindl = , XF86AudioStop, exec, playerctl stop              # Media Stop (desktop only)
```

**bindl:** Key binding without repeat (locked/one-time)

**What they do:** Control media playback (music, videos)

**Tool Used:**
- `playerctl` - Media player control (works with Spotify, VLC, etc.)

---

## Window Rules

**File:** `common.conf` (Lines 227-243)

Window rules apply behavior to windows matching specific patterns. See [Window Rules Migration Guide](./MIGRATION_v3_DOCUMENTATION.md) for v3 syntax details.

### Rule 1: Suppress Maximize Events

```conf
windowrule = match:class .*, suppress_event = maximize
```

**What it does:** Prevents applications from maximizing windows  
**Why:** Keeps tiles in predictable sizes  
**Match:** All windows (`.*`)

### Rule 2: XWayland Focus Fix

```conf
windowrule = match:class ^$, match:title ^$, match:xwayland true, 
            match:float true, match:fullscreen false, match:pin false, no_focus = on
```

**What it does:** Prevents focus on empty XWayland windows  
**Why:** Some XWayland apps create invisible windows; this prevents focus stealing  
**Conditions:**
- No window class (`^$`)
- No window title (`^$`)
- Is XWayland (`true`)
- Is floating (`true`)
- Not fullscreen (`false`)
- Not pinned (`false`)

### Rule 3: EWW Dashboard Widgets

```conf
windowrule {
  name = eww_dashboard
  match:class = ^(eww)$
  float = on
  no_focus = on
  no_initial_focus = on
  border_size = 0
  no_shadow = on
  pin = on
  no_anim = on
}
```

**What it does:** Configure EWW (widget system) windows as desktop widgets

**Effects:**
- `float = on` - Window floats above tiles
- `no_focus = on` - Can't focus the widget
- `no_initial_focus = on` - Never gets initial focus
- `border_size = 0` - No border
- `no_shadow = on` - No shadow
- `pin = on` - Visible on all workspaces
- `no_anim = on` - No opening animation

**Result:** EWW widgets act like OS-level widgets (taskbar, widgets, etc.)

---

## Monitor Configuration

**File:** `hyprland.conf` (Lines 12-13)

Configure multiple displays and their layout.

### Monitor Setup

```conf
monitor = DP-2, 3840x2160@59.99700, 0x0,      1.50
monitor = DP-3, 3840x2160@59.99700, 2560x0,   1.50
```

**Format:** `monitor = NAME, RESOLUTION@REFRESH, POSITION, SCALE`

### DP-2 Configuration

```conf
monitor = DP-2, 3840x2160@59.99700, 0x0, 1.50
```

- **Name:** DP-2 (DisplayPort 2)
- **Resolution:** 3840×2160 pixels (4K)
- **Refresh Rate:** 59.997 Hz (~60 Hz)
- **Position:** 0,0 (top-left monitor)
- **Scale:** 1.50 (1.5x scaling)

**Result:** 
- Physical size: 3840 × 2160 = 4K monitor
- Logical size: 2560 × 1440 (after 1.5x scale)
- Appears on left side of virtual display

### DP-3 Configuration

```conf
monitor = DP-3, 3840x2160@59.99700, 2560x0, 1.50
```

- **Name:** DP-3 (DisplayPort 3)
- **Resolution:** 3840×2160 pixels (4K)
- **Refresh Rate:** 59.997 Hz (~60 Hz)
- **Position:** 2560,0 (to the right of DP-2)
- **Scale:** 1.50 (1.5x scaling)

**Result:**
- Physical size: 3840 × 2160 = 4K monitor
- Logical size: 2560 × 1440 (after 1.5x scale)
- Positioned right of DP-2 monitor

### Dual Monitor Layout

```
DP-2 (Left)              DP-3 (Right)
2560×1440              2560×1440
[Virtual X: 0-2559]   [Virtual X: 2560-5119]
├─────────────────┬─────────────────┤
│      4K         │      4K         │
│    Monitor      │    Monitor      │
│  Scaled 1.5x    │  Scaled 1.5x    │
└─────────────────┴─────────────────┘
Total Virtual Workspace: 5120×1440
```

**Why 1.5x Scale?**
- Raw 4K (3840×2160) would be tiny text/UI on 27" monitors
- 1.5x scaling makes everything 50% larger
- Logical resolution: 2560×1440 = good balance of space and readability

### Finding Monitor Names

```bash
hyprctl monitors          # List connected monitors
```

### Changing Refresh Rates

```conf
# 144Hz gaming monitor
monitor = HDMI-1, 2560x1440@144, 0x0, 1.0

# Lowest power mode
monitor = DP-1, 3840x2160@30, 0x0, 1.5
```

---

## Autostart Programs

**File:** `hyprland.conf` (Lines 20)

Programs that launch automatically when Hyprland starts.

```conf
exec-once = ~/.config/waybar/waybar-launcher.sh & dunst & ~/.config/eww/eww-launcher.sh
```

**What it does:** Start three services on boot

**Components:**

1. **Waybar Launcher**
   ```bash
   ~/.config/waybar/waybar-launcher.sh
   ```
   - Launches waybar (status bar)
   - Shows time, workspace info, system stats

2. **Dunst**
   ```bash
   dunst
   ```
   - Notification daemon
   - Displays desktop notifications

3. **EWW Launcher**
   ```bash
   ~/.config/eww/eww-launcher.sh
   ```
   - Launches EWW widget system
   - Shows widgets, weather, app launcher

**Ampersand (&):**
- Runs commands in background
- Doesn't block startup
- All three services run in parallel

### Adding More Autostart Programs

```conf
# Launch single app
exec-once = discord

# Launch multiple in sequence
exec-once = nm-applet & blueman-applet

# Launch with arguments
exec-once = firefox --new-window https://example.com
```

---

## Lock Screen (Hyprlock)

**File:** `hyprlock.conf`

Complete lock screen configuration. The lock screen shows when you press Super+L.

### Background

```conf
background {
    monitor =
    path = ~/.config/hypr/hyprlock.png
    blur_passes = 0
    contrast = 0.8916
    brightness = 0.8172
    vibrancy = 0.1696
    vibrancy_darkness = 0.0
}
```

**monitor:** Which monitor(s) to display on (blank = all)

**path:** Background image location

**Image Effects:**
- `blur_passes = 0` - No blur applied
- `contrast = 0.8916` - Reduce contrast ~11%
- `brightness = 0.8172` - Reduce brightness ~18%
- `vibrancy = 0.1696` - Boost color saturation ~17%
- `vibrancy_darkness = 0.0` - No darkness adjustment

### General Settings

```conf
general {
    no_fade_in = false         # Fade in animation on startup
    grace = 0                   # Seconds before lock engages
    disable_loading_bar = false # Show loading bar
}
```

**no_fade_in:** Show fade-in animation  
**grace:** Delay before lock becomes active (0 = immediate)  
**disable_loading_bar:** Show progress indicator while locking

### Welcome Label

```conf
label {
    monitor =
    text = Welcome!
    color = rgba(216, 222, 233, .75)
    font_size = 55
    font_family = SF Pro Display Bold
    position = 150, 320
    halign = left
    valign = center
}
```

**Position Format:** `X, Y` (pixels from top-left)  
**Alignment:**
- `halign` = Horizontal (left, center, right)
- `valign` = Vertical (top, center, bottom)

**Color:** `rgba(R, G, B, A)` where A is opacity (0.75 = 75%)

### Time Display

```conf
label {
    monitor =
    text = cmd[update:1000] echo "<span>$(date +"%I:%M")</span>"
    color = rgba(216, 222, 233, .75)
    font_size = 40
    font_family = SF Pro Display Bold
    position = 240, 240
    halign = left
    valign = center
}
```

**text = cmd[update:1000]** - Execute shell command, update every 1000ms (1 second)  
**date +"%I:%M"** - Show time in 12-hour format (HH:MM)

**Time Format Examples:**
```conf
# 24-hour time (14:30)
text = cmd[update:1000] echo "<span>$(date +"%H:%M")</span>"

# With seconds (14:30:45)
text = cmd[update:1000] echo "<span>$(date +"%H:%M:%S")</span>"

# Show timezone (2:30 PM EST)
text = cmd[update:1000] echo "<span>$(date +"%I:%M %p %Z")</span>"
```

### Date Display

```conf
label {
    monitor =
    text = cmd[update:1000] echo -e "$(date +"%A, %B %d")"
    color = rgba(216, 222, 233, .75)
    font_size = 19
    font_family = SF Pro Display Bold
    position = 217, 175
    halign = left
    valign = center
}
```

**date +"%A, %B %d"** - Display like "Monday, January 11"

**Date Format Examples:**
```conf
# Short format (Jan 11)
text = cmd[update:1000] echo "$(date +"%b %d")"

# Full with year (Monday, January 11, 2026)
text = cmd[update:1000] echo "$(date +"%A, %B %d, %Y")"

# ISO format (2026-01-11)
text = cmd[update:1000] echo "$(date +"%Y-%m-%d")"
```

### Profile Photo

```conf
image {
    monitor =
    path = ~/.config/hypr/jabawack.jpg
    border_size = 2
    border_color = rgba(255, 255, 255, .75)
    size = 95
    rounding = 47
    rotate = 0
    reload_time = -1
    position = 270, 25
    halign = left
    valign = center
}
```

**Visual Result:**
```
┌──────────────────────────────────────┐
│ Welcome!           ╭─────────┓       │
│                    │ Photo   │       │
│                    │ 95×95px │       │
│ 14:30              ├─────────┤       │
│ Monday, Jan 11     │   2px   │       │
│                    │ border  │       │
│                    ├─────────┤       │
│                    ╰─────────╯       │
└──────────────────────────────────────┘
```

**Image Properties:**
- `size = 95` - 95×95 pixel image
- `rounding = 47` - Fully rounded (95/2 = circular)
- `border_size = 2` - 2px white border
- `rotate = 0` - No rotation
- `reload_time = -1` - Don't reload image

### User Label

```conf
label {
    monitor =
    text =     $USER
    color = rgba(216, 222, 233, 0.80)
    font_size = 16
    font_family = SF Pro Display Bold
    position = 275, -140
    halign = left
    valign = center
}
```

**$USER:** Variable showing username (e.g., "paolo")

### Input Field (Password)

```conf
input-field {
    monitor =
    size = 320, 55
    outline_thickness = 0
    dots_size = 0.2
    dots_spacing = 0.2
    dots_center = true
    outer_color = rgba(255, 255, 255, 0)
    inner_color = rgba(255, 255, 255, 0.1)
    font_color = rgb(200, 200, 200)
    fade_on_empty = false
    font_family = SF Pro Display Bold
    placeholder_text = <i><span foreground="##ffffff99">🔒  Enter Pass</span></i>
    hide_input = false
    position = 160, -220
    halign = left
    valign = center
}
```

**Input Field Features:**
- `size = 320, 55` - 320px wide, 55px tall box
- `dots_size = 0.2` - Placeholder dots (20% of field height)
- `dots_spacing = 0.2` - Space between dots
- `dots_center = true` - Center dots vertically
- `placeholder_text` - Shows before typing
- `hide_input = false` - Show dots as you type

**Customization Examples:**
```conf
# Hide password input (show nothing)
hide_input = true

# Hide dots, show asterisks instead
dots_size = 0        # Disable dots

# Different placeholder
placeholder_text = <span foreground="##888888">Unlock System</span>

# Larger input field
size = 400, 60
font_size = 18
```

### User Box (Rounded Rectangle)

```conf
shape {
    monitor =
    size = 320, 55
    color = rgba(255, 255, 255, .1)
    rounding = -1
    border_size = 0
    border_color = rgba(255, 255, 255, 1)
    rotate = 0
    xray = false
    position = 160, -140
    halign = left
    valign = center
}
```

**Purpose:** Background shape behind username

**Visual:**
```
┌─────────────────────────────────┐
│  Shape (semi-transparent white) │
│  ┌─────────────────────────────┐│
│  │  Username                    ││
│  └─────────────────────────────┘│
└─────────────────────────────────┘
```

**Properties:**
- `color = rgba(255, 255, 255, .1)` - 10% opaque white
- `rounding = -1` - Fully rounded (pill shape)
- `border_size = 0` - No border

---

## Advanced Customization Examples

### Change Theme Colors

```conf
# In general block - use purple instead of cyan/green
col.active_border = rgba(b08cffff) rgba(d8a8ffff) 45deg
col.inactive_border = rgba(808080ff)
```

### Disable All Animations (Performance)

```conf
animations {
    enabled = false
}
```

### Add Custom Workspace Names

```conf
# Use Super+Comma/Period to navigate
bind = $mainMod, comma, workspace, e-1
bind = $mainMod, period, workspace, e+1
```

### Change Default Programs

```conf
$terminal = alacritty
$fileManager = nautilus
$menu = wofi
$browser = chromium
```

---

## Troubleshooting Configuration

### Config Won't Load

```bash
# Check for syntax errors
hyprctl --help | grep reload

# Reload with verbose output
hyprctl reload
```

### Settings Not Applied

```bash
# Full restart Hyprland
killall Hyprland  # Then log back in

# Or use reload
hyprctl reload
```

### Monitor Resolution Issues

```bash
# List available resolutions
hyprctl monitors

# Verify monitor names
hyprctl monitors all
```

---

## Performance Tuning

### For AMD GPU (Shinkiro)

```conf
# These settings are already optimized:
- Animations enabled (AMD handles well)
- Blur enabled (minimal impact)
- Shadows enabled (negligible cost)
```

### For Lower-End Hardware

```conf
# Disable visual effects
animations { enabled = false }
decoration { blur { enabled = false } shadow { enabled = false } }

# Reduce animation counts
animation = global, 1, 2, linear
```

---

## Quick Reference

### Most Important Settings

| Setting | Current | Purpose |
|---------|---------|---------|
| `$terminal` | ghostty | Default terminal |
| `gaps_in` | 5px | Space between windows |
| `gaps_out` | 20px | Space from edges |
| `border_size` | 2px | Window border thickness |
| `layout` | dwindle | Tiling algorithm |
| `$mainMod` | SUPER | Main modifier key |
| `kb_layout` | gb | Keyboard layout |

### Most Important Keybindings

| Combo | Action |
|-------|--------|
| Super+Q | Open Terminal |
| Super+E | Open File Manager |
| Super+R | Open App Launcher |
| Super+C | Close Window |
| Super+Arrow | Move Focus |
| Super+1-9 | Switch Workspace |
| Super+Shift+1-9 | Move to Workspace |
| Super+V | Float/Tile |
| Super+L | Lock Screen |

---

**Last Updated:** January 2026  
**Hyprland Version:** v3  
**System:** Shinkiro (Dual 4K, AMD)
