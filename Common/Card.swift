//
//  Card.swift
//  Psakse
//
//  Created by Daniel Marriner on 29/06/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

// FIXES BUG WITH REDEFINING NSColor and UIColor
#if os(macOS)
    import AppKit
    typealias Color = NSColor
#elseif os(iOS)
    import UIKit
    typealias Color = UIColor
#endif

enum Card: Equatable, Hashable {
    case Wild
    case Normal(GameSymbol, GameColor)
    
    func matches(other: Card) -> Bool {
        switch (self, other) {
            case (.Wild, _), (_, .Wild):
                return true
            case (.Normal(let sym1, let col1), .Normal(let sym2, let col2)):
                return sym1 == sym2 || col1 == col2
        }
    }
    
    var color: Color {
        switch self {
            case .Wild: return Color(named: "pink")!
            case .Normal(_, let color): return color.color
        }
    }
    
    var asset: String {
        switch self {
            case .Wild: return "dot"
            case .Normal(let symbol, _): return symbol.asset
        }
    }
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        switch (lhs, rhs) {
            case (.Wild, .Wild):
                return true
            case (.Normal(let sym1, let col1), .Normal(let sym2, let col2)):
                return sym1 == sym2 && col1 == col2
            default:
                return false
        }
    }
    
    var id: String {
        switch self {
            case .Wild: return ""
            case .Normal(let sym, let col): return col.id + sym.id
        }
    }
}
