// System tray — StatusNotifierItem icons for background apps.
// The first `maxInline` items render as icons in the bar; any extras collapse
// into an overflow dropdown (⋯N) so a busy tray can't stretch the island over
// the centre clock. Left-click activates; right-click opens the app's DBusMenu.
//
// Two robustness measures:
//  1. Slices are identity-stable (replaced only when the item set in a slice
//     actually changes) so the Repeaters don't rebuild delegates — and lose
//     hover state — on every unrelated tray property update.
//  2. A SINGLE shared TrayMenu serves every icon/row, re-anchored on demand,
//     and any already-open popup is closed (with a deferred reopen) before the
//     menu shows — so two xdg-popup grabs never stack on Wayland.
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.Commons
import qs.Ui

Row {
    id: root
    spacing: 8
    anchors.verticalCenter: parent.verticalCenter

    property int maxInline: 3

    // ── Identity-stable slices ────────────────────────────────────────
    property var inlineItems: []
    property var overflowItems: []

    function sameRefs(a, b) {
        if (a.length !== b.length) return false;
        for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return false;
        return true;
    }
    function rebuild() {
        const v = SystemTray.items.values || [];
        const ni = v.slice(0, maxInline);
        const no = v.slice(maxInline);
        if (!sameRefs(inlineItems, ni)) inlineItems = ni;
        if (!sameRefs(overflowItems, no)) overflowItems = no;
        // Don't leave an orphaned dropdown/menu when items disappear.
        if (no.length === 0) overflowPopup.visible = false;
        if (menuItem && v.indexOf(menuItem) === -1) sharedMenu.visible = false;
    }
    Component.onCompleted: rebuild()
    Connections {
        target: SystemTray.items
        function onValuesChanged() { root.rebuild(); }
    }

    // ── Single shared DBusMenu ────────────────────────────────────────
    property var menuItem: null
    property Item menuAnchor: null
    Timer { id: menuDelay; interval: 60; onTriggered: sharedMenu.visible = true }

    // Open `item`'s menu anchored under `anchorEl`. If any popup is already
    // grabbing, close it and defer the open so grabs never stack.
    function openMenu(item, anchorEl) {
        root.menuItem = item;
        root.menuAnchor = anchorEl;
        const busy = overflowPopup.visible || sharedMenu.visible || menuDelay.running;
        overflowPopup.visible = false;
        if (busy) { sharedMenu.visible = false; menuDelay.restart(); }
        else sharedMenu.visible = true;
    }

    TrayMenu { id: sharedMenu; item: root.menuItem; anchorItem: root.menuAnchor }

    // ── Inline icons (first maxInline) ────────────────────────────────
    Repeater {
        model: root.inlineItems

        delegate: MouseArea {
            id: trayItem
            required property var modelData
            property bool hovered: containsMouse

            implicitWidth: Style.font.base + 4
            implicitHeight: Style.font.base + 4
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            anchors.verticalCenter: parent.verticalCenter

            onClicked: function(mouse) {
                if (mouse.button === Qt.LeftButton) modelData.activate();
                else if (modelData.hasMenu) root.openMenu(modelData, trayItem);
                else modelData.secondaryActivate();
            }

            Image {
                anchors.centerIn: parent
                source: modelData.icon
                sourceSize.width: 20; sourceSize.height: 20
                width: 18; height: 18; smooth: true
                opacity: parent.hovered ? 1.0 : 0.85
                Behavior on opacity { NumberAnimation { duration: 120 } }
            }
        }
    }

    // ── Overflow toggle + dropdown ────────────────────────────────────
    MouseArea {
        id: overflowBtn
        visible: root.overflowItems.length > 0
        width: visible ? ovText.implicitWidth + 4 : 0
        implicitHeight: Style.font.base + 4
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        anchors.verticalCenter: parent.verticalCenter
        onClicked: overflowPopup.toggle()

        BarText {
            id: ovText
            anchors.centerIn: parent
            text: "⋯" + root.overflowItems.length
            color: overflowBtn.containsMouse || overflowPopup.visible ? Color.highlight : Color.textDim
            Behavior on color { ColorAnimation { duration: 120 } }
        }

        PopupCard {
            id: overflowPopup
            anchorItem: overflowBtn
            padding: 6
            contentWidth: 240
            contentHeight: ovCol.implicitHeight + 12

            Column {
                id: ovCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                spacing: 2

                Repeater {
                    model: root.overflowItems

                    delegate: MouseArea {
                        id: ovRow
                        required property var modelData
                        width: ovCol.width
                        height: 34
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onClicked: function(mouse) {
                            if (mouse.button === Qt.RightButton) {
                                if (modelData.hasMenu) root.openMenu(modelData, overflowBtn);
                                else modelData.secondaryActivate();
                            } else if (modelData.onlyMenu && modelData.hasMenu) {
                                root.openMenu(modelData, overflowBtn);
                            } else {
                                modelData.activate();
                                overflowPopup.visible = false;
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: Style.cornerRadius
                            color: ovRow.containsMouse ? Color.surfaceInactive : "transparent"
                        }

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10

                            Image {
                                anchors.verticalCenter: parent.verticalCenter
                                source: ovRow.modelData.icon
                                sourceSize.width: 18; sourceSize.height: 18
                                width: 18; height: 18; smooth: true
                            }
                            BarText {
                                small: true
                                anchors.verticalCenter: parent.verticalCenter
                                width: ovCol.width - 52
                                text: ovRow.modelData.tooltipTitle || ovRow.modelData.title
                                      || ovRow.modelData.id || "tray item"
                                color: ovRow.containsMouse ? Color.highlight : Color.foreground
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}
