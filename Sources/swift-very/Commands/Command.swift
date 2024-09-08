//
//  Command.swift
//  swift-very
//
//  Created by David Walter on 05.09.24.
//

import Foundation

protocol Command {
    static var command: String { get }
    
    var output: Pipe { get }
    var process: Process { get }
}

extension Command {
    static func check() -> Bool {
        do {
            let command = Which(arguments: [command])
            try command.run()
            command.waitUntilExit()
            return command.isSuccess
        } catch {
            return false
        }
    }
    
    var isSuccess: Bool {
        guard !process.isRunning else { return false }
        return process.terminationStatus == 0
    }
    
    @discardableResult func run() throws -> Pipe {
        try run(input: nil)
    }
    
    @discardableResult func run(input: Pipe?) throws -> Pipe {
        if let input {
            process.standardInput = input
        }
        try process.run()
        return output
    }
    
    func waitUntilExit() {
        process.waitUntilExit()
    }
    
    func pipe(_ command: Command) throws -> Command {
        let pipe = if process.isRunning {
            output
        } else {
            try run()
        }
        command.process.standardInput = pipe
        return command
    }
    
    func capture() async throws -> Command {
        let printer = Printer()
        let pipe = if process.isRunning {
            output
        } else {
            try run()
        }
        
        for await output in printer.run(input: pipe) {
            switch output {
            case .launched:
                break
            case .output(let string):
                print(string)
                fflush(stdout)
            case .error(let string):
                print(string)
                fflush(stderr)
            case .terminated:
                break
            }
        }
        return self
    }
}
