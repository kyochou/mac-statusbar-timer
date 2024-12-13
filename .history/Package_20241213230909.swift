// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "StatusBarTimer",
    platforms: [
        .macOS(.v12)
    ],
    targets: [
        .executableTarget(
            name: "StatusBarTimer",
            path: "Sources/StatusBarTimer"
        )
    ]
) 