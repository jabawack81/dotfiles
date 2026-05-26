// Audio volume + mute via Pipewire. Click to toggle mute. Scroll to adjust.
// Renders as a BarPill: [ VOL 65% ] / [ MUTE ].
import QtQuick
import Quickshell.Services.Pipewire
import qs.Commons
import qs.Ui

BarPill {
    id: root

    property var sink: Pipewire.defaultAudioSink
    property bool muted: sink && sink.audio ? sink.audio.muted : false
    property int volume: sink && sink.audio ? Math.round(sink.audio.volume * 100) : 0

    content: muted ? "MUTE" : "VOL " + String(volume).padStart(2, "0") + "%"
    baseColor: muted ? Color.urgent : Color.foreground

    acceptedButtons: Qt.LeftButton
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
}
