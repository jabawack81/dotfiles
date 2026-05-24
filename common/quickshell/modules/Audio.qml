// Audio volume + mute via Pipewire. Click to toggle mute. Scroll to adjust volume.
// Reads the default sink, tracks volume %, and shows MUTE when muted.
import QtQuick
import Quickshell.Services.Pipewire
import "../"

MouseArea {
    id: root
    anchors.verticalCenter: parent.verticalCenter
    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton

    property var sink: Pipewire.defaultAudioSink
    property bool muted: sink && sink.audio ? sink.audio.muted : false
    property int volume: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0

    onClicked: if (sink && sink.audio) sink.audio.muted = !sink.audio.muted
    onWheel: function(wheel) {
        if (!sink || !sink.audio) return;
        const step = 0.02;
        const delta = wheel.angleDelta.y > 0 ? step : -step;
        sink.audio.volume = Math.max(0, Math.min(1, sink.audio.volume + delta));
    }

    // Keep sink tracked even if Pipewire reassigns it
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
            text: Theme.bracketL
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
        Text {
            text: root.muted ? "MUTE"
                             : "VOL " + String(root.volume).padStart(2, "0") + "%"
            color: root.muted ? Theme.critical
                              : (root.containsMouse ? Theme.highlight : Theme.text)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            Behavior on color { ColorAnimation { duration: 120 } }
        }
        Text {
            text: Theme.bracketR
            color: Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }
}
