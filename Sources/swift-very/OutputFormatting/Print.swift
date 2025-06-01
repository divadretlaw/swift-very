//
//  Print.swift
//  swift-very
//
//  Created by David Walter on 07.09.24.
//

import Foundation
import ShellStyle

func printHeader(_ value: String) {
    let header = TextHeader(value)
    print(header.render().foregroundColor(.green))
}

func printError(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let string = items.map { "\($0)" }.joined(separator: separator)
    print("error:".foregroundColor(.red), string, separator: " ", terminator: terminator)
}
