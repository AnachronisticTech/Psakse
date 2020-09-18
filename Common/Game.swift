//
//  Game.swift
//  Psakse
//
//  Created by Daniel Marriner on 14/09/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import Foundation

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence
func ^^ (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

class Game {
    let gridsize: Int
    
    var deck: [Card] = [] {
        didSet { deckDidChange() }
    }
    
    var board: [Card?] {
        didSet { boardDidChange() }
    }
    
    var fixedLocations: [Int] = []
    
    var isComplete = false {
        didSet { if isComplete { didWinGame() } }
    }
    
    var activeCard: Card? = nil {
        didSet {
            if activeCard == nil {
                didDeselectCard(at: lastSelected)
                lastSelected = -1
            }
        }
    }
    
    var lastSelected = -1 {
        didSet {
            if lastSelected != -1 {
                didSelectCard(at: lastSelected)
            }
        }
    }
    
    private var observations = [ObjectIdentifier : Observation]()
    
    init(_ gridsize: Int = 5) {
        self.gridsize = gridsize
        self.board = Array.init(repeating: nil, count: (gridsize ^^ 2) + 4)
        
        // generate deck
        var tempDeck = DeckBuilder()
            .new()
            .shuffle()
            .remove(to: gridsize, withSpaceFor: 2)
            .addWildcards(2)
            .shuffle()
            .build()
        
        for _ in 1...3 {
            var fixed = gridsize ^^ 2
            while fixedLocations.contains(fixed) ||
                fixed == gridsize ^^ 2 ||
                fixedLocations.contains(fixed - 1) ||
                fixedLocations.contains(fixed + 1) ||
                fixedLocations.contains(fixed - gridsize) ||
                fixedLocations.contains(fixed + gridsize) {
                    fixed = Int.random(in: 1..<(gridsize ^^ 2))
            }
            fixedLocations.append(fixed)
            while tempDeck[0] == .Wild { tempDeck.shuffle() }
            board[fixed] = tempDeck.removeFirst()
        }
        tempDeck.shuffle()
        self.deck = tempDeck
    }
    
    init(with puzzle: Puzzle) {
        let properties = puzzle.gameProperties()

        self.gridsize = properties.size
        self.board = Array.init(repeating: nil, count: (gridsize ^^ 2) + 4)
        
        // generate deck
        var tempDeck = DeckBuilder()
            .createFrom(string: properties.deck)
            .addWildcards(properties.wild)
            .shuffle()
            .build()

        for i in 0..<properties.fixed.count {
            var locked = properties.fixed[i]
            let fixed = Int(String(locked.removeFirst()) + String(locked.removeFirst()))!
            let color = String(locked.removeFirst())
            let symbol = String(locked.removeFirst())
            let card = DeckBuilder.card(color, symbol)
            fixedLocations.append(fixed)
            board[fixed] = card
        }
        tempDeck.shuffle()
        self.deck = tempDeck
    }
    
    func checkBefore(placing card: Card, at position: Int) -> Bool {
        func isValid(placing: Card, at position: Int) -> Bool {
            if position > (gridsize * gridsize) { return true }
            if let placedCard = board[position] {
                return card.matches(other: placedCard)
            } else { return true }
        }
        func left(x: Int) -> Int { return x + 1 }
        func right(x: Int) -> Int { return x - 1 }
        func up(x: Int) -> Int { return x + gridsize }
        func down(x: Int) -> Int { return x - gridsize }
        
        if position < gridsize {
            if position == 0 {
                // Bottom right corner; check tiles left and above
                if !isValid(placing: card, at: left(x: position)) { return false }
                if !isValid(placing: card, at: up(x: position)) { return false }
            } else if position == gridsize - 1 {
                // Bottom left corner; check tiles right and above
                if !isValid(placing: card, at: right(x: position)) { return false }
                if !isValid(placing: card, at: up(x: position)) { return false }
            } else {
                // Bottom edge; check tiles left, right and above
                if !isValid(placing: card, at: left(x: position)) { return false }
                if !isValid(placing: card, at: right(x: position)) { return false }
                if !isValid(placing: card, at: up(x: position)) { return false }
            }
        } else if position % gridsize == 0 {
            if position == gridsize * (gridsize - 1) {
                // Top right corner; check tiles left and below
                if !isValid(placing: card, at: left(x: position)) { return false }
                if !isValid(placing: card, at: down(x: position)) { return false }
            } else {
                // Right edge; check tiles left, above and below
                if !isValid(placing: card, at: left(x: position)) { return false }
                if !isValid(placing: card, at: up(x: position)) { return false }
                if !isValid(placing: card, at: down(x: position)) { return false }
            }
        } else if position % gridsize == gridsize - 1 {
            if position == (gridsize * gridsize) - 1 {
                // Top left corner; check tiles right and below
                if !isValid(placing: card, at: right(x: position)) { return false }
                if !isValid(placing: card, at: down(x: position)) { return false }
            } else {
                // Left edge; check tiles right, above and below
                if !isValid(placing: card, at: right(x: position)) { return false }
                if !isValid(placing: card, at: up(x: position)) { return false }
                if !isValid(placing: card, at: down(x: position)) { return false }
            }
        } else if position > gridsize * (gridsize - 1) {
            // Top edge; check tiles left, right and below
            if !isValid(placing: card, at: left(x: position)) { return false }
            if !isValid(placing: card, at: right(x: position)) { return false }
            if !isValid(placing: card, at: down(x: position)) { return false }
        } else {
            // Central tile; check tiles left, right, above and below
            if !isValid(placing: card, at: left(x: position)) { return false }
            if !isValid(placing: card, at: right(x: position)) { return false }
            if !isValid(placing: card, at: up(x: position)) { return false }
            if !isValid(placing: card, at: down(x: position)) { return false }
        }
        return true
    }
    
    func selectCard(at index: Int) {
        if let card = activeCard {
            // if index == lastSelected or -2
            // deselect
            // else if sender empty
            // try move()
            // else
            // try swap()
            if index == lastSelected || index == -2 {
                // If location is card location or deck deselect
                activeCard = nil
            } else {
                if board[index] == nil {
                    // If location empty try move
                    if checkBefore(placing: card, at: index) || index >= gridsize ^^ 2 {
                        // If no tile conflicts place card
                        board[index] = card
                        
                        if lastSelected == -2 && deck.count > 0 {
                            // If card was from deck, remove
                            deck.removeFirst()
                        } else {
                            // clear previous location
                            board[lastSelected] = nil
                        }
                    } else {
                        // warn of tile move conflict (observer)
                        didDetectMoveConflict()
                    }
                    activeCard = nil
                    if deck.count == 0 {
                        // If deck empty check grid full
                        var arr: [Bool] = board.map({ $0 != nil })
                        arr.removeLast(4)
                        // If grid full, game is complete
                        isComplete = !arr.contains(false)
                    }
                } else {
                    // If location not empty try swap
                    if lastSelected != -2 {
                        // If last selected card was not from the deck
                        if (checkBefore(placing: board[index]!, at: lastSelected) || lastSelected >= gridsize ^^ 2) && (checkBefore(placing: card, at: index) || index >= gridsize ^^ 2) {
                            // If cards won't conflict when swapped, swap cards
                            board[lastSelected] = board[index]!
                            board[index] = card
                        } else {
                            // Warn of tile swap conflict (observer)
                            didDetectSwapConflict()
                        }
                    }
                    activeCard = nil
                }
            }
        } else {
            // set card to active
            if index == -2, let card = deck.first {
                activeCard = card
                lastSelected = index
            } else if let selected = board[index] {
                activeCard = selected
                lastSelected = index
            }
        }
    }
    
    func generateProperties() -> String {
        let fixedTiles = fixedLocations.map({ ($0).twoDigitPad() + board[$0]!.id }).contentsToString()
        var cards = Array(repeating: 0, count: DeckBuilder.allCards.count)
        for index in 0..<board.count {
            guard let card = board[index], card != .Wild else { continue }
            if fixedLocations.contains(index) { continue }
            guard let i = DeckBuilder.allCards.firstIndex(of: card) else { continue }
            cards[Int(i)] += 1
        }
        let remaining = cards.contentsToString()
        return fixedTiles + remaining
    }

}

extension Game {
    struct Observation {
        weak var observer: GameObserver?
    }
    
    func deckDidChange() {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            observer.gameDeckDidChange(self)
        }
    }
    
    func boardDidChange() {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            observer.gameBoardDidChange(self)
        }
    }
    
    func didSelectCard(at index: Int) {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            observer.game(self, didSelectCardAt: index)
        }
    }
    
    func didDeselectCard(at index: Int) {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            observer.game(self, didDeselectCardAt: index)
        }
    }
    
    func didWinGame() {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            observer.gameDidComplete(self)
        }
    }
    
    func didDetectSwapConflict() {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            observer.gameDidDetectSwapConflict(self)
        }
    }
    
    func didDetectMoveConflict() {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            observer.gameDidDetectMoveConflict(self)
        }
    }
}

extension Game {
    func addObserver(_ observer: GameObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }

    func removeObserver(_ observer: GameObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}

protocol GameObserver: class {
    func gameDeckDidChange(_ game: Game)
    
    func gameBoardDidChange(_ game: Game)
    
    func game(_ game: Game, didSelectCardAt index: Int)
    
    func game(_ game: Game, didDeselectCardAt index: Int)
    
    func gameDidComplete(_ game: Game)
    
    func gameDidDetectSwapConflict(_ game: Game)
    
    func gameDidDetectMoveConflict(_ game: Game)
}

extension GameObserver {
    func gameDeckDidChange(_ game: Game) {}
    
    func gameBoardDidChange(_ game: Game) {}
    
    func game(_ game: Game, didSelectCardAt index: Int) {}
    
    func game(_ game: Game, didDeselectCardAt index: Int) {}
    
    func gameDidComplete(_ game: Game) {}
    
    func gameDidDetectSwapConflict(_ game: Game) {}
    
    func gameDidDetectMoveConflict(_ game: Game) {}
}
