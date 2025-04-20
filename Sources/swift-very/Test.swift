//
//  Test.swift
//  swift-very
//
//  Created by David Walter on 20.04.25.
//

import Foundation
@preconcurrency import ArgumentParser
import Shell

struct Test: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Run swift test with xcbeautify")

    mutating func run() async throws {
        let test = Command("swift", "test")
        if await Command.isAvailable("xcbeautify") {
            let xcbeautify = Command("xcbeautify", "--disable-logging")
            let command = test | xcbeautify
            try await command()
        } else {
            try await test()
        }
    }
}
