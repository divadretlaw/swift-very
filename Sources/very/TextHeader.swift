//
//  File.swift
//  swift-very
//
//  Created by David Walter on 06.09.24.
//

import Foundation

struct TextHeader {
    let value: String
    private let count: Int
    
    init(_ value: String) {
        self.value = value
        self.count = value.count + 8
    }
    
    func render() -> String {
        let border = Array(repeating: "-", count: count).joined()
        return """
        \(border)
        --- \(value) ---
        \(border)
        """
    }
}
