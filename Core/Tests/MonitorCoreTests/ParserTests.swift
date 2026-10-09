import XCTest
@testable import MonitorCore

final class ParserTests: XCTestCase {
    func sample(_ cpuUser: Int, _ idle: Int, rx: Int) -> String {
        let m = RemoteCommand.marker
        return """
        \(m) loadavg
        0.29 0.30 0.32 1/772 12345
        \(m) stat
        cpu  \(cpuUser) 0 100 \(idle) 10 0 0 0 0 0
        cpu0 \(cpuUser) 0 100 \(idle) 10 0 0 0 0 0
        \(m) meminfo
        MemTotal:       16000000 kB
        MemFree:         2000000 kB
        MemAvailable:   11000000 kB
        Buffers:          100000 kB
        Cached:          9000000 kB
        SReclaimable:     500000 kB
        Shmem:            100000 kB
        SwapTotal:       2000000 kB
        SwapFree:        1999988 kB
        \(m) netdev
        Inter-|   Receive                                                |  Transmit
         face |bytes    packets errs drop fifo frame compressed multicast|bytes    packets errs drop fifo colls carrier compressed
            lo: \(rx) 10 0 0 0 0 0 0 \(rx) 10 0 0 0 0 0 0
         ens18: \(rx * 2) 10 0 0 0 0 0 0 \(rx) 10 0 0 0 0 0 0
        \(m) df
        Filesystem     1024-blocks      Used Available Capacity Mounted on
        /dev/sda2        132000000  34000000  90000000      28% /
        /dev/sdb1       1000000000 500000000 500000000      50% /mnt/My Data
        \(m) uptime
        90000.12 1000.00
        \(m) host
        archlinux
        \(m) os
        Arch Linux
        \(m) kernel
        6.10.0
        """
    }

    func testParseAndSnapshot() {
        let t0 = Date(timeIntervalSince1970: 0)
        let a = Parser.parse(sample(1000, 9000, rx: 1000), at: t0)
        let b = Parser.parse(sample(1100, 9800, rx: 4000), at: t0.addingTimeInterval(3))
        XCTAssertEqual(a.totalProcs, 772)
        XCTAssertEqual(a.host.hostname, "archlinux")
        XCTAssertEqual(a.host.cores, 1)
        XCTAssertEqual(a.disks.count, 2)
        XCTAssertEqual(a.disks[1].mount, "/mnt/My Data")
        let s = Parser.snapshot(prev: a, cur: b)
        XCTAssertEqual(s.cpu.total, 100.0 / 9.0, accuracy: 0.01) // 100 busy / 900 total
        XCTAssertEqual(s.interfaces.first(where: { $0.name == "ens18" })!.rxPerSec, 2000, accuracy: 0.01)
        XCTAssertEqual(s.totalRx, 2000, accuracy: 0.01) // lo excluded
        XCTAssertEqual(Format.uptime(s.uptimeSeconds), "1d 1h")
        XCTAssertGreaterThan(s.memory.usedPercent, 0)
    }
}
