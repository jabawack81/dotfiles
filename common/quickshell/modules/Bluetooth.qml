// Bluetooth indicator via Quickshell's native BlueZ bindings (no polling).
// Shows BT OFF / BT ON / BT · <device> (or BT · N with several connected).
// Hidden when the machine has no adapter or bluetoothd isn't running.
// Left-click toggles power, right-click opens bluetui for pairing.
import QtQuick
import Quickshell
import Quickshell.Bluetooth as QsBt
import qs.Commons
import qs.Ui

BarPill {
    id: root

    readonly property var adapter: QsBt.Bluetooth.defaultAdapter
    readonly property bool powered: adapter !== null && adapter.enabled
    readonly property var connected: adapter
        ? adapter.devices.values.filter(d => d.connected)
        : []

    visible: adapter !== null

    content: {
        if (!powered) return "BT OFF";
        if (connected.length === 0) return "BT ON";
        if (connected.length > 1) return "BT · " + connected.length;
        // Cap the name so a long headset name can't stretch the island.
        const name = connected[0].name || "DEVICE";
        return "BT · " + (name.length > 16 ? name.slice(0, 15) + "…" : name);
    }
    baseColor: {
        if (!powered) return Colors.textDim;
        if (connected.length > 0) return Colors.accent;
        return Colors.foreground;
    }

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: function(mouse) {
        if (mouse.button === Qt.RightButton)
            Quickshell.execDetached(["ghostty", "-e", "bluetui"]);
        else if (adapter)
            adapter.enabled = !adapter.enabled;
    }

    ToolTip {
        anchorItem: root
        show: root.containsMouse
        contentWidth: 260
        contentHeight: tipCol.implicitHeight + Style.spacing.md * 2

        Column {
            id: tipCol
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 4

            BarText {
                small: true
                text: root.connected.length > 0 ? "CONNECTED" : "NO DEVICES CONNECTED"
                color: Colors.accentDim
            }

            Repeater {
                model: root.connected
                delegate: BarText {
                    required property var modelData
                    small: true
                    text: "󰂱 " + modelData.name
                        + (modelData.batteryAvailable ? "  " + Math.round(modelData.battery * 100) + "%" : "")
                    color: Colors.foreground
                }
            }

            Item { width: 1; height: 2 }

            BarText {
                small: true
                text: "L-click: power · R-click: bluetui"
                color: Colors.accentDim
            }
        }
    }
}
