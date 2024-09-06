//
//  Build.swift
//  swift-very
//
//  Created by David Walter on 01.09.24.
//

import Foundation
import ArgumentParser
import Basics
import Workspace
import Rainbow

struct Build: AsyncParsableCommand {
    @Option(name: .long, help: "Scheme.")
    var scheme: String?
    
    @Option(name: .long, help: "Path of the Package.")
    var path: String?
    
    @Flag(name: .long, help: "Clean before building")
    var clean: Bool = false
    
    static let configuration = CommandConfiguration(abstract: "Build the package")
    
    mutating func run() async throws {
        let path = path ?? FileManager.default.currentDirectoryPath
        let directory = URL(filePath: path)
        let packagePath = try AbsolutePath(validating: path)
        
        let observability = ObservabilitySystem { _, _ in
        }
        
        let workspace = try Workspace(forRootPackage: packagePath)
        let manifest = try await workspace.loadRootManifest(at: packagePath, observabilityScope: observability.topScope)
        
        if let scheme {
            for platform in manifest.platforms {
                let header = TextHeader("Step: Building '\(scheme)' for \(platform.formattedPlatformName)")
                print(header.render().green)
                
                let xcodebuild = XcodeBuild.build(
                    directory: directory,
                    scheme: scheme,
                    destination: "generic/platform=\(platform.platformName)",
                    clean: clean
                )
                let xcbeautify = XCBeautify(arguments: ["--disable-logging"])
                
                let task = try xcodebuild | xcbeautify
                try await task > Printer()
            }
        } else {
            for target in manifest.targets {
                for platform in manifest.platforms {
                    let header = TextHeader("Step: Building '\(target.name)' for \(platform.formattedPlatformName)")
                    print(header.render().green)
                    
                    let xcodebuild = XcodeBuild.build(
                        directory: directory,
                        scheme: target.name,
                        destination: "generic/platform=\(platform.platformName)",
                        clean: clean
                    )
                    let xcbeautify = XCBeautify(arguments: ["--disable-logging"])
                    
                    let task = try xcodebuild | xcbeautify
                    try await task > Printer()
                }
            }
        }
    }
}
