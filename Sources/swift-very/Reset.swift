//
//  Reset.swift
//  swift-very
//
//  Created by David Walter on 05.09.24.
//

import Foundation
import ArgumentParser

struct Reset: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Reset caches.",
        subcommands: [PackageCache.self, DerivedData.self]
    )
    
    struct PackageCache: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Clear Swift Package Manager Caches")
        
        mutating func run() async throws {
            let cache = FileManager.default.homeDirectoryForCurrentUser
                .appending(path: "Library/Caches/org.swift.swiftpm")
            let swiftpm = FileManager.default.homeDirectoryForCurrentUser
                .appending(path: "Library/org.swift.swiftpm")
            
            print("Removing '~/Library/Caches/org.swift.swiftpm'...")
            try FileManager.default.removeItem(at: cache)
            print("Removing '~/Library/org.swift.swiftpm'...")
            try FileManager.default.removeItem(at: swiftpm)
        }
    }
    
    struct DerivedData: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Clear DerivedData")
        
        mutating func run() async throws {
            let derivedData = FileManager.default.homeDirectoryForCurrentUser
                .appending(path: "Library/Developer/Xcode/DerivedData")
            print("Removing '~/Library/Developer/Xcode/DerivedData'...")
            try FileManager.default.removeItem(at: derivedData)
        }
    }
}
