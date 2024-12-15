// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WorkingTimer",
    platforms: [
        .macOS(.v12)
    ],
    targets: [
        .executableTarget(
            name: "WorkingTimer",
            path: "Sources/WorkingTimer"
        )
    ]
) 