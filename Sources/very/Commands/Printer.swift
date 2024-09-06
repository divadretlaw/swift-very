//
//  Printer.swift
//  swift-very
//
//  Created by David Walter on 05.09.24.
//

import Foundation

struct Printer {
    let output: Pipe
    let error: Pipe
    let process: Process
    
    enum Output: Hashable, Equatable, Sendable {
        /// The process has launched
        case launched
        /// The process wrote to `stdout`
        case output(String)
        /// The process wrote to `stderr`
        case error(String)
        /// The process has terminated
        case terminated
    }
    
    init() {
        let output = Pipe()
        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.arguments = ["cat"]
        process.standardOutput = output
        self.error = Pipe()
        self.output = output
        self.process = process
    }
    
    func run(input: Pipe) -> AsyncStream<Output> {
        process.standardInput = input
        return AsyncStream<Output> { continuation in
            continuation.onTermination = { termination in
                switch termination {
                case .finished:
                    break
                case .cancelled:
                    guard self.process.isRunning else { return }
                    process.terminate()
                @unknown default:
                    break
                }
            }
            
            process.terminationHandler = { _ in
                continuation.yield(.terminated)
                continuation.finish()
            }
            
            do {
                try self.process.run()
                continuation.yield(.launched)
            } catch {
                continuation.yield(.terminated)
                continuation.finish()
            }
            
            output.fileHandleForReading.readabilityHandler = { pipe in
                let availableData = String(decoding: pipe.availableData, as: UTF8.self).trimmingCharacters(in: .newlines)
                guard !availableData.isEmpty else { return }
                continuation.yield(.output(availableData))
            }
            error.fileHandleForReading.readabilityHandler = { pipe in
                let availableData = String(decoding: pipe.availableData, as: UTF8.self).trimmingCharacters(in: .newlines)
                guard !availableData.isEmpty else { return }
                continuation.yield(.error(availableData))
            }
        }
    }
}

func > (lhs: Command, rhs: Printer) async throws {
    let pipe = if lhs.process.isRunning {
        lhs.output
    } else {
        try lhs.run()
    }
    for await output in rhs.run(input: pipe) {
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
}
