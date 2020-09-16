//
//  GameColor.swift
//  Psakse
//
//  Created by Daniel Marriner on 29/06/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

enum GameColor: CaseIterable {
    case Green
    case Yellow
    case Purple
    case Orange
    
    var color: Color {
        switch self {
            case .Green : return Color(named: "green")!
            case .Yellow: return Color(named: "yellow")!
            case .Purple: return Color(named: "purple")!
            case .Orange: return Color(named: "orange")!
        }
    }
    
    var id: String {
        switch self {
            case .Green : return "g"
            case .Yellow: return "y"
            case .Purple: return "p"
            case .Orange: return "o"
        }
    }
}
