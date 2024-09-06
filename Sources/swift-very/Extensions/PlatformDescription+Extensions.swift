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
        switch platformName {
        case "ios":
            "iOS"
        case "macos":
            "macOS"
        case "tvos":
            "tvOS"
        case "watchos":
            "watchOS"
        case "visionos":
            "visionOS"
        default:
            platformName
        }
    }
    
    public var description: String {
        "\(formattedPlatformName) \(version)"
    }
}
