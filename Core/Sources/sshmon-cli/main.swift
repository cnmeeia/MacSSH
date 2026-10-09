import Foundation
import MonitorCore

// usage: sshmon-cli host port user password
let a = CommandLine.arguments
guard a.count >= 5 else { print("usage: sshmon-cli host port user password"); exit(1) }
let auth: AuthMethod = a[4].hasPrefix("@") ? .privateKey(try! String(contentsOfFile: String(a[4].dropFirst()), encoding: .utf8), passphrase: nil) : .password(a[4])
let conn = SSHConnection(ServerEndpoint(host: a[1], port: Int(a[2]) ?? 22, username: a[3], auth: auth))
let t0 = Date()
let mon = Monitor(connection: conn, interval: .seconds(1))
var n = 0
do {
    for try await s in mon.stream() {
        if n == 0 { print(String(format: "first frame after %.0f ms", Date().timeIntervalSince(t0) * 1000)) }
        print("[\(s.host.hostname) | \(s.host.os) | \(s.host.cores) cores | up \(Format.uptime(s.uptimeSeconds))]")
        print(String(format: "load %.2f %.2f %.2f  procs %d/%d  cpu %.1f%% (user %.1f sys %.1f io %.1f)",
                     s.load1, s.load5, s.load15, s.runningProcs, s.totalProcs, s.cpu.total, s.cpu.user, s.cpu.system, s.cpu.iowait))
        print(String(format: "mem %.1f%% used %@ cache %@ of %@", s.memory.usedPercent,
                     Format.kb(s.memory.usedKB), Format.kb(s.memory.cacheKB), Format.kb(s.memory.totalKB)))
        print("net rx \(Format.bytesPerSec(s.totalRx)) tx \(Format.bytesPerSec(s.totalTx)); ifaces \(s.interfaces.map(\.name))")
        print("disks \(s.disks.map { "\($0.mount) \(Int($0.usedPercent))%" })")
        n += 1; if n >= 2 { break }
    }
    let echo = try await conn.run("echo pty-ok")
    print("exec:", echo.trimmingCharacters(in: .whitespacesAndNewlines))
} catch { print("ERROR:", error) ; exit(2) }

// PTY test
let shell = ShellSession(connection: conn) // reuses the same SSH connection
let t1 = Date()
shell.start(cols: 100, rows: 30)
shell.send("stty size; echo PTY_$((6*7)); exit\n")
var out = ""
for await event in shell.events {
    if case .output(let bytes) = event { out += String(decoding: bytes, as: UTF8.self) }
    if out.contains("PTY_42") { break }
}
print(String(format: "pty ready in %.0f ms (shared connection)", Date().timeIntervalSince(t1) * 1000)); print("pty:", out.contains("PTY_42") ? "OK" : "FAIL", out.contains("30 100") ? "size OK" : "size ?")
await conn.close()
