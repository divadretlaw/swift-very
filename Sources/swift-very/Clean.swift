//
//  Clean.swift
//  swift-very
//
//  Created by David Walter on 29.05.25.
//

import Foundation
@preconcurrency import ArgumentParser
import Shell

struct Clean: AsyncParsableCommand {
    @Option(name: .long, help: "Directory containing the Package.swift to build.")
    var path: String?

    @Flag(name: .shortAndLong, help: "Clean subdirectories recursively.")
    var recursive: Bool = false

    mutating func run() async throws {
        let path = path ?? FileManager.default.currentDirectoryPath
        let directory = URL(filePath: path)
        try clean(directory)
        if recursive {
            try iterateDirectory(directory)
        }
    }

    private func iterateDirectory(_ directory: URL) throws {
        for url in try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]) {
            let attributes = try url.resourceValues(forKeys: [.isDirectoryKey])
            if attributes.isDirectory == true {
                try clean(url)
                try iterateDirectory(url)
            }
        }
    }

    // MARK: -

    private func clean(_ directory: URL) throws {
        let packageSwift = directory.appending(path: "Package.swift")
        guard FileManager.default.fileExists(atPath: packageSwift.path(percentEncoded: false)) else {
            // Not a Swift Package, nothing to clean
            return
        }
        let build = directory.appending(path: ".build")
        guard FileManager.default.fileExists(atPath: build.path(percentEncoded: false)) else {
            // No .build folder present, nothing to clean
            return
        }
        print("Cleaning Swift Package at '\(directory.absoluteString.replacing("file://", with: ""))'")
        try FileManager.default.removeItem(at: build)
    }
}
