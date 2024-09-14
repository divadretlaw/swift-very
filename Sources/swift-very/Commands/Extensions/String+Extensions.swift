//
//  String+Extensions.swift
//  swift-very
//
//  Created by David Walter on 07.09.24.
//

import Foundation

extension [String] {
    func fenced(separator: String) -> String {
        "\(separator)\(joined(separator: separator))\(separator)"
    }
}
