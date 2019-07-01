//
//  Symbols.swift
//  Psakse-2
//
//  Created by Daniel Marriner on 29/06/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

enum Symbols: CaseIterable {
    case Psi
    case A
    case Xi
    case E
    
    func getFilename() -> String {
        switch self {
        case .Psi:
            return "psi.png"
        case .A:
            return "a.png"
        case .Xi:
            return "xi.png"
        case .E:
            return "e.png"
        }
    }
    
    func getID() -> String {
        switch self {
        case .Psi:
            return "p"
        case .A:
            return "a"
        case .Xi:
            return "x"
        case .E:
            return "e"
        }
    }
}
