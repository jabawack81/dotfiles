// Omni menu — Spotlight/Raycast-style command palette (neon-glow design).
// Fuses installed apps (DesktopEntries) with system actions, fuzzy-scored
// against the query. Keyboard-first: type to filter, ↑↓ to move, Enter to
// run, Esc to close. Triggered by a Hyprland global shortcut:
//   bind = SUPER, SPACE, global, quickshell:omni
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons

Scope {
    id: scope

    property string query: ""
    property int selected: 0

    // System actions available alongside apps.
    readonly property var actions: [
        { name: "Lock screen", icon: "system-lock-screen", comment: "Lock with hyprlock", cmd: "hyprlock", kw: "lock secure" },
        { name: "Suspend",     icon: "system-suspend",      comment: "Sleep to RAM",       cmd: "systemctl suspend", kw: "sleep" },
        { name: "Hibernate",   icon: "system-suspend-hibernate", comment: "Sleep to disk", cmd: "systemctl hibernate", kw: "sleep" },
        { name: "Restart",     icon: "system-reboot",       comment: "Reboot the machine", cmd: "systemctl reboot", kw: "reboot restart" },
        { name: "Shutdown",    icon: "system-shutdown",     comment: "Power off",          cmd: "systemctl poweroff", kw: "power off poweroff" },
        { name: "Log out",     icon: "system-log-out",      comment: "Exit Hyprland",      cmd: "hyprctl dispatch exit", kw: "logout exit" },
    ]

    Process { id: runProc }

    // Score an item against the query. 0 = no match. Higher = better.
    function score(name, kw, q) {
        if (q === "") return 1;
        const n = name.toLowerCase();
        const k = (kw || "").toLowerCase();
        if (n.startsWith(q)) return 100 - n.length;
        const wi = n.indexOf(" " + q);
        if (wi >= 0) return 80 - n.length;
        if (n.includes(q)) return 60 - n.length;
        if (k.includes(q)) return 40;
        return 0;
    }

    // Evaluate a math expression. Returns a number string or null. Only allows
    // arithmetic chars (no identifiers) so eval can't run arbitrary code.
    function calcResult(raw) {
        const expr = raw.trim();
        if (!/[0-9]/.test(expr) || !/[-+*/%]/.test(expr)) return null;
        if (!/^[0-9+\-*/%.()\s]+$/.test(expr)) return null;
        try {
            const v = Function('"use strict";return (' + expr + ')')();
            if (typeof v === "number" && isFinite(v))
                return (Math.round(v * 1e6) / 1e6).toString();
        } catch (e) {}
        return null;
    }

    // Build the scored, sorted result list from apps, actions, and open windows.
    // A calculator result (when the query is an expression) is pinned on top.
    function results() {
        const q = scope.query.toLowerCase().trim();
        const out = [];

        // Calculator — pinned first
        const calc = calcResult(scope.query);
        if (calc !== null)
            out.push({ kind: "calc", name: calc, icon: "accessories-calculator",
                       comment: "= " + scope.query.trim() + "  ·  Enter to copy", value: calc, score: 1e6 });

        for (const app of DesktopEntries.applications.values) {
            if (app.noDisplay) continue;
            const kw = ((app.categories || []).join(" ") + " " + (app.keywords || []).join(" "));
            const s = score(app.name, kw, q);
            if (s > 0) out.push({ kind: "app", name: app.name, icon: app.icon,
                                  comment: app.comment || app.genericName || "Application",
                                  entry: app, score: s });
        }
        for (const a of scope.actions) {
            const s = score(a.name, a.kw, q);
            if (s > 0) out.push({ kind: "action", name: a.name, icon: a.icon,
                                  comment: a.comment, cmd: a.cmd, score: s });
        }
        // Open windows (focus on Enter)
        for (const w of Hyprland.toplevels.values) {
            const ipc = w.lastIpcObject || {};
            const title = w.title || ipc.title || ipc.class || "window";
            const cls = ipc.class || "";
            const s = score(title, cls + " window", q);
            if (s > 0) out.push({ kind: "window", name: title,
                                  icon: DesktopEntries.heuristicLookup(cls) ? DesktopEntries.heuristicLookup(cls).icon : cls,
                                  comment: "Window · " + cls, address: ipc.address, score: s - 5 });
        }

        out.sort((x, y) => y.score - x.score || x.name.localeCompare(y.name));
        return out.slice(0, 40);
    }

    property var items: results()
    onItemsChanged: if (selected >= items.length) selected = Math.max(0, items.length - 1)

    function run(item) {
        if (!item) return;
        switch (item.kind) {
            case "app":    item.entry.execute(); break;
            case "action": runProc.command = ["bash", "-c", item.cmd]; runProc.running = true; break;
            case "window": if (item.address) Hyprland.dispatch("focuswindow address:" + item.address); break;
            case "calc":   runProc.command = ["bash", "-c", "printf '%s' " + Util.shellQuote(item.value) + " | wl-copy"]; runProc.running = true; break;
        }
        Globals.omniOpen = false;
    }

    function open() {
        scope.query = "";
        scope.selected = 0;
        Globals.omniOpen = true;
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "omni"
        onPressed: Globals.omniOpen ? Globals.omniOpen = false : scope.open()
    }

    LazyLoader {
        active: Globals.omniOpen

        component: Variants {
            model: Quickshell.screens.slice(0, 1)

            PanelWindow {
                required property var modelData
                screen: modelData

                anchors { top: true; bottom: true; left: true; right: true }
                color: "#aa000000"   // dim backdrop
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

                // Click backdrop to close
                MouseArea { anchors.fill: parent; onClicked: Globals.omniOpen = false }

                // Faint accent grid backdrop (neon-glow signature)
                Item {
                    anchors.fill: parent
                    opacity: 0.5
                    Repeater {
                        model: Math.ceil(parent.height / 42)
                        Rectangle { y: index * 42; width: parent.width; height: 1; color: Color.accent; opacity: 0.04 }
                    }
                    Repeater {
                        model: Math.ceil(parent.width / 42)
                        Rectangle { x: index * 42; width: 1; height: parent.height; color: Color.accent; opacity: 0.04 }
                    }
                }

                // Focused key handler
                Item {
                    anchors.fill: parent
                    focus: true
                    Component.onCompleted: forceActiveFocus()

                    Keys.onPressed: function(event) {
                        switch (event.key) {
                            case Qt.Key_Escape: Globals.omniOpen = false; break;
                            case Qt.Key_Up:     scope.selected = Math.max(0, scope.selected - 1); break;
                            case Qt.Key_Down:   scope.selected = Math.min(scope.items.length - 1, scope.selected + 1); break;
                            case Qt.Key_Return:
                            case Qt.Key_Enter:  scope.run(scope.items[scope.selected]); break;
                            case Qt.Key_Backspace:
                                scope.query = scope.query.slice(0, -1); scope.selected = 0; break;
                            default:
                                if (event.text && event.text.length === 1 && event.text >= " ") {
                                    scope.query += event.text; scope.selected = 0;
                                } else { return; }
                        }
                        event.accepted = true;
                    }

                    // ── Neon-glow card ──────────────────────────────────────
                    Rectangle {
                        anchors.centerIn: parent
                        width: Math.min(880, parent.width - 80)
                        height: 520
                        radius: 14
                        color: "#0b1016"
                        border.color: Color.accent
                        border.width: 1
                        // layered outer glow
                        Rectangle {
                            anchors.fill: parent; anchors.margins: -3; z: -1
                            radius: parent.radius + 3; color: "transparent"
                            border.color: Color.accent; border.width: 2; opacity: 0.18
                        }

                        Column {
                            anchors.fill: parent

                            // Search row
                            Item {
                                width: parent.width; height: 64
                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 30; anchors.rightMargin: 30
                                    spacing: 14
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "⌕"; color: Color.accent; font.family: Style.font.family; font.pixelSize: 22
                                    }
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 120
                                        text: scope.query === "" ? "Search apps and actions…" : scope.query
                                        color: scope.query === "" ? Color.textDim : Color.foreground
                                        font.family: Style.font.family; font.pixelSize: 19
                                        elide: Text.ElideRight
                                    }
                                    Rectangle {  // caret
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 2; height: 22; color: Color.highlight
                                        SequentialAnimation on opacity {
                                            loops: Animation.Infinite
                                            NumberAnimation { to: 0; duration: 500 }
                                            NumberAnimation { to: 1; duration: 500 }
                                        }
                                    }
                                }
                            }

                            // gradient separator
                            Rectangle {
                                width: parent.width; height: 1
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: "transparent" }
                                    GradientStop { position: 0.5; color: Color.accent }
                                    GradientStop { position: 1.0; color: "transparent" }
                                }
                            }

                            // Quick-stats dashboard — shown when the query is empty.
                            QuickStats {
                                visible: scope.query === ""
                                width: parent.width - 76
                                height: parent.height - 64 - 1 - 44
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            // Body: results + preview (shown once you type)
                            Row {
                                visible: scope.query !== ""
                                width: parent.width
                                height: parent.height - 64 - 1 - 44

                                // Results list
                                ListView {
                                    id: list
                                    width: parent.width * 0.58
                                    height: parent.height
                                    clip: true
                                    model: scope.items
                                    currentIndex: scope.selected
                                    boundsBehavior: Flickable.StopAtBounds

                                    delegate: Rectangle {
                                        required property var modelData
                                        required property int index
                                        width: ListView.view.width
                                        height: 52
                                        property bool sel: index === scope.selected
                                        color: sel ? "#16334a" : "transparent"

                                        // selected accent bar
                                        Rectangle {
                                            visible: parent.sel
                                            width: 2; height: parent.height; color: Color.accent
                                        }

                                        Row {
                                            anchors.fill: parent
                                            anchors.leftMargin: 16; anchors.rightMargin: 16
                                            spacing: 14

                                            Rectangle {  // icon chip
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 34; height: 34; radius: 9
                                                color: parent.parent.sel ? "#0e2a1f" : "#101820"
                                                border.color: parent.parent.sel ? Color.secondary : "#1d3340"
                                                border.width: 1
                                                Image {
                                                    anchors.centerIn: parent
                                                    width: 20; height: 20; sourceSize.width: 20; sourceSize.height: 20
                                                    source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                                                    smooth: true
                                                }
                                            }
                                            Column {
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: parent.width - 110
                                                spacing: 2
                                                Text {
                                                    text: modelData.name
                                                    color: parent.parent.parent.sel ? Color.accent : Color.foreground
                                                    font.family: Style.font.family; font.pixelSize: 15
                                                    elide: Text.ElideRight; width: parent.width
                                                }
                                                Text {
                                                    text: modelData.comment
                                                    color: Color.textDim
                                                    font.family: Style.font.family; font.pixelSize: 11
                                                    elide: Text.ElideRight; width: parent.width
                                                }
                                            }
                                            Text {
                                                anchors.verticalCenter: parent.verticalCenter
                                                text: modelData.kind === "action" ? "PWR" : "APP"
                                                color: Color.textDim; font.family: Style.font.family; font.pixelSize: 10
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onEntered: scope.selected = index
                                            onClicked: scope.run(modelData)
                                        }
                                    }
                                }

                                // vertical divider
                                Rectangle { width: 1; height: parent.height; color: "#13202a" }

                                // Preview pane
                                Item {
                                    width: parent.width * 0.42 - 1
                                    height: parent.height
                                    property var cur: scope.items[scope.selected] || null

                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 24
                                        spacing: 16
                                        visible: parent.cur !== null

                                        Rectangle {
                                            width: 74; height: 74; radius: 16
                                            color: "#0e2a1f"; border.color: Color.secondary; border.width: 1
                                            Image {
                                                anchors.centerIn: parent
                                                width: 40; height: 40; sourceSize.width: 40; sourceSize.height: 40
                                                source: parent.parent.parent.cur
                                                    ? Quickshell.iconPath(parent.parent.parent.cur.icon, "application-x-executable") : ""
                                                smooth: true
                                            }
                                        }
                                        Text {
                                            text: parent.parent.cur ? parent.parent.cur.name : ""
                                            color: Color.foreground; font.family: Style.font.family; font.pixelSize: 22
                                            elide: Text.ElideRight; width: parent.width
                                        }
                                        Text {
                                            text: parent.parent.cur
                                                ? (parent.parent.cur.kind === "action" ? "SYSTEM ACTION" : "APPLICATION")
                                                : ""
                                            color: Color.accent; font.family: Style.font.family; font.pixelSize: 11
                                        }
                                        Text {
                                            text: parent.parent.cur ? parent.parent.cur.comment : ""
                                            color: Color.textDim; font.family: Style.font.family; font.pixelSize: 13
                                            wrapMode: Text.WordWrap; width: parent.width
                                        }
                                    }
                                }
                            }

                            // Footer
                            Rectangle {
                                width: parent.width; height: 44
                                color: "#070b0f"
                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 30; anchors.rightMargin: 30
                                    spacing: 22
                                    Text { anchors.verticalCenter: parent.verticalCenter; text: "↑↓ move"; color: Color.textDim; font.family: Style.font.family; font.pixelSize: 11 }
                                    Text { anchors.verticalCenter: parent.verticalCenter; text: "⏎ run"; color: Color.textDim; font.family: Style.font.family; font.pixelSize: 11 }
                                    Item { width: 1; height: 1 }
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.right: parent.right; anchors.rightMargin: 30
                                    text: scope.query === "" ? "system · type to search · esc"
                                                             : scope.items.length + " results · esc"
                                    color: Color.highlight; font.family: Style.font.family; font.pixelSize: 11
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
