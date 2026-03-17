// swift-tools-version: 5.9
// PocketMux — Swift Package Manifest
// This file declares dependencies for later resolution in a macOS/Xcode environment.
// It does not replace an .xcodeproj for building the iOS app target.

import PackageDescription

let package = Package(
    name: "PocketMux",
    platforms: [.iOS(.v17)],
    dependencies: [
        .package(url: "https://github.com/orlandos-nl/Citadel.git", from: "0.6.0"),
    ],
    targets: [
        .target(
            name: "PocketMuxApp",
            dependencies: [
                .product(name: "Citadel", package: "Citadel"),
            ],
            path: "PocketMuxApp"
        ),
    ]
)
