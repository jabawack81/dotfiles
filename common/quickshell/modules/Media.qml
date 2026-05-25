// Media player widget via MPRIS. Shows ⏵/⏸ + scrolling track title.
// Click title toggles play/pause; ⏮ ⏭ skip. Hidden when no player is active.
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import "../"

Row {
    id: root
    spacing: 6
    anchors.verticalCenter: parent.verticalCenter
    visible: player !== null

    // Pick the first controllable player (prefer one that's actually playing).
    property var player: {
        let candidate = null;
        for (const p of Mpris.players.values) {
            if (!p.canControl) continue;
            if (p.isPlaying) return p;       // prefer the playing one
            if (!candidate) candidate = p;   // fall back to first controllable
        }
        return candidate;
    }

    property bool playing: player && player.isPlaying
    property string title: player ? (player.trackTitle || "Unknown") : ""
    property string artist: player ? (player.trackArtist || "") : ""

    // Play/pause toggle
    Text {
        text: root.playing ? "⏸" : "⏵"
        color: mpHover.containsMouse ? Theme.highlight : Theme.secondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        anchors.verticalCenter: parent.verticalCenter

        MouseArea {
            id: mpHover
            anchors.fill: parent
            hoverEnabled: true
            onClicked: if (root.player) root.player.togglePlaying()
        }
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    // Track title (clipped to keep the bar tidy)
    Text {
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, 240)
        elide: Text.ElideRight
        text: root.artist ? (root.artist + " — " + root.title) : root.title
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall

        MouseArea {
            anchors.fill: parent
            onClicked: if (root.player) root.player.togglePlaying()
        }
    }

    // Skip controls
    Text {
        visible: root.player && root.player.canGoPrevious
        text: "⏮"
        color: prevHover.containsMouse ? Theme.highlight : Theme.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        anchors.verticalCenter: parent.verticalCenter
        MouseArea {
            id: prevHover
            anchors.fill: parent
            hoverEnabled: true
            onClicked: if (root.player) root.player.previous()
        }
        Behavior on color { ColorAnimation { duration: 120 } }
    }
    Text {
        visible: root.player && root.player.canGoNext
        text: "⏭"
        color: nextHover.containsMouse ? Theme.highlight : Theme.textDim
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        anchors.verticalCenter: parent.verticalCenter
        MouseArea {
            id: nextHover
            anchors.fill: parent
            hoverEnabled: true
            onClicked: if (root.player) root.player.next()
        }
        Behavior on color { ColorAnimation { duration: 120 } }
    }
}
