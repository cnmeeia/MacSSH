// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "MonitorCore",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [.library(name: "MonitorCore", targets: ["MonitorCore"])],
    dependencies: [
        .package(url: "https://github.com/orlandos-nl/Citadel.git", from: "0.12.0"),
    ],
    targets: [
        .target(name: "MonitorCore", dependencies: [.product(name: "Citadel", package: "Citadel")]),
        .executableTarget(name: "sshmon-cli", dependencies: ["MonitorCore"]),
        .testTarget(name: "MonitorCoreTests", dependencies: ["MonitorCore"]),
    ],
    swiftLanguageModes: [.v6]
)
