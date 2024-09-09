//
//  Executable.swift
//  swift-very
//
//  Created by David Walter on 05.09.24.
//

import Foundation

protocol Executable: Sendable {
    var command: Command { get }
}

extension Executable {
    var isSuccess: Bool {
        command.isSuccess
    }
    
    func pipe(_ other: Executable) throws -> Executable {
        try command.pipe(other)
    }
    
    func run() -> AsyncThrowingStream<Command.Output, Swift.Error> {
        command.run()
    }
    
    func runAndPrint() async throws {
        try await command.runAndPrint()
    }
}

func | (lhs: Executable, rhs: Executable) throws -> Executable {
    try lhs.command.pipe(rhs)
}
