//
//  TextTable.swift
//  swift-very
//
//  Created by David Walter on 07.09.24.
//

import Foundation

struct TextTable: Sendable {
    private var columns: [Column]
    
    var fence = "|"
    var row = "-"
    var corner = "+"
    
    var header: String?
    
    init(header: String? = nil, columns: [TextTable.Column]) {
        self.header = header
        self.columns = columns
    }
    
    mutating func addRow(_ values: CustomStringConvertible...) {
        addRow(values: values)
    }
    
    mutating func addRow(values: [CustomStringConvertible]) {
        let values = if values.count >= columns.count {
            values
        } else {
            values + repeatElement("", count: columns.count - values.count)
        }
        
        columns = zip(columns, values)
            .map { column, value in
                var column = column
                column.values.append(value.description)
                return column
            }
    }
    
    func render(hideHeaders: Bool = false) -> String {
        let separator = columns
            .map { column in
                repeatElement(row, count: column.width + 2).joined()
            }
            .fenced(separator: corner)
        
        let header: [String?] = if !hideHeaders {
            [renderTableHeader(), renderColumnHeader(), separator]
        } else {
            [renderTableHeader()]
        }
        
        let numberOfRows = columns.map { $0.values.count }.max() ?? 0
        
        let values = (0..<numberOfRows)
            .map { index in
                columns.map { " \($0.values[index].padding(toLength: $0.width, withPad: " ", startingAt: 0)) " }
                    .fenced(separator: fence)
            }
            .joined(separator: "\n")
        
        return (header + [values, separator])
            .compactMap { $0 }
            .joined(separator: "\n")
    }
    
    private func renderColumnHeader() -> String {
        columns
            .map { column in
                " \(column.header.padding(toLength: column.width, withPad: " ", startingAt: 0)) "
            }
            .fenced(separator: fence)
    }
    
    private func renderTableHeader() -> String? {
        guard let header else {
            return nil
        }
        
        let count = columns.reduce(columns.count - 1) { result, column in
            result + column.width + 2
        }
        
        let separator = "\(corner)\(repeatElement(row, count: count).joined())\(corner)"
        let title = "\(fence) \(header.padding(toLength: count - 2, withPad: " ", startingAt: 0)) \(fence)"
        return [separator, title, separator]
            .joined(separator: "\n")
    }
}

extension TextTable {
    struct Column: Sendable, ExpressibleByStringLiteral {
        typealias StringLiteralType = String
        
        var header: String {
            didSet {
                calculateWidth()
            }
        }
        
        fileprivate var values: [String] = [] {
            didSet {
                calculateWidth()
            }
        }
        
        private(set) var width: Int = 0
        
        init(stringLiteral header: String) {
            self.header = header
            calculateWidth()
        }
        
        var rows: [String] {
            [header] + values
        }
        
        private mutating func calculateWidth() {
            let max = rows.max { lhs, rhs in
                lhs.count < rhs.count
            }
            guard let length = max?.count else { return }
            width = length
        }
    }
}
