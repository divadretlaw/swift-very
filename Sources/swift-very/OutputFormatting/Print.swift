//
//  PrintError.swift
//  swift-very
//
//  Created by David Walter on 07.09.24.
//

import Foundation
import Rainbow

func printHeader(_ value: String) {
    let header = TextHeader(value)
    print(header.render().green)
}

func printError(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let string = items.map { "\($0)" }.joined(separator: separator)
    print("error:".red, string, separator: " ", terminator: terminator)
}
