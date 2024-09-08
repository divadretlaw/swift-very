//
//  XcodeBuild.swift
//  swift-very
//
//  Created by David Walter on 05.09.24.
//

import Foundation

struct XcodeBuild: Command {
    static var command: String { "xcodebuild" }
    
    let output: Pipe
    let process: Process
    
    init(directory: URL? = nil, arguments: [String]) {
        let output = Pipe()
        let process = Process()
        process.currentDirectoryURL = directory
        process.launchPath = "/usr/bin/env"
        process.arguments = ["xcodebuild"] + arguments
        process.standardOutput = output
        self.output = output
        self.process = process
    }
    
    static func build(directory: URL? = nil, scheme: String, destination: String, clean: Bool = false) -> Self {
        Self.init(
            directory: directory,
            arguments: [
                clean ? "clean" : nil,
                "build",
                "-scheme",
                scheme,
                "-destination",
                destination
            ].compactMap { $0 }
        )
    }
}
