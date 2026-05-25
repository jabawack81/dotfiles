// Shared UI state across windows (bar ↔ dashboard popup).
pragma Singleton
import QtQuick

QtObject {
    property bool dashboardOpen: false
}
