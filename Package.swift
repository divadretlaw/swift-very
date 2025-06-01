// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-very",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/divadretlaw/Shell", from: "1.2.0"),
        .package(url: "https://github.com/swiftlang/swift-package-manager", revision: "swift-6.0-RELEASE")
    ],
    targets: [
        .executableTarget(
            name: "swift-very",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Shell", package: "Shell"),
                .product(name: "ShellStyle", package: "Shell"),
                .product(name: "SwiftPM", package: "swift-package-manager")
            ]
        )
    ]
)
