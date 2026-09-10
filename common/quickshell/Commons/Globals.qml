pragma Singleton
import QtQuick

// Shared UI state across windows (bar ↔ popups/panels).
QtObject {
    property bool overviewOpen: false
    property bool omniOpen: false
    // Keyboard cursor for the workspace overview (the id currently selected
    // via Tab/arrows, distinct from the active workspace).
    property int overviewSelectedId: -1

    // Notification center state. History holds plain snapshots (not live
    // Notification objects, which go invalid after dismiss).
    property var notificationHistory: []   // [{ appName, summary, body, urgency, time }]

    function pushNotification(notif) {
        const snap = {
            appName: notif.appName || "notify",
            summary: notif.summary || "",
            body: notif.body || "",
            urgency: notif.urgency,
            time: Qt.formatDateTime(new Date(), "HH:mm"),
        };
        notificationHistory = [snap, ...notificationHistory].slice(0, 50);
    }

    function clearNotifications() {
        notificationHistory = [];
    }

    // Do Not Disturb. Notifications are still received and logged to history
    // above; they just don't toast. Critical (urgency 2) still gets through.
    property bool doNotDisturb: false

    // Notifications suppressed by DND since the center was last opened — the
    // badge on the bell, so what was missed is visible at a glance.
    property int missedCount: 0

    function toggleDoNotDisturb() {
        doNotDisturb = !doNotDisturb;
    }
}
