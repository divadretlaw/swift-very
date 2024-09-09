//
//  Which.swift
//  swift-very
//
//  Created by David Walter on 07.09.24.
//

import Foundation

struct Which {
    let output: Pipe
    let process: Process
    
    init(command: String) {
        let output = Pipe()
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["which", command]
        process.standardOutput = output
        self.output = output
        self.process = process
    }
    
    func run() -> Bool {
        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0
        } catch {
            return false
        }
    }
}
