pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs

// System stats, process lists, network and ports. The probes and the
// TERM-then-KILL flow started from gdeyoung/omarchy-sysmon (MIT, see LICENSE).
Singleton {
    id: root

    // Set by the panel while it is open: samples faster and runs the process
    // and network probes.
    property bool watching: false

    property real cpuPct: 0
    property real gpuPct: -1
    property real memUsedKb: 0
    property real memTotalKb: 1
    property real vramUsedB: -1
    property real vramTotalB: -1
    property real diskUsedB: 0
    property real diskSizeB: 1
    property real cpuTemp: -1
    property real gpuTemp: -1
    property real diskTemp: -1
    // Local filesystems: [[mount, usedB, sizeB], ...]
    property var volumes: []

    readonly property real memPct: memUsedKb / memTotalKb * 100
    readonly property real diskPct: diskUsedB / diskSizeB * 100

    // Rates in bytes/s.
    property real netDown: 0
    property real netUp: 0
    property real ioRead: 0
    property real ioWrite: 0

    // The last `samples` readings of each, oldest first, for the charts.
    readonly property int samples: 60
    property var cpuHistory: []
    property var gpuHistory: []
    property var memHistory: []
    property var netHistory: []     // [{ down, up }, ...]
    property var ioHistory: []      // [{ read, write }, ...]

    // The user's processes grouped by executable, top by CPU and by memory:
    // [[name, pcpu, rssKb, [[pid, comm, pcpu, rssKb], ...]], ...]
    property var byCpu: []
    property var byMem: []
    // TCP traffic per app, busiest first: [[name, downBps, upBps, [pid, ...]], ...]
    property var netProcs: []
    // Listening TCP sockets: [[pid, name, [port, ...], exposed, dir], ...]
    property var ports: []

    // Two-step kill: TERM first; a target that is still listed after the next
    // refresh stays the killTarget, and the panel then offers KILL. The key is
    // an app name, or a pid as a string for a single process.
    property string killTarget: ""
    readonly property bool killAlive: byCpu.concat(byMem)
        .some(g => g[0] === killTarget || g[3].some(p => String(p[0]) === killTarget))
        || netProcs.some(p => p[0] === killTarget)
        || ports.some(p => String(p[0]) === killTarget)
    onKillAliveChanged: if (!killAlive) killTarget = ""

    function kill(key: string, pids: var): void {
        const force = killTarget === key
        Quickshell.execDetached(["kill", force ? "-9" : "-15", ...pids.map(String)])
        killTarget = force ? "" : key
        procProbe.running = true
        netProbe.running = true
    }

    function levelColor(pct: real): color {
        return pct >= 90 ? Theme.critical : pct >= 70 ? Theme.warning : Theme.fg
    }

    function pushed(history: var, sample: var): var {
        return history.slice(1 - samples).concat([sample])
    }

    // Previous cumulative counters, for the deltas.
    property var prev: null
    property real prevStamp: 0
    property var prevNet: ({})
    property real prevNetStamp: 0

    function apply(text: string): void {
        let d
        try { d = JSON.parse(text) } catch (e) { return }

        const now = Date.now()
        const dt = (now - prevStamp) / 1000
        if (prev && dt > 0.4) {
            const dTotal = d.cpu_total - prev.cpu_total
            if (dTotal > 0)
                cpuPct = Math.max(0, Math.min(100, 100 * (1 - (d.cpu_idle - prev.cpu_idle) / dTotal)))
            const rate = key => Math.max(0, (d[key] - prev[key]) / dt)
            netDown = rate("net_rx")
            netUp = rate("net_tx")
            ioRead = rate("io_read")
            ioWrite = rate("io_write")
        }
        prev = d
        prevStamp = now

        gpuPct = d.gpu_busy_pct
        memTotalKb = d.mem_total_kb || 1
        memUsedKb = d.mem_total_kb - d.mem_avail_kb
        vramUsedB = d.vram_used_b
        vramTotalB = d.vram_total_b
        diskUsedB = d.disk_used_b
        diskSizeB = d.disk_size_b || 1
        cpuTemp = d.cpu_temp_mc / 1000
        gpuTemp = d.gpu_temp_mc / 1000
        diskTemp = d.disk_temp_mc / 1000
        volumes = d.vols

        cpuHistory = pushed(cpuHistory, cpuPct)
        gpuHistory = pushed(gpuHistory, Math.max(0, gpuPct))
        memHistory = pushed(memHistory, memPct)
        netHistory = pushed(netHistory, { down: netDown, up: netUp })
        ioHistory = pushed(ioHistory, { read: ioRead, write: ioWrite })
    }

    // Per-app rates from the cumulative byte counts of their open sockets. A
    // closing socket takes its bytes with it, hence the clamp at zero.
    function applyNet(text: string): void {
        let d
        try { d = JSON.parse(text) } catch (e) { return }
        ports = d.ports

        const now = Date.now()
        const dt = (now - prevNetStamp) / 1000
        const cur = {}
        const rates = []
        for (const [name, rx, tx, pids] of d.net) {
            cur[name] = [rx, tx]
            const before = prevNet[name]
            rates.push(before && dt > 0.4
                ? [name, Math.max(0, (rx - before[0]) / dt), Math.max(0, (tx - before[1]) / dt), pids]
                : [name, 0, 0, pids])
        }
        netProcs = rates.sort((a, b) => (b[1] + b[2]) - (a[1] + a[2]) || a[0].localeCompare(b[0]))
        prevNet = cur
        prevNetStamp = now
    }

    function script(name: string): string {
        return Qt.resolvedUrl(name).toString().replace("file://", "")
    }

    Process {
        id: probe
        command: ["bash", root.script("probe.sh")]
        stdout: StdioCollector { onStreamFinished: root.apply(text) }
    }

    Process {
        id: procProbe
        command: ["bash", root.script("procprobe.sh")]
        stdout: StdioCollector {
            onStreamFinished: {
                let d
                try { d = JSON.parse(text) } catch (e) { return }
                root.byCpu = d.cpu
                root.byMem = d.mem
            }
        }
    }

    Process {
        id: netProbe
        command: ["bash", root.script("netprobe.sh")]
        stdout: StdioCollector { onStreamFinished: root.applyNet(text) }
    }

    Timer {
        interval: root.watching ? 2000 : 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: probe.running = true
    }

    Timer {
        interval: 2000
        running: root.watching
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            procProbe.running = true
            netProbe.running = true
        }
    }
}
