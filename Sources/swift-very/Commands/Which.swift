//
//  Which.swift
//  swift-very
//
//  Created by David Walter on 07.09.24.
//

import Foundation

struct Which: Command {
    static var command: String { "which" }
    
    let output: Pipe
    let process: Process
    
    init(arguments: [String]) {
        let output = Pipe()
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["which"] + arguments
        process.standardOutput = output
        self.output = output
        self.process = process
    }
}
