import Foundation

public struct CPUTimes: Equatable, Sendable {
    public var user: UInt64 = 0, nice: UInt64 = 0, system: UInt64 = 0, idle: UInt64 = 0
    public var iowait: UInt64 = 0, irq: UInt64 = 0, softirq: UInt64 = 0, steal: UInt64 = 0
    public var total: UInt64 { user + nice + system + idle + iowait + irq + softirq + steal }
    public init() {}
}

public struct CPUUsage: Equatable, Sendable {
    public var total: Double = 0, user: Double = 0, system: Double = 0, iowait: Double = 0, nice: Double = 0
    public init() {}
}

public struct MemoryInfo: Equatable, Sendable {
    public var totalKB: UInt64 = 0, freeKB: UInt64 = 0, availableKB: UInt64 = 0
    public var buffersKB: UInt64 = 0, cachedKB: UInt64 = 0, sReclaimableKB: UInt64 = 0, shmemKB: UInt64 = 0
    public var swapTotalKB: UInt64 = 0, swapFreeKB: UInt64 = 0
    public var cacheKB: UInt64 { buffersKB + cachedKB + sReclaimableKB - min(shmemKB, cachedKB) }
    public var usedKB: UInt64 { let u = Int64(totalKB) - Int64(freeKB) - Int64(cacheKB); return UInt64(max(0, u)) }
    public var usedPercent: Double { totalKB == 0 ? 0 : Double(usedKB) / Double(totalKB) * 100 }
    public var swapUsedKB: UInt64 { swapTotalKB &- swapFreeKB }
    public init() {}
}

public struct InterfaceCounter: Equatable, Sendable {
    public var name: String; public var rxBytes: UInt64; public var txBytes: UInt64
}

public struct InterfaceRate: Identifiable, Equatable, Sendable {
    public var id: String { name }
    public var name: String; public var rxPerSec: Double; public var txPerSec: Double
}

public struct DiskMount: Identifiable, Equatable, Sendable {
    public var id: String { mount }
    public var filesystem: String; public var mount: String
    public var sizeKB: UInt64; public var usedKB: UInt64; public var availKB: UInt64
    public var usedPercent: Double { sizeKB == 0 ? 0 : Double(usedKB) / Double(sizeKB) * 100 }
}

public struct HostInfo: Equatable, Sendable {
    public var hostname = "", os = "", kernel = "", cores = 0
    public init() {}
}

/// One raw sample read from the server.
public struct RawSample: Sendable {
    public var time: Date
    public var load: (Double, Double, Double) = (0, 0, 0)
    public var runningProcs = 0, totalProcs = 0
    public var cpu = CPUTimes()
    public var perCore: [CPUTimes] = []
    public var memory = MemoryInfo()
    public var interfaces: [InterfaceCounter] = []
    public var disks: [DiskMount] = []
    public var uptimeSeconds: Double = 0
    public var host = HostInfo()
}

/// Derived snapshot the UI shows.
public struct Snapshot: Sendable {
    public var time: Date
    public var host: HostInfo
    public var uptimeSeconds: Double
    public var load1: Double, load5: Double, load15: Double
    public var runningProcs: Int, totalProcs: Int
    public var cpu: CPUUsage
    public var perCore: [Double]
    public var memory: MemoryInfo
    public var interfaces: [InterfaceRate]
    public var totalRx: Double, totalTx: Double
    public var disks: [DiskMount]
    /// false on the very first frame (CPU / network rates need two samples)
    public var hasRates: Bool = true
}

public enum Format {
    public static func bytesPerSec(_ v: Double) -> String { bytes(v) + "/s" }
    public static func bytes(_ v: Double) -> String {
        let units = ["B", "KB", "MB", "GB", "TB"]
        var x = v, i = 0
        while x >= 1024 && i < units.count - 1 { x /= 1024; i += 1 }
        return i == 0 ? String(format: "%.0f %@", x, units[i]) : String(format: "%.1f %@", x, units[i])
    }
    public static func kb(_ v: UInt64) -> String { bytes(Double(v) * 1024) }
    public static func uptime(_ s: Double) -> String {
        let t = Int(s); let d = t / 86400, h = (t % 86400) / 3600, m = (t % 3600) / 60
        if d > 0 { return "\(d)d \(h)h" }
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}
