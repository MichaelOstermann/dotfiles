pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Colour picker state: the current colour, the format it is copied in, a
// short history, and the hex / rgba / oklch conversions.
Singleton {
    id: root

    readonly property var formats: ["hex", "rgba", "oklch"]
    property string format: "hex"
    property string current: "#93a2d7"      // always "#rrggbb"
    property var history: []                // newest first, "#rrggbb"
    readonly property int historySize: 6

    // ---- Conversions (sRGB -> OKLCH, Björn Ottosson's OKLab) ----------------
    function toRgb(hex: string): var {
        const n = parseInt(hex.slice(1), 16)
        return [(n >> 16) & 255, (n >> 8) & 255, n & 255]
    }

    function toHex(r: real, g: real, b: real): string {
        const h = v => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, "0")
        return "#" + h(r) + h(g) + h(b)
    }

    // -> [L 0..1, C 0..~0.4, H 0..360]
    function toOklch(hex: string): var {
        const lin = v => { v /= 255; return v <= 0.04045 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4) }
        const [r, g, b] = toRgb(hex).map(lin)
        const l = Math.cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b)
        const m = Math.cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b)
        const s = Math.cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b)
        const L = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s
        const A = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s
        const B = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s
        const C = Math.sqrt(A * A + B * B)
        const H = C < 1e-4 ? 0 : (Math.atan2(B, A) * 180 / Math.PI + 360) % 360
        return [L, C, H]
    }

    function formatted(hex: string, as: string): string {
        if (as === "rgba") return "rgba(" + toRgb(hex).join(", ") + ", 1)"
        if (as === "oklch") {
            const [L, C, H] = toOklch(hex)
            return "oklch(" + L.toFixed(3) + " " + C.toFixed(3) + " " + H.toFixed(1) + ")"
        }
        return hex
    }

    // ---- Actions ------------------------------------------------------------
    // Copies `hex` in `as` (which becomes the default format) and files it
    // at the front of the history.
    function copy(hex: string, as: string): void {
        format = as
        current = hex
        history = [hex].concat(history.filter(h => h !== hex)).slice(0, historySize)
        Quickshell.execDetached(["wl-copy", formatted(hex, as)])
        store.setText(JSON.stringify({ format: format, history: history }))
    }

    FileView {
        id: store
        path: Quickshell.statePath("colors.json")
        printErrors: false
        onLoaded: {
            try {
                const d = JSON.parse(text())
                root.format = d.format ?? "hex"
                root.history = (d.history ?? []).slice(0, root.historySize)
                if (root.history.length) root.current = root.history[0]
            } catch (e) {}
        }
    }
}
