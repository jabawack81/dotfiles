-- Barbatos (ThinkPad T470p) specific Hyprland configuration
--
-- Intel HD 630 drives the panel; the NVIDIA 940MX is only reached through
-- `prime-run` (EnvyControl hybrid). See tasks/barbatos.yml for the
-- driver, suspend hook and fingerprint setup this config leans on.

local common  = require("~/.config/hypr_common/common")
local mainMod = common.mainMod
local D       = common.D

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })

-- Dock monitors (BenQ EL2870U) show up as DP-4 / DP-5. Force 1080p60: the
-- panel is 4K but the 940MX can't push 4K smoothly and `preferred` picks
-- 4K@30Hz, which is worse than 1080p60 on this GPU.
hl.monitor({ output = "DP-4", mode = "1920x1080@60", position = "auto", scale = 1 })
hl.monitor({ output = "DP-5", mode = "1920x1080@60", position = "auto", scale = 1 })

-- Anything else: EDID preferred mode
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

hl.env("GDK_SCALE", "1")

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("~/.config/scripts/bar-launcher.sh")
    -- Power state via caffeine-toggle.sh (normal → caffeine → remote →
    -- hibernate, cycled from the bar). Same scheme as shinkiro, with a laptop
    -- twist: on mains start in "remote" (short lock timers, never suspends,
    -- stays reachable over tailscale); on battery start in "normal" so an
    -- unplugged, forgotten laptop still suspends after 30 min.
    hl.exec_cmd('sh -c \'[ "$(cat /sys/class/power_supply/AC/online)" = 1 ] && s=remote || s=normal; ~/.config/waybar_common/caffeine-toggle.sh "$s"\'')
    -- Lid switch binds only fire on transitions; if the machine boots with
    -- the lid closed (docked) nothing would disable eDP-1. Apply the current
    -- state once at startup.
    hl.exec_cmd("~/.config/hypr/lid.sh init")
    -- Clipboard history capture for the quickshell clipboard module
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

------------------
---- NVIDIA ----
------------------

-- Software cursors: hardware cursors glitch on NVIDIA under Wayland.
hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})

-- Deliberately NOT set globally: NVD_BACKEND, LIBVA_DRIVER_NAME=nvidia and
-- __GLX_VENDOR_LIBRARY_NAME=nvidia. In hybrid mode Intel owns the desktop and
-- forcing every GL/VA client onto the 940MX is pointless (and, when
-- the driver isn't loaded, garbles GTK fonts — the Feb-2026 bug). Use
-- `prime-run <app>` for the odd program that should run on the dGPU.

---------------
---- INPUT ----
---------------

-- US keyboard on this ThinkPad (common.lua defaults to gb); Caps Lock is the
-- compose key.
hl.config({
    input = {
        kb_layout          = "us",
        kb_options         = "compose:caps",
        repeat_rate        = 40,
        repeat_delay       = 600,
        numlock_by_default = true,

        touchpad = {
            scroll_factor = 0.4,
        },
    },
})

-- Terminals scroll too slowly at the global touchpad factor; ghostty too fast.
hl.window_rule({
    name  = "touchpad-scroll-terminals",
    match = { class = "^(Alacritty|kitty|foot)$" },

    scroll_touchpad = 1.5,
})
hl.window_rule({
    name  = "touchpad-scroll-ghostty",
    match = { class = "^com\\.mitchellh\\.ghostty$" },

    scroll_touchpad = 0.2,
})

--------------------
---- LID SWITCH ----
--------------------

-- Closing the lid turns off the panel (external monitors stay up) and stops
-- the fingerprint daemon so a docked laptop doesn't keep polling a sensor
-- nobody can reach. lid.sh needs the sudoers drop-in from tasks/barbatos.yml.
hl.bind("switch:on:Lid Switch",  hl.dsp.exec_cmd("~/.config/hypr/lid.sh closed"), { locked = true, description = "Lid closed" })
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("~/.config/hypr/lid.sh open"),   { locked = true, description = "Lid opened" })

----------------------
---- WINDOW RULES ----
----------------------

-- The GPU / fan TUIs launched from the waybar modules get a roomy floating
-- window. Class names are set by `ghostty --class=...` in config-machine.jsonc.
for _, class in ipairs({ "envy-tui", "thinkfan-tui" }) do
    hl.window_rule({
        name  = "float-" .. class,
        match = { class = "^" .. class .. "$" },

        float  = true,
        center = true,
        size   = "1100 700",
    })
end

---------------------
---- KEYBINDINGS ----
---------------------

-- Super+N is bound per machine rather than in common.lua; this is the plain
-- single-monitor behaviour. See the note in common.lua for why.
hl.bind(mainMod .. " + N", hl.dsp.focus({ workspace = "emptym" }), D "New workspace (monitor)")

-- Move window to next/prev workspace on the same monitor (shinkiro parity;
-- shinkiro needs a script for its odd/even split, here plain m+1/m-1 will do)
hl.bind(mainMod .. " + CTRL + SHIFT + right", hl.dsp.window.move({ workspace = "m+1" }), D "Move window to next workspace (monitor)")
hl.bind(mainMod .. " + CTRL + SHIFT + left",  hl.dsp.window.move({ workspace = "m-1" }), D "Move window to prev workspace (monitor)")
