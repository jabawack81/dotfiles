pragma Singleton
import QtQuick

// Pure helper functions shared across the shell. No state — anything
// stateful belongs on Color, Style, or Globals.
QtObject {
    id: root

    function clamp(value, min, max) {
        const n = Number(value);
        if (!isFinite(n)) return min;
        return Math.max(min, Math.min(max, n));
    }

    function clampAlpha(value) {
        return clamp(value, 0, 1);
    }

    // Compose a base color with an opacity. Accepts a color or hex string.
    function alpha(c, opacity) {
        const a = clampAlpha(opacity);
        if (!c) return Qt.rgba(0, 0, 0, a);
        if (typeof c === "string") c = Qt.color(c);
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    // file:// URL with each path segment percent-encoded so spaces/special
    // chars in user paths don't break Image.source.
    function fileUrl(path) {
        if (!path) return "";
        return "file://" + String(path).split("/").map(encodeURIComponent).join("/");
    }

    // Single-quote a string for bash.
    function shellQuote(value) {
        return "'" + String(value || "").replace(/'/g, "'\\''") + "'";
    }
}
