-- Kyrios (Laptop) specific Hyprland configuration

local common  = require("~/.config/hypr_common/common")
local mainMod = common.mainMod
local D       = common.D

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "eDP-1", mode = "1920x1080@60.02", position = "0x0", scale = 1 })

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("~/.config/waybar/waybar-launcher.sh & dunst")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("hypridle")
    -- hl.exec_cmd("blueman-applet")
    -- hl.exec_cmd("pasystray")
end)

-------------------------
---- LAPTOP SPECIFIC ----
-------------------------

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------

-- Super+N is bound per machine rather than in common.lua; this is the plain
-- single-monitor behaviour. See the note in common.lua for why.
hl.bind(mainMod .. " + N", hl.dsp.focus({ workspace = "emptym" }), D "New workspace (monitor)")
