//
//  XCBeautify.swift
//  swift-very
//
//  Created by David Walter on 05.09.24.
//

import Foundation

struct XCBeautify: Command {
    let output: Pipe
    let process: Process
    
    init(arguments: [String]) {
        let output = Pipe()
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["xcbeautify"] + arguments
        process.standardOutput = output
        self.output = output
        self.process = process
    }
}
