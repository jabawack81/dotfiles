-- Common Hyprland configuration shared between all machines.
--
-- Lua config format, introduced in Hyprland 0.56. The old hyprlang `.conf`
-- format is deprecated and support for it is removed in 0.57.
--
-- Loaded by each machine's hyprland.lua via:
--     local common = require("~/.config/hypr_common/common")
--
-- The returned table exposes the program names, the main modifier and the D()
-- description helper, for machine configs to reuse.

local M = {}

---------------------
---- MY PROGRAMS ----
---------------------

M.terminal    = "ghostty"
M.fileManager = "thunar"
M.browser     = "firefox"

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 20,

        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before turning this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,

        -- Transparency of focused and unfocused windows
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true, -- Required for the togglesplit layout message to work
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
    },
})

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1.0 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },    { 0.1, 1 } } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout = "gb",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
M.mainMod = mainMod

-- Bind-options helper: `D "text"` attaches a description, which is what
-- hyprctl binds reports and show-keybinds.sh renders. Under the Lua config
-- every bind's dispatcher is the opaque "__lua", so without a description
-- the Super+K cheat sheet has nothing to show.
local function D(text) return { description = text } end
M.D = D

-- Keys aligned with Omarchy (lupus) idioms for cross-machine muscle memory.
hl.bind(mainMod .. " + W",         hl.dsp.window.close(),                      D "Close window")           -- was Super+C
hl.bind(mainMod .. " + D",         hl.dsp.exec_cmd("discord"),                 D "Discord")
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(M.fileManager),             D "File manager")           -- was Super+E
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd(M.browser),                 D "Browser")                -- was Super+F
hl.bind(mainMod .. " + G",         hl.dsp.exec_cmd("steam"),                   D "Steam")
hl.bind(mainMod .. " + J",         hl.dsp.layout("togglesplit"),               D "Toggle split (dwindle)")
hl.bind(mainMod .. " + M",         hl.dsp.exit(),                              D "Exit Hyprland")
hl.bind(mainMod .. " + P",         hl.dsp.window.pseudo(),                     D "Pseudotile (dwindle)")
hl.bind(mainMod .. " + Return",    hl.dsp.exec_cmd(M.terminal),                D "Terminal")               -- was Super+Q
hl.bind(mainMod .. " + T",         hl.dsp.window.float({ action = "toggle" }), D "Toggle floating")        -- was Super+V
hl.bind(mainMod .. " + CTRL + L",  hl.dsp.exec_cmd("hyprlock"),                D "Lock screen")            -- Super+L left free
-- App launcher: Super+Space opens quickshell:omni (see global binds below).

-- Screenshots (grimblast)
hl.bind("Print",               hl.dsp.exec_cmd("grimblast --notify copy area"),   D "Screenshot area to clipboard")
hl.bind("SHIFT + Print",       hl.dsp.exec_cmd("grimblast --notify copy screen"), D "Screenshot screen to clipboard")
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("grimblast --notify save area"),   D "Screenshot area to file")

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }),  D "Focus left")
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }), D "Focus right")
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }),    D "Focus up")
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }),  D "Focus down")

-- Switch workspaces with mainMod + [0-9], move the active window with SHIFT
for i = 1, 10 do
    local key = i % 10 -- workspace 10 lives on key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }),            D("Workspace " .. i))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }),      D("Move window to workspace " .. i))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"),          D "Toggle magic scratchpad")
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }), D "Move window to magic scratchpad")

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), D "Next workspace (scroll)")
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), D "Prev workspace (scroll)")

-- Cycle workspaces on the current monitor only
hl.bind(mainMod .. " + CTRL + right",      hl.dsp.focus({ workspace = "m+1" }), D "Next workspace (monitor)")
hl.bind(mainMod .. " + CTRL + left",       hl.dsp.focus({ workspace = "m-1" }), D "Prev workspace (monitor)")
hl.bind(mainMod .. " + CTRL + mouse_down", hl.dsp.focus({ workspace = "m+1" }), D "Next workspace (monitor)")
hl.bind(mainMod .. " + CTRL + mouse_up",   hl.dsp.focus({ workspace = "m-1" }), D "Prev workspace (monitor)")

-- Move the current workspace to another monitor (Omarchy parity)
hl.bind(mainMod .. " + SHIFT + ALT + left",  hl.dsp.workspace.move({ monitor = "l" }), D "Move workspace to monitor left")
hl.bind(mainMod .. " + SHIFT + ALT + right", hl.dsp.workspace.move({ monitor = "r" }), D "Move workspace to monitor right")
hl.bind(mainMod .. " + SHIFT + ALT + up",    hl.dsp.workspace.move({ monitor = "u" }), D "Move workspace to monitor up")
hl.bind(mainMod .. " + SHIFT + ALT + down",  hl.dsp.workspace.move({ monitor = "d" }), D "Move workspace to monitor down")

-- Resize the active window from the keyboard (Omarchy parity).
-- Super + [ / ] shrink/grow horizontally; add Shift for vertical.
hl.bind(mainMod .. " + bracketleft",          hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true, description = "Shrink window horizontally" })
hl.bind(mainMod .. " + bracketright",         hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true, description = "Grow window horizontally" })
hl.bind(mainMod .. " + SHIFT + bracketleft",  hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true, description = "Shrink window vertically" })
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true, description = "Grow window vertically" })

-- Super+N (new empty workspace) is bound per machine, not here: shinkiro needs
-- a parity-aware script for its odd/even dual-monitor split, kyrios just wants
-- plain emptym. Binding it centrally and unbinding it per host also worked,
-- but binding it directly in each host is simpler.

-- Show keybinding cheat sheet (Super+K, aligned with Omarchy)
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd("~/.config/hypr_common/show-keybinds.sh"), D "Show keybindings")

-- Toggle status bar between waybar and quickshell
-- (moved off Super+Shift+B, which is now the browser)
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("~/.config/scripts/bar-switch.sh toggle"), D "Toggle status bar")

-- Quickshell workspace overview / omni menu (no-op when quickshell isn't running)
hl.bind(mainMod .. " + TAB",       hl.dsp.global("quickshell:overview"), D "Workspace overview")
hl.bind(mainMod .. " + Space",     hl.dsp.global("quickshell:omni"),     D "App launcher / command palette")
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.global("quickshell:dnd"),      D "Toggle Do Not Disturb")

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   D "Move window (drag)")
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), D "Resize window (drag)")

-- Multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("pamixer -i 5"),                                 { locked = true, repeating = true, description = "Volume up" })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("pamixer -d 5"),                                 { locked = true, repeating = true, description = "Volume down" })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),   { locked = true, repeating = true, description = "Toggle mute" })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true, description = "Toggle mic mute" })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"),                         { locked = true, repeating = true, description = "Brightness up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"),                         { locked = true, repeating = true, description = "Brightness down" })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true, description = "Media next" })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Media play/pause" })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Media play/pause" })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true, description = "Media previous" })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Ignore maximize requests from apps
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

return M
