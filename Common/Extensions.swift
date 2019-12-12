//
//  Extensions.swift
//  Psakse
//
//  Created by Daniel Marriner on 07/11/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import Foundation

#if os(macOS)
    import AppKit
    typealias View = NSView
    typealias Color = NSColor
    typealias Image = NSImage
    typealias Button = NSButton
#elseif os(iOS)
    import UIKit
    typealias View = UIView
    typealias Color = UIColor
    typealias Image = UIImage
    typealias Button = UIButton
#endif

public extension Array where Element == Int {
    func contentsToString() -> String {
        var tmp = ""
        for i in self {
            tmp += String(i)
        }
        return tmp
    }
}

extension GameViewController {
    
    func resetGame() {
        gameComplete = false
        deck = Deck()
        state = []
        fixedTiles = []
        if let grid = grid {
            // Reset all buttons in main and side grids
            grid.reset()
        } else {
            // Create main and side grids with all buttons
            grid = Grid(gridSize: gridSize, mainGrid: mainGrid, subGrid: subGrid)
            for button in grid!.buttonGrid {
                button.setTarget(controller: self, #selector(select))
            }
            
            // Create in game controls
            if let _ = puzzleID {
                setupButtonView(button: backView, title: "Back", color: .Orange, action: #selector(goToSelect))
                setupButtonView(button: newView, title: "Reset", color: .Purple, action: #selector(newGame))
            } else {
                setupButtonView(button: backView, title: "Home", color: .Orange, action: #selector(goToHome))
                setupButtonView(button: newView, title: "New Game", color: .Purple, action: #selector(newGame))
            }
            setupButtonView(button: undoView, title: "Undo", color: .Green, action: #selector(restoreState))
            setupButtonView(button: resetView, title: "Reset", color: .Yellow, action: #selector(resetState))
        }
        
        // Create deck from override or procedurally
        if let puzzle = override {
            var locked = puzzle.dropLast(17)
            for _ in 0..<3 {
                let pos = Int(String(locked.removeFirst()) + String(locked.removeFirst()))!
                let col = String(locked.removeFirst())
                let sym = String(locked.removeFirst())
                let card = deck!.stringToCard(col: col, sym: sym)
                setCard(atLocation: pos, card: card)
                grid!.buttonGrid[pos].setBorder(width: 3, color: .yellow)
                grid!.buttonGrid[pos].isEnabled = false
                grid!.grid[pos] = card
                fixedTiles.append(pos)
            }
            deck!.arr = deck!.createDeckFromString(string: String(puzzle.dropFirst(12)))
        } else {
            deck!.populateDeck()
            deck!.finalShuffle()
            deck!.removeCards(gridSize: gridSize, wildcards: wildcards)
            // three random starting cards section
            for _ in 1...3 {
                var randPosition = UInt32(gridSize * gridSize)
                while fixedTiles.contains(Int(randPosition)) ||
                    randPosition == gridSize * gridSize ||
                    fixedTiles.contains(Int(randPosition) - 1) ||
                    fixedTiles.contains(Int(randPosition) + 1) ||
                    fixedTiles.contains(Int(randPosition) - gridSize) ||
                    fixedTiles.contains(Int(randPosition) + gridSize) {
                        randPosition = arc4random_uniform(UInt32(gridSize * gridSize - 1))
                        if randPosition == 0 {
                            randPosition = 1
                        }
                }
                fixedTiles.append(Int(randPosition))
            }
            for i in fixedTiles {
                let image = deck!.arr[0].getFilename()
                let bgcolor = deck!.arr[0].getColor()
                grid!.buttonGrid[i].setAttrs(image: Image(named: image), bgColor: bgcolor)
                grid!.buttonGrid[i].setBorder(width: 3, color: .yellow)
                grid!.buttonGrid[i].isEnabled = false
                grid!.grid[i] = deck!.arr[0]
                let card = deck!.arr.removeFirst()
                deck!.updateQuantities(card: card)
                puzzleSig += (i < 10 ? "0" : "") + String(i) + card.getID()
            }
            puzzleSig += deck!.cardQuantities.contentsToString()
            //
            
            deck!.addWildCards(count: wildcards)
        }
        
        // Shuffle deck and set draw tile
        deck!.finalShuffle()
        setCard(atLocation: (gridSize * gridSize), card: deck?.arr[0])
    }
    
    @objc func select(sender: Button!) {
        if let currentActiveCard = activeCard {
            // if sender == gridSize^2 or sender == lastSelected
            // deselect
            // else if sender empty
            // try move()
            // else
            // try swap()
            if sender.tag == (gridSize * gridSize) || sender.tag == lastSelected {
                // If location is card location or deck location deselect
                deselect()
            } else {
                let location = sender.tag
                if grid!.grid[location] == nil {
                    // If location empty try move
                    if checker(position: location, card: currentActiveCard) || location > (gridSize * gridSize) {
                        // If no tile conflicts place card
                        saveState()
                        setCard(atLocation: location, card: currentActiveCard)
                        // clear previous location
                        clearTile(position: lastSelected)
                    } else {
                        // Warn of tile move conflict
                        moveConflictWarning()
                    }
                    deselect()
                    if deck!.arr.count == 0 {
                        // If deck empty check grid full
                        var arr: [Bool] = grid!.grid.map({ $0 != nil })
                        arr.removeLast(5)
                        if !arr.contains(false) {
                            // If grid full, game is complete
                            gameComplete = true
                            if let id = puzzleID {
                                UserDefaults.standard.set(true, forKey: "\(id)")
                            } else {
                                sendToServer(puzzle: puzzleSig)
                            }
                            for i in grid!.buttonGrid {
                                i.isEnabled = false
                            }
                            puzzleCompleteAlert()
                        }
                    }
                } else {
                    // If location not empty try swap
                    if lastSelected != (gridSize * gridSize) {
                        // If last selected card was not from the deck
                        if (checker(position: lastSelected, card: grid!.grid[location]!) || lastSelected > (gridSize * gridSize)) && (checker(position: location, card: currentActiveCard) ||  location > (gridSize * gridSize)) {
                            // If cards won't conflict when swapped, swap cards
                            saveState()
                            setCard(atLocation: lastSelected, card: grid?.grid[location])
                            setCard(atLocation: location, card: currentActiveCard)
                        } else {
                            // Warn of tile swap conflict
                            swapConflictWarning()
                        }
                    }
                    deselect()
                }
            }
        } else {
            // set card to active
            // set border
            // lastSelected = tag
            let location = sender.tag
            if let selectedCard = grid!.grid[location] {
                activeCard = selectedCard
                grid!.buttonGrid[location].setBorder(width: 3, color: .black)
            }
            lastSelected = location
        }
    }
    
    func deselect() {
        activeCard = nil
        grid!.buttonGrid[lastSelected].setBorder(width: 0, color: .black)
        lastSelected = -1
    }
    
    func setCard(atLocation location: Int, card: Card?) {
        if let card = card {
            grid?.grid[location] = card
            grid?.buttonGrid[location].setAttrs(image: Image(named: card.getFilename()), bgColor: card.getColor())
            grid?.buttonGrid[location].setBorder(width: 0, color: .black)
        } else {
            grid?.grid[location] = nil
            grid?.buttonGrid[location].setAttrs(image: nil, bgColor: .white)
            grid?.buttonGrid[location].setBorder(width: 0, color: .black)
        }
    }
    
    func clearTile(position: Int) {
        if position == (gridSize * gridSize) {
            deck!.arr.removeFirst()
            if deck!.arr.count >= 1 {
                setCard(atLocation: (gridSize * gridSize), card: deck?.arr[0])
            } else {
                grid!.grid[(gridSize * gridSize)] = nil
                grid!.buttonGrid[(gridSize * gridSize)].setAttrs(image: Image(named: "none.png"), bgColor: .white)
                grid!.buttonGrid[(gridSize * gridSize)].isEnabled = false
            }
        } else {
            setCard(atLocation: position, card: nil)
        }
    }
    
    func checker(position: Int, card: Card) -> Bool {
        func checkTile(position: Int, card: Card) -> Bool {
            if position > (gridSize * gridSize) { return true }
            if let placedCard = grid!.grid[position] {
                return card.matches(other: placedCard)
            } else { return true }
        }
        func left(x: Int) -> Int { return x + 1 }
        func right(x: Int) -> Int { return x - 1 }
        func up(x: Int) -> Int { return x + gridSize }
        func down(x: Int) -> Int { return x - gridSize }
        
        if position < gridSize {
            if position == 0 {
                // Bottom right corner; check tiles left and above
                if !checkTile(position: left(x: position), card: card) { return false }
                if !checkTile(position: up(x: position), card: card) { return false }
            } else if position == gridSize - 1 {
                // Bottom left corner; check tiles right and above
                if !checkTile(position: right(x: position), card: card) { return false }
                if !checkTile(position: up(x: position), card: card) { return false }
            } else {
                // Bottom edge; check tiles left, right and above
                if !checkTile(position: left(x: position), card: card) { return false }
                if !checkTile(position: right(x: position), card: card) { return false }
                if !checkTile(position: up(x: position), card: card) { return false }
            }
        } else if position % gridSize == 0 {
            if position == gridSize * (gridSize - 1) {
                // Top right corner; check tiles left and below
                if !checkTile(position: left(x: position), card: card) { return false }
                if !checkTile(position: down(x: position), card: card) { return false }
            } else {
                // Right edge; check tiles left, above and below
                if !checkTile(position: left(x: position), card: card) { return false }
                if !checkTile(position: up(x: position), card: card) { return false }
                if !checkTile(position: down(x: position), card: card) { return false }
            }
        } else if position % gridSize == gridSize - 1 {
            if position == (gridSize * gridSize) - 1 {
                // Top left corner; check tiles right and below
                if !checkTile(position: right(x: position), card: card) { return false }
                if !checkTile(position: down(x: position), card: card) { return false }
            } else {
                // Left edge; check tiles right, above and below
                if !checkTile(position: right(x: position), card: card) { return false }
                if !checkTile(position: up(x: position), card: card) { return false }
                if !checkTile(position: down(x: position), card: card) { return false }
            }
        } else if position > gridSize * (gridSize - 1) {
            // Top edge; check tiles left, right and below
            if !checkTile(position: left(x: position), card: card) { return false }
            if !checkTile(position: right(x: position), card: card) { return false }
            if !checkTile(position: down(x: position), card: card) { return false }
        } else {
            // Central tile; check tiles left, right, above and below
            if !checkTile(position: left(x: position), card: card) { return false }
            if !checkTile(position: right(x: position), card: card) { return false }
            if !checkTile(position: up(x: position), card: card) { return false }
            if !checkTile(position: down(x: position), card: card) { return false }
        }
        return true
    }
        
    func saveState() {
        var gridState: [Card?] = []
        grid?.grid.forEach { card in
            gridState.append(card)
        }
        state.append(State(grid: gridState, deck: deck!.arr))
    }
    
    @objc func restoreState() {
        let prevState = state.popLast()
        if let currentState = prevState {
            activeCard = nil
            lastSelected = -1
            for i in 0..<grid!.grid.count {
                setCard(atLocation: i, card: currentState.grid[i])
            }
            deck?.arr = currentState.deck
            grid!.buttonGrid[gridSize * gridSize].isEnabled = true
            for i in fixedTiles {
                grid?.buttonGrid[i].setBorder(width: 3, color: .yellow)
            }
        }
    }
    
    @objc func resetState() {
        if state.count >= 1 {
            let currentState = state[0]
            activeCard = nil
            lastSelected = -1
            for i in 0..<grid!.grid.count {
                setCard(atLocation: i, card: currentState.grid[i])
            }
            deck?.arr = currentState.deck
            grid!.buttonGrid[gridSize * gridSize].isEnabled = true
            for i in fixedTiles {
                grid?.buttonGrid[i].setBorder(width: 3, color: .yellow)
            }
            state = []
        }
    }
    
    func sendToServer(puzzle: String) {
        if let location = Bundle.main.url(forResource: "link", withExtension: "txt") {
            do {
                let tmp = try String(contentsOf: location)
                print(tmp)
                if tmp == "" {
                    return
                }
                let url = URL(string: tmp.trimmingCharacters(in: CharacterSet.newlines))!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                let session = URLSession.shared
                let data = "string=" + puzzleSig
                request.httpBody = data.data(using: .utf8)
                let task = session.dataTask(with: request) {data, response, error in
                    if let data = data, let dataString = String(data: data, encoding: .utf8) {
                        print(dataString)
                    }
                }
                task.resume()
            } catch {
                return
            }
        }
    }
}

extension SelectViewController {
    
    func getJson() {
        let x = URL(string: "https://anachronistic-tech.co.uk/projects/psakse/get_puzzles.php")!
        let request = NSMutableURLRequest(url: x)
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if error != nil {} else {
                if let unwrappedData = data {
                    let decoder = JSONDecoder()
                    self.tableData = try! decoder.decode([Puzzle].self, from: unwrappedData)
                    self.tableData.sort{ (lhs: Puzzle, rhs: Puzzle) -> Bool in
                        return Int(lhs.numID)! < Int(rhs.numID)!
                    }
                    DispatchQueue.main.sync(execute: {
                        self.challengeView.reloadData()
                    })
                }
            }
        }
        task.resume()
    }
}
