//
//  Command.swift
//  swift-very
//
//  Created by David Walter on 05.09.24.
//

import Foundation

protocol Command {
    var output: Pipe { get }
    var process: Process { get }
    
    func run() throws -> Pipe
    func run(input: Pipe?) throws -> Pipe
    func waitUntilExit()
}

extension Command {
    func run() throws -> Pipe {
        try run(input: nil)
    }
    
    func run(input: Pipe?) throws -> Pipe {
        process.standardInput = input
        try process.run()
        return output
    }
    
    func waitUntilExit() {
        process.waitUntilExit()
    }
}

func | (lhs: Command, rhs: Command) throws -> Command {
    let pipe = if lhs.process.isRunning {
        lhs.output
    } else {
        try lhs.run()
    }
    _ = try rhs.run(input: pipe)
    return rhs
}
