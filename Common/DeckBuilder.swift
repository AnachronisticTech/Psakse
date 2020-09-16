//
//  DeckBuilder.swift
//  Psakse
//
//  Created by Daniel Marriner on 29/06/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import Foundation

class DeckBuilder {
    enum Operation: Equatable {
        case new
        case createFrom(String)
        case shuffle
        case addWildcards(Int)
        case removeCards(Int)
        case removeSize(Int, Int)
    }
    
    fileprivate var operations = [Operation]()
    
    static let allCards: [Card] = [
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
        .Normal(.E, .Orange)
    ]
    
    func new() -> DeckBuilder {
        guard operations.count == 0 else { return self }
        operations.append(.new)
        return self
    }
    
    func createFrom(string: String) -> DeckBuilder {
        guard operations.count == 0 else { return self }
        operations.append(.createFrom(string))
        return self
    }
    
    func shuffle() -> DeckBuilder {
        guard operations.count > 0 else { return self }
        operations.append(.shuffle)
        return self
    }
    
    func addWildcards(_ quantity: Int) -> DeckBuilder {
        guard operations.count > 0 else { return self }
        operations.append(.addWildcards(quantity))
        return self
    }
    
    func removeCards(_ quantity: Int) -> DeckBuilder {
        guard operations.count > 0, operations.contains(where: {$0 == .new}) else { return self }
        operations.append(.removeCards(quantity))
        return self
    }
    
    func remove(to size: Int, withSpaceFor wildcards: Int) -> DeckBuilder {
        guard operations.count > 0, operations.contains(where: {$0 == .new}) else { return self }
        operations.append(.removeSize(size, wildcards))
        return self
    }
    
    func build() -> [Card] {
        var deck = [Card]()
        for operation in operations {
            switch operation {
                case .new:
                    for card in DeckBuilder.allCards {
                        deck.append(card)
                        deck.append(card)
                    }
                case .createFrom(var string):
                    for i in 0..<DeckBuilder.allCards.count {
                        let quantity = Int(String(string.removeFirst()))
                        deck += Array.init(repeating: DeckBuilder.allCards[i], count: quantity!)
                    }
                case .shuffle:
                    deck.shuffle()
                case .addWildcards(let quantity):
                    for _ in 0..<quantity { deck.append(.Wild) }
                case .removeCards(let quantity):
                    deck.removeLast(quantity)
                case .removeSize(let size, let wild):
                    let total = deck.count - (size ^^ 2) + wild
                    deck.removeLast(total)
            }
        }
        return deck
    }
    
    static func card(_ color: String, _ symbol: String) -> Card {
        func sym(_ sym: String) -> GameSymbol {
            switch sym {
                case "p": return .Psi
                case "a": return .A
                case "x": return .Xi
                default : return .E
            }
        }
        func col(_ col: String) -> GameColor {
            switch col {
                case "g": return .Green
                case "y": return .Yellow
                case "p": return .Purple
                default : return .Orange
            }
        }
        return .Normal(sym(symbol), col(color))
    }
}
