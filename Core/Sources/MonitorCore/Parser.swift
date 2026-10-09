import Foundation

/// The single shell command run on each refresh. Linux only (reads /proc).
public enum RemoteCommand {
    public static let marker = "@@HARK@@"
    public static let script: String = """
    export LC_ALL=C
    echo '\(marker) loadavg'; cat /proc/loadavg
    echo '\(marker) stat'; grep '^cpu' /proc/stat
    echo '\(marker) meminfo'; cat /proc/meminfo
    echo '\(marker) netdev'; cat /proc/net/dev
    echo '\(marker) df'; df -kP -x tmpfs -x devtmpfs -x overlay -x squashfs -x efivarfs 2>/dev/null
    echo '\(marker) uptime'; cat /proc/uptime
    echo '\(marker) host'; hostname 2>/dev/null || cat /etc/hostname
    echo '\(marker) os'; (. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME") || uname -s
    echo '\(marker) kernel'; uname -r
    """
}

public enum Parser {
    public static func sections(_ text: String) -> [String: [String]] {
        var out: [String: [String]] = [:]
        var current: String?
        for line in text.split(separator: "\n", omittingEmptySubsequences: false) {
            let l = String(line)
            if l.hasPrefix(RemoteCommand.marker + " ") {
                current = String(l.dropFirst(RemoteCommand.marker.count + 1)).trimmingCharacters(in: .whitespaces)
                out[current!] = []
            } else if let c = current, !l.isEmpty {
                out[c, default: []].append(l)
            }
        }
        return out
    }

    static func fields(_ s: String) -> [String] { s.split(whereSeparator: { $0 == " " || $0 == "\t" }).map(String.init) }

    public static func parse(_ text: String, at time: Date = Date()) -> RawSample {
        let s = sections(text)
        var r = RawSample(time: time)

        if let l = s["loadavg"]?.first {
            let f = fields(l)
            if f.count >= 4 {
                r.load = (Double(f[0]) ?? 0, Double(f[1]) ?? 0, Double(f[2]) ?? 0)
                let p = f[3].split(separator: "/")
                if p.count == 2 { r.runningProcs = Int(p[0]) ?? 0; r.totalProcs = Int(p[1]) ?? 0 }
            }
        }
        for l in s["stat"] ?? [] {
            let f = fields(l); guard f.count >= 5 else { continue }
            var t = CPUTimes()
            let n = f.dropFirst().map { UInt64($0) ?? 0 }
            t.user = n[0]; t.nice = n[1]; t.system = n[2]; t.idle = n[3]
            if n.count > 4 { t.iowait = n[4] }
            if n.count > 5 { t.irq = n[5] }
            if n.count > 6 { t.softirq = n[6] }
            if n.count > 7 { t.steal = n[7] }
            if f[0] == "cpu" { r.cpu = t } else { r.perCore.append(t) }
        }
        for l in s["meminfo"] ?? [] {
            let f = fields(l); guard f.count >= 2, let v = UInt64(f[1]) else { continue }
            switch f[0] {
            case "MemTotal:": r.memory.totalKB = v
            case "MemFree:": r.memory.freeKB = v
            case "MemAvailable:": r.memory.availableKB = v
            case "Buffers:": r.memory.buffersKB = v
            case "Cached:": r.memory.cachedKB = v
            case "SReclaimable:": r.memory.sReclaimableKB = v
            case "Shmem:": r.memory.shmemKB = v
            case "SwapTotal:": r.memory.swapTotalKB = v
            case "SwapFree:": r.memory.swapFreeKB = v
            default: break
            }
        }
        for l in s["netdev"] ?? [] {
            guard let colon = l.firstIndex(of: ":") else { continue }
            let name = l[..<colon].trimmingCharacters(in: .whitespaces)
            let f = fields(String(l[l.index(after: colon)...]))
            guard f.count >= 9 else { continue }
            r.interfaces.append(InterfaceCounter(name: name, rxBytes: UInt64(f[0]) ?? 0, txBytes: UInt64(f[8]) ?? 0))
        }
        for l in (s["df"] ?? []).dropFirst() {
            let f = fields(l); guard f.count >= 6 else { continue }
            let mount = f[5...].joined(separator: " ")
            r.disks.append(DiskMount(filesystem: f[0], mount: mount,
                                     sizeKB: UInt64(f[1]) ?? 0, usedKB: UInt64(f[2]) ?? 0, availKB: UInt64(f[3]) ?? 0))
        }
        if let l = s["uptime"]?.first { r.uptimeSeconds = Double(fields(l).first ?? "0") ?? 0 }
        r.host.hostname = s["host"]?.first ?? ""
        r.host.os = s["os"]?.first ?? ""
        r.host.kernel = s["kernel"]?.first ?? ""
        r.host.cores = r.perCore.count
        return r
    }

    static func usage(_ a: CPUTimes, _ b: CPUTimes) -> CPUUsage {
        var u = CPUUsage()
        let dt = Double(b.total &- a.total); guard dt > 0, b.total >= a.total else { return u }
        func p(_ x: UInt64, _ y: UInt64) -> Double { y >= x ? Double(y - x) / dt * 100 : 0 }
        u.user = p(a.user, b.user); u.system = p(a.system + a.irq + a.softirq, b.system + b.irq + b.softirq)
        u.iowait = p(a.iowait, b.iowait); u.nice = p(a.nice, b.nice)
        u.total = max(0, min(100, 100 - p(a.idle + a.iowait, b.idle + b.iowait)))
        return u
    }

    /// Combine two consecutive samples into a snapshot. `prev` may be nil for the first sample.
    public static func snapshot(prev: RawSample?, cur: RawSample) -> Snapshot {
        var cpu = CPUUsage(); var cores = [Double](repeating: 0, count: cur.perCore.count)
        var rates: [InterfaceRate] = cur.interfaces.map { InterfaceRate(name: $0.name, rxPerSec: 0, txPerSec: 0) }
        if let p = prev {
            cpu = usage(p.cpu, cur.cpu)
            for i in 0..<min(p.perCore.count, cur.perCore.count) { cores[i] = usage(p.perCore[i], cur.perCore[i]).total }
            let dt = cur.time.timeIntervalSince(p.time)
            if dt > 0 {
                let old = Dictionary(p.interfaces.map { ($0.name, $0) }, uniquingKeysWith: { a, _ in a })
                rates = cur.interfaces.map { c in
                    guard let o = old[c.name], c.rxBytes >= o.rxBytes, c.txBytes >= o.txBytes else {
                        return InterfaceRate(name: c.name, rxPerSec: 0, txPerSec: 0)
                    }
                    return InterfaceRate(name: c.name, rxPerSec: Double(c.rxBytes - o.rxBytes) / dt,
                                         txPerSec: Double(c.txBytes - o.txBytes) / dt)
                }
            }
        }
        rates.sort { ($0.rxPerSec + $0.txPerSec) > ($1.rxPerSec + $1.txPerSec) }
        let external = rates.filter { $0.name != "lo" }
        var snap = Snapshot(time: cur.time, host: cur.host, uptimeSeconds: cur.uptimeSeconds,
                        load1: cur.load.0, load5: cur.load.1, load15: cur.load.2,
                        runningProcs: cur.runningProcs, totalProcs: cur.totalProcs,
                        cpu: cpu, perCore: cores, memory: cur.memory, interfaces: rates,
                        totalRx: external.reduce(0) { $0 + $1.rxPerSec }, totalTx: external.reduce(0) { $0 + $1.txPerSec },
                        disks: cur.disks)
        snap.hasRates = prev != nil
        return snap
    }
}
