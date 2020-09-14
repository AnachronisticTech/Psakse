//
//  GameSymbol.swift
//  Psakse
//
//  Created by Daniel Marriner on 29/06/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

enum GameSymbol: CaseIterable {
    case Psi, A, Xi, E
    
    var asset: String {
        switch self {
            case .Psi: return "psi"
            case .A: return "a"
            case .Xi: return "xi"
            case .E: return "e"
        }
    }
    
    var id: String {
        switch self {
            case .Psi: return "p"
            case .A: return "a"
            case .Xi: return "x"
            case .E: return "e"
        }
    }
}
