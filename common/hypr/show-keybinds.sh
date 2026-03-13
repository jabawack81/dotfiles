#!/usr/bin/env bash
# Show all active Hyprland keybindings in fuzzel
# Dynamically reads from hyprctl so new bindings are always picked up

decode_modmask() {
    local mask=$1
    local mods=""
    (( mask & 64 )) && mods+="Super + "
    (( mask & 4 ))  && mods+="Ctrl + "
    (( mask & 1 ))  && mods+="Shift + "
    (( mask & 8 ))  && mods+="Alt + "
    echo "${mods% + }"
}

friendly_key() {
    local key=$1
    case "$key" in
        mouse:272)           echo "LMB" ;;
        mouse:273)           echo "RMB" ;;
        mouse_down)          echo "ScrollDown" ;;
        mouse_up)            echo "ScrollUp" ;;
        XF86AudioRaiseVolume) echo "Vol+" ;;
        XF86AudioLowerVolume) echo "Vol-" ;;
        XF86AudioMute)       echo "Mute" ;;
        XF86AudioMicMute)    echo "MicMute" ;;
        XF86AudioPlay)       echo "Play" ;;
        XF86AudioPause)      echo "Pause" ;;
        XF86AudioNext)       echo "Next" ;;
        XF86AudioPrev)       echo "Prev" ;;
        XF86AudioStop)       echo "Stop" ;;
        XF86MonBrightnessUp)   echo "Bright+" ;;
        XF86MonBrightnessDown) echo "Bright-" ;;
        *)                   echo "$key" ;;
    esac
}

friendly_description() {
    local dispatcher=$1
    local arg=$2
    case "$dispatcher" in
        exec)
            case "$arg" in
                *grimblast*copy\ area)   echo "Screenshot area → clipboard" ;;
                *grimblast*copy\ screen) echo "Screenshot screen → clipboard" ;;
                *grimblast*save\ area)   echo "Screenshot area → file" ;;
                *move-window-on-monitor*next) echo "Move window → next workspace (monitor)" ;;
                *move-window-on-monitor*prev) echo "Move window → prev workspace (monitor)" ;;
                *pamixer*-i*)    echo "Volume up" ;;
                *pamixer*-d*)    echo "Volume down" ;;
                *wpctl*SINK*)    echo "Toggle mute" ;;
                *wpctl*SOURCE*)  echo "Toggle mic mute" ;;
                *playerctl\ next)       echo "Media next" ;;
                *playerctl\ prev*)      echo "Media previous" ;;
                *playerctl\ play-pause) echo "Media play/pause" ;;
                *playerctl\ stop)       echo "Media stop" ;;
                *brightnessctl*+) echo "Brightness up" ;;
                *brightnessctl*-) echo "Brightness down" ;;
                *show-keybinds*)  echo "Show keybindings" ;;
                *hyprlock)        echo "Lock screen" ;;
                *)                echo "$arg" ;;
            esac ;;
        killactive)          echo "Close window" ;;
        exit)                echo "Exit Hyprland" ;;
        togglefloating)      echo "Toggle floating" ;;
        togglesplit)         echo "Toggle split (dwindle)" ;;
        pseudo)              echo "Pseudotile (dwindle)" ;;
        movefocus)
            case "$arg" in
                l) echo "Focus left" ;; r) echo "Focus right" ;;
                u) echo "Focus up" ;;   d) echo "Focus down" ;;
                *) echo "Focus $arg" ;;
            esac ;;
        workspace)
            case "$arg" in
                [0-9]|10)     echo "Workspace $arg" ;;
                e+1)          echo "Next workspace (scroll)" ;;
                e-1)          echo "Prev workspace (scroll)" ;;
                m+1)          echo "Next workspace (monitor)" ;;
                m-1)          echo "Prev workspace (monitor)" ;;
                emptym)       echo "New workspace (monitor)" ;;
                empty)        echo "New workspace" ;;
                special:*)    echo "Toggle ${arg#special:} scratchpad" ;;
                *)            echo "Workspace $arg" ;;
            esac ;;
        movetoworkspace)
            case "$arg" in
                [0-9]|10)     echo "Move window → workspace $arg" ;;
                special:*)    echo "Move window → ${arg#special:} scratchpad" ;;
                *)            echo "Move window → workspace $arg" ;;
            esac ;;
        movewindow)          echo "Move window (drag)" ;;
        resizewindow)        echo "Resize window (drag)" ;;
        togglespecialworkspace) echo "Toggle ${arg:-scratchpad} scratchpad" ;;
        *)
            if [[ -n "$arg" ]]; then
                echo "$dispatcher $arg"
            else
                echo "$dispatcher"
            fi ;;
    esac
}

# Parse bindings from hyprctl and format them
hyprctl binds -j | jq -r '.[] | "\(.modmask)|\(.key)|\(.dispatcher)|\(.arg)|\(.mouse)"' | while IFS='|' read -r modmask key dispatcher arg mouse; do
    mods=$(decode_modmask "$modmask")
    key=$(friendly_key "$key")
    desc=$(friendly_description "$dispatcher" "$arg")

    if [[ -n "$mods" ]]; then
        combo="$mods + $key"
    else
        combo="$key"
    fi

    printf "%-35s %s\n" "$combo" "$desc"
done | sort | fuzzel --dmenu --prompt="Keybindings > " --width=60 --lines=30 > /dev/null
