//
//  Concatenate.swift
//  swift-very
//
//  Created by David Walter on 09.09.24.
//

import Foundation
import Shell

struct Concatenate: CommandRunnable {    
    let command: Command
    
    init() {
        self.command = Command("cat")
    }
}
