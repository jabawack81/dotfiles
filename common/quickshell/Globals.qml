// Shared UI state across windows (bar ↔ dashboard popup).
pragma Singleton
import QtQuick

QtObject {
    property bool dashboardOpen: false
    property bool overviewOpen: false

    // Notification center state. History holds plain snapshots (not live
    // Notification objects, which go invalid after dismiss).
    property bool notificationCenterOpen: false
    property var notificationHistory: []   // [{ appName, summary, body, urgency, time }]

    function pushNotification(notif) {
        const snap = {
            appName: notif.appName || "notify",
            summary: notif.summary || "",
            body: notif.body || "",
            urgency: notif.urgency,
            time: Qt.formatDateTime(new Date(), "HH:mm"),
        };
        // Newest first, cap at 50 to bound memory.
        notificationHistory = [snap, ...notificationHistory].slice(0, 50);
    }

    function clearNotifications() {
        notificationHistory = [];
    }
}
