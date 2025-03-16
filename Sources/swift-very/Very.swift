//
//  main.swift
//  swift-very
//
//  Created by David Walter on 01.09.24.
//

import Foundation
@preconcurrency import ArgumentParser

@main
struct Very: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Swift Package Manager utilities.",
        version: "0.7.0",
        subcommands: [Build.self, Lint.self, Format.self, Reset.self]
    )
}
