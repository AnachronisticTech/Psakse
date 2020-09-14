//
//  Deck.swift
//  Psakse
//
//  Created by Daniel Marriner on 29/06/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import Foundation

class Deck {
    let allCards:[Card] = [
        .Normal(.Psi, .Green),
        .Normal(.A, .Green),
        .Normal(.Xi, .Green),
        .Normal(.E, .Green),
        .Normal(.Psi, .Yellow),
        .Normal(.A, .Yellow),
        .Normal(.Xi, .Yellow),
        .Normal(.E, .Yellow),
        .Normal(.Psi, .Purple),
        .Normal(.A, .Purple),
        .Normal(.Xi, .Purple),
        .Normal(.E, .Purple),
        .Normal(.Psi, .Orange),
        .Normal(.A, .Orange),
        .Normal(.Xi, .Orange),
        .Normal(.E, .Orange),
        .Wild
    ]
    var cardQuantities = Array(repeating: 2, count: 17)
    
    var arr = [Card]()
//    var numberSymbols: Int
//    var numberColors: Int
    
    init() {
//    init(numberSymbols: Int, numberColors: Int) {
//        self.numberSymbols = numberSymbols
//        self.numberColors = numberColors
    }
    
    func populateDeck() {
//        let symbolsToRemove = 4 - numberSymbols
//        let colorsToRemove = 4 - numberColors
//
//        if symbolsToRemove != 0 {
//            var last = 4
//            while last > 0 {
//                let rand = (Int)(arc4random_uniform(UInt32(last)))
//                self.symbols.swapAt(last, rand)
//                last -= 1
//            }
//            for _ in 0...symbolsToRemove {
//                self.symbols.removeLast()
//            }
//        }
//
//        if colorsToRemove != 0 {
//            var last = 4
//            while last > 0 {
//                let rand = (Int)(arc4random_uniform(UInt32(last)))
//                self.colors.swapAt(last, rand)
//                last -= 1
//            }
//            for _ in 0...colorsToRemove {
//                self.colors.removeLast()
//            }
//        }
        
        for symbol in GameSymbol.allCases {
            for color in GameColor.allCases {
                self.arr.append(Card.Normal(symbol, color))
                self.arr.append(Card.Normal(symbol, color))
            }
        }
    }
    
    func addWildCards(count: Int)  {
        for _ in 0..<count {
            self.arr.append(Card.Wild)
        }
    }
    
    func removeCards(gridSize: Int, wildcards: Int) {
        let gridTotal = self.arr.count - (gridSize * gridSize) + wildcards
        for _ in 0..<gridTotal {
            let card = self.arr.removeLast()
            updateQuantities(card: card)
        }
    }
    
    func updateQuantities(card: Card) {
        let index = allCards.firstIndex { $0 == card }
        cardQuantities[index!] -= 1
    }
    
    func createDeckFromString(string: String) -> [Card] {
        var str = string
        var deck = [Card]()
        for i in 0..<allCards.count {
            let quantity = Int(String(str.removeFirst()))
            deck += Array.init(repeating: allCards[i], count: quantity!)
        }
        return deck
    }
    
    func stringToCard(col: String, sym: String) -> Card {
        func symbol(_ sym: String) -> GameSymbol {
            switch sym {
            case "p": return .Psi
            case "a": return .A
            case "x": return .Xi
            default : return .E
            }
        }
        func color(_ col: String) -> GameColor {
            switch col {
            case "g": return .Green
            case "y": return .Yellow
            case "p": return .Purple
            default : return .Orange
            }
        }
        return .Normal(symbol(sym), color(col))
    }
    
    func finalShuffle() {
        var last = self.arr.count - 1
        while last > 0 {
            let rand = Int.random(in: 0..<last)
            self.arr.swapAt(last, rand)
            last -= 1
        }
    }
}
