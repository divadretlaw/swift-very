//
//  XCBeautify.swift
//  swift-very
//
//  Created by David Walter on 05.09.24.
//

import Foundation

struct XCBeautify: Executable {
    static var command: String { "xcbeautify" }
    
    let command: Command
    
    init() {
        self.command = Command("xcbeautify", "--disable-logging")
    }
    
    static func check() -> Bool {
        Which(command: "xcbeautify").run()
    }
}
