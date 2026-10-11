// Bracketed section header used in panels: [ TITLE ]
import QtQuick
import qs.Commons

Text {
    property string title: ""
    text: "[ " + title + " ]"
    color: Colors.secondary
    font.family: Style.font.family
    font.pixelSize: Style.font.small
    font.bold: true
}
