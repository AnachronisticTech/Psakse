//
//  Card.swift
//  Psakse-2
//
//  Created by Daniel Marriner on 29/06/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit

enum Card {
    
    case Wild
    case Normal(Symbols, Colors)
    
    func matches(other: Card) -> Bool {
        switch (self, other) {
        case (.Wild, _), (_, .Wild):
            return true
        case (.Normal(let sym1, let col1), .Normal(let sym2, let col2)):
            return sym1 == sym2 || col1 == col2
        }
    }
    
    func getColor() -> UIColor {
        switch self {
        case .Wild:
            return UIColor(red: 255/255, green: 180/255, blue: 188/255, alpha: 1)
        case .Normal(_, let color):
            return color.getColor()
        }
    }
    
    func getFilename() -> String {
        switch self {
        case .Wild:
            return "dot.png"
        case .Normal(let symbol, _):
            return symbol.getFilename()
        }
    }
    
    func equals(other: Card) -> Bool {
        switch (self, other) {
        case (.Wild, .Wild):
            return true
        case (.Normal(let sym1, let col1), .Normal(let sym2, let col2)):
            return sym1 == sym2 && col1 == col2
        default:
            return false
        }
    }
    
    func getID() -> String {
        switch self {
        case .Wild:
            return ""
        case .Normal(let sym, let col):
            return col.getID() + sym.getID()
        }
    }
}
