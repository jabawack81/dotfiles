import QtQuick
import Quickshell
import qs.Commons

// Reusable popup anchored under a bar item. Uses the native xdg-popup grab
// (grabFocus) so it takes keyboard focus for search fields and dismisses on
// outside click. Renders a bordered cyberpunk card; callers drop content
// straight inside (default property).
//
//   PopupCard {
//       anchorItem: someBarIcon
//       open: someBarIcon.menuOpen
//       contentWidth: 360; contentHeight: 460
//       Column { ... }
//   }
PopupWindow {
    id: root

    required property Item anchorItem
    property int contentWidth: 240
    property int contentHeight: 200
    property color borderColor: Color.popups.border
    default property alias cardContent: holder.data

    visible: false
    color: "transparent"
    implicitWidth: contentWidth
    implicitHeight: contentHeight

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom | Edges.Left

    // Native grab: keyboard focus + dismiss-on-outside-click.
    grabFocus: visible
    onClosed: root.visible = false

    function toggle() { root.visible = !root.visible; }

    Rectangle {
        anchors.fill: parent
        color: Color.popups.background
        border.color: root.borderColor
        border.width: 1
        radius: Style.cornerRadius

        Item {
            id: holder
            anchors.fill: parent
            anchors.margins: Style.spacing.lg
        }
    }
}
