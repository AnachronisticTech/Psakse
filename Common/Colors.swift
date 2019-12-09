//
//  Colors.swift
//  Psakse
//
//  Created by Daniel Marriner on 29/06/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

enum Colors: CaseIterable {
    case Green
    case Yellow
    case Purple
    case Orange
    
    func getColor() -> Color {
        switch self {
        case .Green:
            return Color(red: 175/255, green: 227/255, blue: 70/255, alpha: 1)
        case .Yellow:
            return Color(red: 255/255, green: 220/255, blue: 115/255, alpha: 1)
        case .Purple:
            return Color(red: 236/255, green: 167/255, blue: 238/255, alpha: 1)
        case .Orange:
            return Color(red: 255/255, green: 153/255, blue: 51/255, alpha: 1)
        }
    }
    
    func getID() -> String {
        switch self {
        case .Green:
            return "g"
        case .Yellow:
            return "y"
        case .Purple:
            return "p"
        case .Orange:
            return "o"
        }
    }
}
