//
//  Format.swift
//  swift-very
//
//  Created by David Walter on 16.03.25.
//

@preconcurrency import ArgumentParser
import Foundation
import Shell

struct Format: AsyncParsableCommand {
    enum Formatter: String, ExpressibleByArgument {
        case swiftFormat = "swift-format"
        case sourceKitten = "sourcekitten"
    }
    
    @Argument
    var path: String
    
    @Option(name: .long, help: "The formatters to use.")
    var formatters: [Formatter] = [.swiftFormat, .sourceKitten]
    
    static let configuration = CommandConfiguration(abstract: "Run swift code formatters")
    
    mutating func run() async throws {
        if formatters.contains(.swiftFormat), await Command.isAvailable("swift-format") {
            let swiftFormat = Command("swift-format", "-i", "-r", path)
            try await swiftFormat()
        }
        
        let directory = URL(filePath: path)
        let files = try FileManager.default.swiftFiles(in: directory)
        if formatters.contains(.sourceKitten), await Command.isAvailable("sourcekitten") {
            for file in files {
                let sourcekitten = Command("sourcekitten", "format", "--file", file.path())
                try await sourcekitten()
            }
        }
    }
}

extension FileManager {
    func swiftFiles(in directory: URL) throws -> [URL] {
        var result: [URL] = []
        if let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator where fileURL.pathExtension == "swift" {
                let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                if fileAttributes.isRegularFile! {
                    result.append(fileURL)
                }
            }
        }
        return result
    }
}
