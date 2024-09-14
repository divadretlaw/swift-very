//
//  Build.swift
//  swift-very
//
//  Created by David Walter on 01.09.24.
//

import Foundation
import ArgumentParser
import Shell
import Rainbow
import Basics
import Workspace

struct Build: AsyncParsableCommand {
    @Option(name: .long, help: "The scheme to build.")
    var scheme: String?
    
    @Option(name: .long, help: "Directory containing the Package.swift to build.")
    var path: String?
    
    @Flag(name: .long, help: "Clean before building.")
    var clean: Bool = false
    
    static let configuration = CommandConfiguration(abstract: "Build all variants of the package")
    
    mutating func run() async throws {
        let path = path ?? FileManager.default.currentDirectoryPath
        let directory = URL(filePath: path)
        let packageSwift = directory.appending(path: "Package.swift")
        guard FileManager.default.fileExists(atPath: packageSwift.path(percentEncoded: false)) else {
            printError("Could not find Package.swift in this directory.")
            return
        }
        let packagePath = try AbsolutePath(validating: path)
        
        let observability = ObservabilitySystem { _, _ in
        }
        
        let workspace = try Workspace(forRootPackage: packagePath)
        let manifest = try await workspace.loadRootManifest(at: packagePath, observabilityScope: observability.topScope)
        
        var information = TextTable(
            header: "Loaded Package",
            columns: ["Key", "Value"]
        )
        information.addRow("Targets", manifest.targets.map(\.name).joined(separator: ", "))
        information.addRow("Platforms", manifest.platforms.map(\.description).joined(separator: ", "))
        information.addRow("Swift Version", manifest.toolsVersion.description)
        print(information.render(hideHeaders: true))
        
        let isXcbeautifyAvailable = XCBeautify.check()
        
        var summary = TextTable(
            header: "Build Summary",
            columns: ["Step", "Result"]
        )
        
        if let scheme {
            for platform in manifest.platforms {
                printHeader("Step: Building '\(scheme)' for \(platform.formattedPlatformName)")
                
                let xcodebuild = XcodeBuild.build(
                    directory: directory,
                    scheme: scheme,
                    destination: "generic/platform=\(platform.platformName)",
                    clean: clean
                )
                
                let task = if isXcbeautifyAvailable {
                    xcodebuild | XCBeautify()
                } else {
                    xcodebuild
                }
                
                do {
                    try await task()
                } catch let error as ShellError {
                    switch error {
                    case .terminated(let status, _):
                        summary.addRow("'\(scheme)' for \(platform.formattedPlatformName)", status == 0 ? "Success" : "Failure")
                    case .signalled:
                        throw error
                    }
                } catch {
                    throw error
                }
            }
        } else {
            for target in manifest.targets {
                for platform in manifest.platforms {
                    printHeader("Step: Building '\(target.name)' for \(platform.formattedPlatformName)")
                    
                    let xcodebuild = XcodeBuild.build(
                        directory: directory,
                        scheme: target.name,
                        destination: "generic/platform=\(platform.platformName)",
                        clean: clean
                    )
                    
                    let task = if isXcbeautifyAvailable {
                        xcodebuild | XCBeautify()
                    } else {
                        xcodebuild
                    }
                    
                    do {
                        try await task()
                    } catch let error as ShellError {
                        switch error {
                        case .terminated(let status, _):
                            summary.addRow("'\(target.name)' for \(platform.formattedPlatformName)", status == 0 ? "Success" : "Failure")
                        case .signalled:
                            throw error
                        }
                    } catch {
                        throw error
                    }
                }
            }
        }
        
        print(summary.render(hideHeaders: true))
    }
}
