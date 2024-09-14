// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-very",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/divadretlaw/Shell", from: "0.1.0"),
        .package(url: "https://github.com/swiftlang/swift-package-manager", revision: "swift-5.10-RELEASE"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.1")
    ],
    targets: [
        .executableTarget(
            name: "swift-very",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Shell", package: "Shell"),
                .product(name: "SwiftPM", package: "swift-package-manager"),
                .product(name: "Rainbow", package: "Rainbow")
            ]
        )
    ]
)
