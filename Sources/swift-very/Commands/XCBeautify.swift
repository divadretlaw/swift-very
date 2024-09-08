//
//  XCBeautify.swift
//  swift-very
//
//  Created by David Walter on 05.09.24.
//

import Foundation

struct XCBeautify: Command {
    static var command: String { "xcbeautify" }
    
    let output: Pipe
    let process: Process
    
    init() {
        let output = Pipe()
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["xcbeautify", "--disable-logging"]
        process.standardOutput = output
        self.output = output
        self.process = process
    }
}
