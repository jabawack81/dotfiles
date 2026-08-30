-- Shinkiro (Desktop PC) specific Hyprland configuration

local common  = require("~/.config/hypr_common/common")
local mainMod = common.mainMod
local D       = common.D

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "DP-2", mode = "3840x2160@59.99700", position = "0x0",    scale = 1.50 })
hl.monitor({ output = "DP-3", mode = "3840x2160@59.99700", position = "2560x0", scale = 1.50 })

--------------------
---- WORKSPACES ----
--------------------

-- Odd workspaces on the left monitor (DP-2), even on the right (DP-3).
-- Static rules for 1-10 (Super+key bindings); move-window-on-monitor.sh
-- handles placement dynamically for workspaces beyond 10.
for i = 1, 10 do
    hl.workspace_rule({
        workspace = tostring(i),
        monitor   = (i % 2 == 1) and "DP-2" or "DP-3",
    })
end

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("~/.config/scripts/bar-launcher.sh")
    -- Start hypridle in "remote" mode: short idle timers but no suspend, so
    -- the machine stays reachable over the network. The bar can still cycle
    -- states from here; the state file lives in tmpfs and does not persist.
    hl.exec_cmd("~/.config/waybar_common/caffeine-toggle.sh remote")
    hl.exec_cmd("xhost +si:localuser:root")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("~/.local/bin/cycle-wallpaper.sh")
    -- Clipboard history capture (text + images) for the quickshell clipboard module
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-------------------------------
---- DESKTOP SPECIFIC VARS ----
-------------------------------

hl.env("QT_QPA_PLATFORMTHEME", "qt5ct") -- change to qt6ct if you have that

--------------------------------------
---- DUAL-MONITOR WORKSPACE BINDS ----
--------------------------------------

-- Move window to next/prev workspace on the same monitor (Super+Ctrl+Shift+Arrow)
hl.bind(mainMod .. " + CTRL + SHIFT + right", hl.dsp.exec_cmd("~/.config/hypr/move-window-on-monitor.sh next"), D "Move window to next workspace (monitor)")
hl.bind(mainMod .. " + CTRL + SHIFT + left",  hl.dsp.exec_cmd("~/.config/hypr/move-window-on-monitor.sh prev"), D "Move window to prev workspace (monitor)")

-- Super+N: next free workspace with the correct parity for the focused
-- monitor (odd on DP-2, even on DP-3).
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("~/.config/hypr/new-workspace-on-monitor.sh"), D "New workspace (monitor, parity-aware)")

------------------------------
---- MEDIA KEY BINDINGS   ----
------------------------------

-- Additional media key for Stop (not in the common config).
-- Volume slider, mute, play/pause, prev and next all live in common.lua.
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true, description = "Media stop" })
