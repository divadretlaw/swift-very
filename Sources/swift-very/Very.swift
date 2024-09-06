//
//  main.swift
//  swift-very
//
//  Created by David Walter on 01.09.24.
//

import Foundation
import ArgumentParser

@main
struct Very: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Swift Package Manager utilities.",
        version: "0.1.1",
        subcommands: [Build.self, Reset.self]
    )
}
