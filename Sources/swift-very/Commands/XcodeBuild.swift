//
//  XcodeBuild.swift
//  swift-very
//
//  Created by David Walter on 05.09.24.
//

import Foundation
import Shell

struct XcodeBuild: CommandRunnable {
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
    
    static func listSchemes(directory: URL? = nil) async throws -> [String] {
        let xcodebuild = XcodeBuild(
            directory: directory,
            arguments: [ "-list"]
        )
        var results: [String] = []
        for try await output in xcodebuild.stream() {
            switch output {
            case let .output(data):
                if let string = String(data: data, encoding: .utf8) {
                    fputs(string, Darwin.stdout)
                    results.append(string)
                    fflush(Darwin.stdout)
                }
            case let .error(data):
                if let string = String(data: data, encoding: .utf8) {
                    fputs(string, Darwin.stderr)
                    fflush(Darwin.stderr)
                }
            }
        }
        let output = results.joined()
        let parts = output.split(separator: "Schemes:")
        guard let schemes = parts.last else { return [] }
        return schemes.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
}
