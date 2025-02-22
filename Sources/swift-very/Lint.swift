//
//  Lint.swift
//  swift-very
//
//  Created by David Walter on 19.09.24.
//

import Foundation
@preconcurrency import ArgumentParser
import Shell

struct Lint: AsyncParsableCommand {
    @Option(name: .long, help: "Directory containing the Package.swift to build.")
    var path: String?
    
    static let configuration = CommandConfiguration(abstract: "Run swiftlint with autocorrection")
    
    mutating func run() async throws {
        let swiftlintAutocorrect = if let path {
            Command("swiftlint", "--autocorrect", path)
        } else {
            Command("swiftlint", "--autocorrect")
        }
        
        try await swiftlintAutocorrect()
        
        let swiftlint = if let path {
            Command("swiftlint", path)
        } else {
            Command("swiftlint")
        }
        
        for try await output in swiftlint.stream() {
            switch output {
            case let .output(data):
                if let string = String(data: data, encoding: .utf8) {
                    if !string.hasPrefix("Linting") {
                        print(string)
                    }
                }
            case let .error(data):
                if let string = String(data: data, encoding: .utf8) {
                    printError(string)
                }
            }
        }
    }
}
