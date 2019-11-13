//
//  GameViewController.swift
//  Psakse
//
//  Created by Daniel Marriner on 24/12/2018.
//  Copyright © 2018 Daniel Marriner. All rights reserved.
//

import AppKit
import CoreGraphics

class GameViewController: NSViewController {
    
    let gridSize = 5
    let wildcards = 2
//    var numberSymbols = 4
//    var numberColors = 4
    var grid:Grid? = nil
    var deck:Deck? = nil
    var activeCard:Card? = nil
    var lastSelected = -1
    var gameComplete = false
    var puzzleID: String? = nil
    var override: String? = nil
    var puzzleSig: String = ""
    
    @IBOutlet weak var mainGrid: NSView!
    @IBOutlet weak var subGrid: NSView!
    @IBOutlet weak var backView: NSButton!
    @IBOutlet weak var newView: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = 500
        let height = 750
        self.view.window?.setFrame(NSRect(x: 0, y: 0, width: width, height: height), display: true)
        let layer = CALayer()
        layer.backgroundColor = NSColor.white.cgColor
        self.view.layer = layer
        
        // Do any additional setup after loading the view, typically from a nib.
        resetGame()
    }
    
    func setupButtonView(button: NSButton, title: String, color: Colors, action: Selector) {
        let layer = CALayer()
        layer.backgroundColor = color.getColor().cgColor
        let text = CATextLayer()
        text.string = title
        text.frame = CGRect(x: 0, y: button.bounds.height / 2.7, width: button.bounds.width, height: button.bounds.height)
        let CGR = NSClickGestureRecognizer(target: self, action: action)
        button.addGestureRecognizer(CGR)
        text.foregroundColor = NSColor.darkGray.cgColor
        text.fontSize = 16
        text.alignmentMode = .center
        layer.addSublayer(text)
        layer.cornerRadius = 10
        button.layer = layer
        button.setBorder(width: 3, color: .darkGray)
    }
    
    func resetGame() {
        gameComplete = false
        deck = Deck()
        if let grid = grid {
            // Reset all buttons in main and side grids
            grid.reset()
        } else {
            // Create main and side grids with all buttons
            grid = Grid(gridSize: gridSize, mainGrid: mainGrid, subGrid: subGrid)
            mainGrid.layer = CALayer()
            mainGrid.layer?.backgroundColor = .black
            subGrid.layer = CALayer()
            subGrid.layer?.backgroundColor = .black
            for button in grid!.buttonGrid {
                button.action = #selector(select(sender:))
            }
            
            // Create in game controls
            if let _ = puzzleID {
                setupButtonView(button: backView, title: "Back", color: .Orange, action: #selector(goToSelect))
                setupButtonView(button: newView, title: "Reset", color: .Purple, action: #selector(newGame))
            } else {
                setupButtonView(button: backView, title: "Home", color: .Orange, action: #selector(goToHome))
                setupButtonView(button: newView, title: "New Game", color: .Purple, action: #selector(newGame))
            }
        }
        
        // Create deck from override or procedurally
        if let puzzle = override {
            var locked = puzzle.dropLast(17)
            for _ in 0..<3 {
                let pos = Int(String(locked.removeFirst()) + String(locked.removeFirst()))
                let col = String(locked.removeFirst())
                let sym = String(locked.removeFirst())
                let card = deck!.stringToCard(col: col, sym: sym)
                let image = card.getFilename()
                let bgcolor = card.getColor()
                grid!.buttonGrid[pos!].setAttrs(image: NSImage(named: image), bgColor: bgcolor)
                grid!.buttonGrid[pos!].setBorder(width: 3, color: .yellow)
                grid!.buttonGrid[pos!].isEnabled = false
                grid!.grid[pos!] = card
            }
            deck!.arr = deck!.createDeckFromString(string: String(puzzle.dropFirst(12)))
        } else {
            deck!.populateDeck()
            deck!.finalShuffle()
            deck!.removeCards(gridSize: gridSize, wildcards: wildcards)
            // three random starting cards section
            var randArray = [Int]()
            for _ in 1...3 {
                var randPosition = UInt32(gridSize * gridSize)
                while randArray.contains(Int(randPosition)) ||
                    randPosition == gridSize * gridSize ||
                    randArray.contains(Int(randPosition) - 1) ||
                    randArray.contains(Int(randPosition) + 1) ||
                    randArray.contains(Int(randPosition) - gridSize) ||
                    randArray.contains(Int(randPosition) + gridSize) {
                        randPosition = arc4random_uniform(UInt32(gridSize * gridSize - 1))
                        if randPosition == 0 {
                            randPosition = 1
                        }
                }
                randArray.append(Int(randPosition))
            }
            for i in randArray {
                let image = deck!.arr[0].getFilename()
                let bgcolor = deck!.arr[0].getColor()
                grid!.buttonGrid[i].setAttrs(image: NSImage(named: image), bgColor: bgcolor)
                grid!.buttonGrid[i].setBorder(width: 5, color: .yellow)
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
        let image = deck!.arr[0].getFilename()
        let bgcolor = deck!.arr[0].getColor()
        grid!.grid[(gridSize * gridSize)] = deck!.arr[0]
        grid!.buttonGrid[(gridSize * gridSize)].setAttrs(image: NSImage(named: image), bgColor: bgcolor)
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
    
    @objc func select(sender: NSButton!) {
        let btnsender: NSButton = sender
        if let currentActiveCard = activeCard {
            // if sender == gridSize^2 or sender == lastSelected
            // deselect
            // else if sender empty
            // try move()
            // else
            // try swap()
            if btnsender.tag == (gridSize * gridSize) || btnsender.tag == lastSelected {
                deselect()
            } else {
                let location = btnsender.tag
                if grid!.grid[location] == nil {
                    // try move
                    if checker(position: location, card: currentActiveCard) || location > (gridSize * gridSize) {
                        grid!.grid[location] = activeCard
                        grid!.buttonGrid[location].setAttrs(image: NSImage(named: currentActiveCard.getFilename()), bgColor: currentActiveCard.getColor())
                        // clear previous
                        clearTile(position: lastSelected)
                    } else {
                        let alertView = NSAlert()
                        alertView.alertStyle = .warning
                        alertView.messageText = "That tile can't be placed there"
                        alertView.addButton(withTitle: "Ok")
                        alertView.runModal()
                    }
                    deselect()
                    if deck!.arr.count == 0 {
                        var arr: [Bool] = grid!.grid.map({ $0 != nil })
                        arr.removeLast(5)
                        if !arr.contains(false)  {
                            gameComplete = true
                            if let id = puzzleID {
                                UserDefaults.standard.set(true, forKey: "\(id)")
                            } else {
                                sendToServer(puzzle: puzzleSig)
                            }
                            for i in grid!.buttonGrid {
                                i.isEnabled = false
                            }
                            let alertView = NSAlert()
                            alertView.alertStyle = .warning
                            alertView.messageText = "Puzzle complete!"
                            alertView.informativeText = "You solved the puzzle! Would you like to play again?"
                            alertView.addButton(withTitle: "Yes")
                            alertView.addButton(withTitle: "No")
                            let result = alertView.runModal()
                            switch result {
                            case NSApplication.ModalResponse.alertFirstButtonReturn:
                                self.resetGame()
                            default: return
                            }
                        }
                    }
                } else {
                    // try swap
                    if lastSelected != (gridSize * gridSize) {
                        if (checker(position: lastSelected, card: grid!.grid[location]!) || lastSelected > (gridSize * gridSize)) && (checker(position: location, card: activeCard!) ||  location > (gridSize * gridSize)) {
                            grid!.grid[lastSelected] = grid!.grid[location]
                            var image = grid!.grid[lastSelected]!.getFilename()
                            var color = grid!.grid[lastSelected]!.getColor()
                            grid!.buttonGrid[lastSelected].setAttrs(image: NSImage(named: image), bgColor: color)
                            grid!.buttonGrid[lastSelected].setBorder(width: 0, color: .black)
                            grid!.grid[location] = activeCard
                            image = grid!.grid[location]!.getFilename()
                            color = grid!.grid[location]!.getColor()
                            grid!.buttonGrid[location].setAttrs(image: NSImage(named: image), bgColor: color)
                            grid!.buttonGrid[location].setBorder(width: 0, color: .black)
                        } else {
                            let alertView = NSAlert()
                            alertView.alertStyle = .warning
                            alertView.messageText = "Those tiles can't be swapped."
                            alertView.addButton(withTitle: "Ok")
                            alertView.runModal()
                        }
                    }
                    deselect()
                }
            }
        } else {
            // set card to active
            // set border
            // lastSelected = tag
            let location = btnsender.tag
            if let selectedCard = grid!.grid[location] {
                activeCard = selectedCard
                grid!.buttonGrid[location].setBorder(width: 3, color: .black)
            }
            lastSelected = btnsender.tag
        }
    }
    
    func deselect() {
        activeCard = nil
        grid!.buttonGrid[lastSelected].setBorder(width: 0, color: .black)
        lastSelected = -1
    }
    
    func clearTile(position: Int) {
        if position == (gridSize * gridSize) {
            deck!.arr.removeFirst()
            if deck!.arr.count >= 1 {
                let image = deck!.arr[0].getFilename()
                let color = deck!.arr[0].getColor()
                grid!.grid[(gridSize * gridSize)] = deck!.arr[0]
                grid!.buttonGrid[(gridSize * gridSize)].setAttrs(image: NSImage(named: image), bgColor: color)
            } else {
                grid!.grid[(gridSize * gridSize)] = nil
                grid!.buttonGrid[(gridSize * gridSize)].setAttrs(image: NSImage(named: "none.png"), bgColor: .white)
                grid!.buttonGrid[(gridSize * gridSize)].isEnabled = false
            }
        } else {
            grid!.grid[position] = nil
            grid!.buttonGrid[position].setAttrs(image: nil, bgColor: .white)
        }
    }
    
    func left(x: Int) -> Int {
        return x + 1
    }
    func right(x: Int) -> Int {
        return x - 1
    }
    func up(x: Int) -> Int {
        return x + gridSize
    }
    func down(x: Int) -> Int {
        return x - gridSize
    }
    
    func checker(position: Int, card: Card) -> Bool {
        var validArray = [Bool]()
        if position < gridSize {
            if position == 0 {
                // Bottom right corner; check tiles left and above
                validArray.append(checkTile(position: left(x: position), card: card))
                validArray.append(checkTile(position: up(x: position), card: card))
            } else if position == gridSize - 1 {
                // Bottom left corner; check tiles right and above
                validArray.append(checkTile(position: right(x: position), card: card))
                validArray.append(checkTile(position: up(x: position), card: card))
            } else {
                // Bottom edge; check tiles left, right and above
                validArray.append(checkTile(position: left(x: position), card: card))
                validArray.append(checkTile(position: right(x: position), card: card))
                validArray.append(checkTile(position: up(x: position), card: card))
            }
        } else if position % gridSize == 0 {
            if position == gridSize * (gridSize - 1) {
                // Top right corner; check tiles left and below
                validArray.append(checkTile(position: left(x: position), card: card))
                validArray.append(checkTile(position: down(x: position), card: card))
            } else {
                // Right edge; check tiles left, above and below
                validArray.append(checkTile(position: left(x: position), card: card))
                validArray.append(checkTile(position: up(x: position), card: card))
                validArray.append(checkTile(position: down(x: position), card: card))
            }
        } else if position % gridSize == gridSize - 1 {
            if position == (gridSize * gridSize) - 1 {
                // Top left corner; check tiles right and below
                validArray.append(checkTile(position: right(x: position), card: card))
                validArray.append(checkTile(position: down(x: position), card: card))
            } else {
                // Left edge; check tiles right, above and below
                validArray.append(checkTile(position: right(x: position), card: card))
                validArray.append(checkTile(position: up(x: position), card: card))
                validArray.append(checkTile(position: down(x: position), card: card))
            }
        } else if position > gridSize * (gridSize - 1) {
            // Top edge; check tiles left, right and below
            validArray.append(checkTile(position: left(x: position), card: card))
            validArray.append(checkTile(position: right(x: position), card: card))
            validArray.append(checkTile(position: down(x: position), card: card))
        } else {
            // Central tile; check tiles left, right, above and below
            validArray.append(checkTile(position: left(x: position), card: card))
            validArray.append(checkTile(position: right(x: position), card: card))
            validArray.append(checkTile(position: up(x: position), card: card))
            validArray.append(checkTile(position: down(x: position), card: card))
        }
        return !validArray.contains(false)
    }
    
    func checkTile(position: Int, card: Card) -> Bool {
        if position > (gridSize * gridSize) {
            return true
        }
        if let placedCard = grid!.grid[position] {
            return card.matches(other: placedCard)
        } else {
            return true
        }
    }
    
    @objc func newGame() {
        if gameComplete {
            resetGame()
        } else {
            let alertView = NSAlert()
            alertView.alertStyle = .warning
            alertView.messageText = "Puzzle not finished!"
            alertView.informativeText = "Are you sure you want a new puzzle? All progress on this puzzle will be lost."
            alertView.addButton(withTitle: "New Puzzle")
            alertView.addButton(withTitle: "Stay")
            let result = alertView.runModal()
            switch result {
            case NSApplication.ModalResponse.alertFirstButtonReturn:
                self.resetGame()
            default: return
            }
        }
    }
    
    @objc func goToHome() {
        if gameComplete {
            performSegue(withIdentifier: "ToHome", sender: self)
            self.view.window?.windowController?.close()
        } else {
            let alertView = NSAlert()
            alertView.alertStyle = .warning
            alertView.messageText = "Puzzle not finished!"
            alertView.informativeText = "Are you sure you want to quit? All progress on this puzzle will be lost."
            alertView.addButton(withTitle: "Quit")
            alertView.addButton(withTitle: "Stay")
            let result = alertView.runModal()
            switch result {
            case NSApplication.ModalResponse.alertFirstButtonReturn:
                performSegue(withIdentifier: "ToHome", sender: self)
                self.view.window?.windowController?.close()
            default: return
            }
        }
    }
    
    @objc func goToSelect() {
        if gameComplete {
            performSegue(withIdentifier: "ToSelect", sender: self)
            self.view.window?.windowController?.close()
        } else {
            let alertView = NSAlert()
            alertView.alertStyle = .warning
            alertView.messageText = "Puzzle not finished!"
            alertView.informativeText = "Are you sure you want to quit? All progress on this puzzle will be lost."
            alertView.addButton(withTitle: "Quit")
            alertView.addButton(withTitle: "Stay")
            let result = alertView.runModal()
            switch result {
            case NSApplication.ModalResponse.alertFirstButtonReturn:
                performSegue(withIdentifier: "ToSelect", sender: self)
                self.view.window?.windowController?.close()
            default: return
            }
        }
    }
    
}
