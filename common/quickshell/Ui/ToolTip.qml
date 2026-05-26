// Passive hover tooltip anchored under a bar item. No focus grab (it's an
// overlay, not interactive). `show` is driven by the owner's hover state;
// a short delay avoids flicker on quick passes.
import QtQuick
import Quickshell
import qs.Commons

PopupWindow {
    id: root

    required property Item anchorItem
    property bool show: false
    property int contentWidth: 260
    property int contentHeight: 120
    default property alias body: holder.data

    color: "transparent"
    implicitWidth: contentWidth
    implicitHeight: contentHeight

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom | Edges.Left

    visible: false
    onShowChanged: {
        if (show) delayTimer.restart();
        else { delayTimer.stop(); visible = false; }
    }

    Timer {
        id: delayTimer
        interval: 350
        onTriggered: root.visible = true
    }

    Rectangle {
        anchors.fill: parent
        color: Color.popups.background
        border.color: Color.popups.border
        border.width: 1
        radius: Style.cornerRadius

        Item {
            id: holder
            anchors.fill: parent
            anchors.margins: Style.spacing.md
        }
    }
}
