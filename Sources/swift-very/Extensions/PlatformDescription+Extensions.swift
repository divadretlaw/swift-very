//
//  PlatformDescription+Extensions.swift
//  swift-very
//
//  Created by David Walter on 06.09.24.
//

import Foundation
import PackageModel

extension PlatformDescription: CustomStringConvertible {
    var formattedPlatformName: String {
        switch platformName.lowercased() {
        case "ios":
            "iOS"
        case "macos":
            "macOS"
        case "maccatalyst":
            "Mac Catalyst"
        case "tvos":
            "tvOS"
        case "watchos":
            "watchOS"
        case "visionos":
            "visionOS"
        case "driverkit":
            "DriverKit"
        case "linux":
            "Linux"
        case "windows":
            "Windows"
        case "android":
            "Android"
        case "wasi":
            "WebAssembly System Interface"
        case "openbsd":
            "OpenBSD"
        default:
            platformName
        }
    }
    
    public var description: String {
        "\(formattedPlatformName) \(version)"
    }
}
