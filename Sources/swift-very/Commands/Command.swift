//
//  Comand.swift
//  swift-very
//
//  Created by David Walter on 08.09.24.
//

import Foundation

struct Command: Executable {
    enum Output: Hashable, Equatable, Sendable {
        /// The process wrote to `stdout`
        case output(Data)
        /// The process wrote to `stderr`
        case error(Data)
    }
    
    enum Error: Swift.Error {
        case terminated(Int32, stderr: String)
        case signalled(Int32)
        case notFound
    }
    
    private let process: Process
    
    var command: Command { self }
    
    init(
        _ arguments: String...,
        currentDirectoryURL: URL? = URL(filePath: FileManager.default.currentDirectoryPath),
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        self.init(
            arguments: arguments,
            currentDirectoryURL: currentDirectoryURL,
            environment: environment
        )
    }
    
    init(
        arguments: [String],
        currentDirectoryURL: URL? = URL(filePath: FileManager.default.currentDirectoryPath),
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        let process = Process()
        
        process.executableURL = URL(filePath: "/usr/bin/env")
        process.arguments = arguments
        process.currentDirectoryURL = currentDirectoryURL
        process.environment = environment
        
        self.process = process
    }
    
    var isSuccess: Bool {
        guard !process.isRunning else { return false }
        return process.terminationStatus == 0
    }
    
    func pipe(_ other: Executable) throws -> Executable {
        let pipe = Pipe()
        process.standardOutput = pipe
        other.command.process.standardInput = pipe
        try process.run()
        return other
    }
    
    func run() -> AsyncThrowingStream<Output, Swift.Error> {
        AsyncThrowingStream(Output.self, bufferingPolicy: .unbounded) { continuation in
            continuation.onTermination = { termination in
                switch termination {
                case .cancelled:
                    if process.isRunning {
                        process.terminate()
                    }
                default:
                    break
                }
            }
            
            var error = ""
            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            
            stdoutPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if !data.isEmpty {
                    continuation.yield(.output(data))
                }
            }
            
            stderrPipe.fileHandleForReading.readabilityHandler = { handle in
                let data = handle.availableData
                if !data.isEmpty, let output = String(data: data, encoding: .utf8) {
                    error.append(output)
                }
            }
            
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe
            
            do {
                if !process.isRunning {
                    try process.run()
                }
                process.waitUntilExit()
                
                if let data = try? stdoutPipe.fileHandleForReading.readToEnd(), !data.isEmpty {
                    continuation.yield(.output(data))
                }
                
                if let data = try? stderrPipe.fileHandleForReading.readToEnd(), !data.isEmpty {
                    continuation.yield(.error(data))
                    if let output = String(data: data, encoding: .utf8) {
                        error.append(output)
                    }
                }
                
                switch process.terminationReason {
                case .exit:
                    switch process.terminationStatus {
                    case 0:
                        break
                    case 127:
                        throw Error.notFound
                    default:
                        throw Error.terminated(process.terminationStatus, stderr: error)
                    }
                case .uncaughtSignal:
                    if process.terminationStatus != 0 {
                        throw Error.signalled(process.terminationStatus)
                    }
                @unknown default:
                    break
                }
                continuation.finish()
            } catch {
                continuation.finish(throwing: error)
            }
        }
    }
    
    func runAndPrint() async throws {
        for try await output in run() {
            switch output {
            case let .output(data):
                if let string = String(data: data, encoding: .utf8) {
                    print(string)
                    fflush(stdout)
                }
            case let .error(data):
                if let string = String(data: data, encoding: .utf8) {
                    printError(string)
                    fflush(stderr)
                }
            }
        }
    }
}
