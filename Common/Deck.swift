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
    //        var numberSymbols: Int
    //        var numberColors: Int
    
    init() {
        //        init(numberSymbols: Int, numberColors: Int) {
        //            self.numberSymbols = numberSymbols
        //            self.numberColors = numberColors
    }
    
    func populateDeck() {
        //            let symbolsToRemove = 4 - numberSymbols
        //            let colorsToRemove = 4 - numberColors
        
        //            if symbolsToRemove != 0 {
        //                var last = 4
        //                while last > 0 {
        //                    let rand = (Int)(arc4random_uniform(UInt32(last)))
        //                    self.symbols.swapAt(last, rand)
        //                    last -= 1
        //                }
        //                for _ in 0...symbolsToRemove {
        //                    self.symbols.removeLast()
        //                }
        //            }
        //
        //            if colorsToRemove != 0 {
        //                var last = 4
        //                while last > 0 {
        //                    let rand = (Int)(arc4random_uniform(UInt32(last)))
        //                    self.colors.swapAt(last, rand)
        //                    last -= 1
        //                }
        //                for _ in 0...colorsToRemove {
        //                    self.colors.removeLast()
        //                }
        //            }
        
        for symbol in Symbols.allCases {
            for color in Colors.allCases {
                self.arr.append(Card.Normal(symbol, color))
                self.arr.append(Card.Normal(symbol, color))
            }
        }
        //            print("\(self.arr.count) cards added to the deck")
    }
    
    func addWildCards(count: Int)  {
        for _ in 0..<count {
            self.arr.append(Card.Wild)
        }
        //            print("\(count) wildcards added to the deck")
    }
    
    func removeCards(gridSize: Int, wildcards: Int) {
        let gridTotal = self.arr.count - (gridSize * gridSize) + wildcards
        for _ in 0..<gridTotal {
            let card = self.arr.removeLast()
            updateQuantities(card: card)
        }
        //            print("\(self.arr.count) cards remaining in the deck")
    }
    
    func updateQuantities(card: Card) {
        let index = allCards.firstIndex(where: {(tmp: Card) in
            return tmp.equals(other: card)
        })
        cardQuantities[index!] -= 1
    }
    
    func createDeckFromString(string: String) -> [Card] {
        var str = string
        var cards = allCards
        var deck = [Card]()
        for i in 0..<cards.count {
            let quantity = Int(String(str.removeFirst()))
            deck += Array.init(repeating: cards[i], count: quantity!)
        }
        return deck
    }
    
    func stringToCard(col: String, sym: String) -> Card {
        var card: Card
        switch col {
        case "g":
            switch sym {
            case "p":
                card = .Normal(.Psi, .Green)
            case "a":
                card = .Normal(.A, .Green)
            case "x":
                card = .Normal(.Xi, .Green)
            default:
                card = .Normal(.E, .Green)
            }
        case "y":
            switch sym {
            case "p":
                card = .Normal(.Psi, .Yellow)
            case "a":
                card = .Normal(.A, .Yellow)
            case "x":
                card = .Normal(.Xi, .Yellow)
            default:
                card = .Normal(.E, .Yellow)
            }
        case "p":
            switch sym {
            case "p":
                card = .Normal(.Psi, .Purple)
            case "a":
                card = .Normal(.A, .Purple)
            case "x":
                card = .Normal(.Xi, .Purple)
            default:
                card = .Normal(.E, .Purple)
            }
        default:
            switch sym {
            case "p":
                card = .Normal(.Psi, .Orange)
            case "a":
                card = .Normal(.A, .Orange)
            case "x":
                card = .Normal(.Xi, .Orange)
            default:
                card = .Normal(.E, .Orange)
            }
        }
        return card
    }
    
    func finalShuffle() {
        var last = self.arr.count - 1
        while last > 0 {
            let rand = (Int)(arc4random_uniform(UInt32(last)))
            self.arr.swapAt(last, rand)
            last -= 1
        }
        //            print("Deck prepared. \(self.arr.count) cards available.")
    }
}
