//
//  Concatenate.swift
//  swift-very
//
//  Created by David Walter on 09.09.24.
//

import Foundation

struct Concatenate: Executable {
    static var command: String { "cat" }
    
    let command: Command
    
    init() {
        self.command = Command("cat")
    }
}
