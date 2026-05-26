// Text pre-styled with the shell's monospace font. `small` switches to the
// smaller type token. Everything else behaves like a normal Text.
import QtQuick
import qs.Commons

Text {
    property bool small: false
    font.family: Style.font.family
    font.pixelSize: small ? Style.font.small : Style.font.base
    color: Color.foreground
}
