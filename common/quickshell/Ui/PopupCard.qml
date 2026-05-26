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
    property int padding: Style.spacing.lg
    property color borderColor: Color.popups.border
    // Direction the popup expands from the anchor's bottom edge. Default
    // Bottom|Left keeps right-side bar icons on-screen; use Bottom alone to
    // center the popup under a centered anchor (e.g. the clock).
    property int gravity: Edges.Bottom | Edges.Left
    default property alias cardContent: holder.data

    visible: false
    color: "transparent"
    implicitWidth: contentWidth
    implicitHeight: contentHeight

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: root.gravity

    // Native grab: keyboard focus + dismiss-on-outside-click. Constant `true`
    // (not bound to `visible`) — the grab only applies while the popup is
    // mapped, and a binding here can miss establishing the grab for popups
    // that hold keyboard focus (e.g. a search field).
    grabFocus: true
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
            anchors.margins: root.padding
        }
    }
}
