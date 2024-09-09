//
//  XcodeBuild.swift
//  swift-very
//
//  Created by David Walter on 05.09.24.
//

import Foundation

struct XcodeBuild: Executable {    
    let command: Command
    
    init(directory: URL? = nil, arguments: [String]) {
        self.command = Command(arguments: ["xcodebuild"] + arguments, currentDirectoryURL: directory)
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
