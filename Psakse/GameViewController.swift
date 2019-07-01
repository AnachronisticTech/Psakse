//
//  ViewController.swift
//  Psakse-2
//
//  Created by Daniel Marriner on 24/12/2018.
//  Copyright © 2018 Daniel Marriner. All rights reserved.
//

import UIKit
import CoreGraphics

class GameViewController: UIViewController {
    
    let gridSize = 5
    let wildcards = 2
    var numberSymbols = 4
    var numberColors = 4
    var gridExists = false
    var grid:Grid? = nil
    var deck:Deck? = nil
    var activeCard:Card? = nil
    var lastSelected = -1
    var gameComplete = false
    var puzzleID: String? = nil
    var override: String? = nil
    var puzzleSig: String = ""
    let dWidth = UIScreen.main.bounds.width
    let dHeight = UIScreen.main.bounds.height
    let impact = UIImpactFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        resetGame()
    }
    
    func resetGame() {
        gameComplete = false
        deck = Deck()
        if let grid = grid {
            // Reset all buttons in main and side grids
            for i in 0..<grid.buttonGrid.count {
                grid.grid[i] = nil
                grid.buttonGrid[i].reset()
                grid.buttonGrid[i].setAttrs(image: nil, bgColor: .white)
                grid.buttonGrid[i].setBorder(width: 0, color: .black)
                grid.buttonGrid[i].isEnabled = true
            }
        } else {
            // Create main and side grids with all buttons
            grid = Grid(gridSize: gridSize)
            grid!.create(view: self.view)
            for button in grid!.buttonGrid {
                button.reset()
                button.addTarget(self, action: #selector(select), for: .touchUpInside)
                button.setAttrs(image: nil, bgColor: .white)
                button.isEnabled = true
            }
            
            // Create in game controls (TODO: Improve and tidy)
            var x = (Int)(dWidth / 2) + 10
            let y = ((Int)((Double)(dHeight) + ((Double)(dWidth) * 0.9)) / 2) + 40
            var button = UIButton(frame: CGRect(x: x, y: y, width: 80, height: 80))
            button.backgroundColor = Colors.Purple.getColor()
            button.adjustsImageWhenDisabled = false
            if let _ = puzzleID {
                button.setTitle("Reset", for: .normal)
            } else {
                button.setTitle("New Game", for: .normal)
            }
            button.addTarget(self, action: #selector(newGame), for: .touchUpInside)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.setTitleColor(UIColor.darkGray, for: .normal)
            button.setBorder(width: 3, color: .darkGray)
            button.layer.cornerRadius = 10
            self.view.addSubview(button)
            
            x = (Int)(dWidth / 2) - 90
            button = UIButton(frame: CGRect(x: x, y: y, width: 80, height: 80))
            button.backgroundColor = Colors.Orange.getColor()
            button.adjustsImageWhenDisabled = false
            if let _ = puzzleID {
                button.setTitle("Back", for: .normal)
                button.addTarget(self, action: #selector(goToSelect), for: .touchUpInside)
            } else {
                button.setTitle("Home", for: .normal)
                button.addTarget(self, action: #selector(goToHome), for: .touchUpInside)
            }
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.setTitleColor(UIColor.darkGray, for: .normal)
            button.setBorder(width: 3, color: .darkGray)
            button.layer.cornerRadius = 10
            self.view.addSubview(button)
            //
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
                grid!.buttonGrid[pos!].setAttrs(image: UIImage(named: image), bgColor: bgcolor)
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
                grid!.buttonGrid[i].setAttrs(image: UIImage(named: image), bgColor: bgcolor)
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
        let image = deck!.arr[0].getFilename()
        let bgcolor = deck!.arr[0].getColor()
        grid!.grid[(gridSize * gridSize)] = deck!.arr[0]
        grid!.buttonGrid[(gridSize * gridSize)].setAttrs(image: UIImage(named: image), bgColor: bgcolor)
    }
    
    func sendToServer(puzzle: String) {
        if let location = Bundle.main.url(forResource: "link", withExtension: "txt") {
            let tmp = try! String(contentsOf: location)
            print(tmp)
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
        }
    }
    
    @objc func select(sender: UIButton!) {
        let btnsender: UIButton = sender
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
                        grid!.buttonGrid[location].setAttrs(image: UIImage(named: currentActiveCard.getFilename()), bgColor: currentActiveCard.getColor())
                        // clear previous
                        clearTile(position: lastSelected)
                    } else {
                        let alert = UIAlertController(title: nil, message: "That tile can't be placed there.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                        impact.impactOccurred()
                        self.present(alert, animated: true)
                    }
                    deselect()
                    var finishedArray = [Bool]()
                    if deck!.arr.count == 0 {
                        for i in 0..<((gridSize * gridSize) + gridSize) {
                            if i < (gridSize * gridSize) {
                                finishedArray.append(grid!.grid[i] != nil)
                            } else {
                                finishedArray.append(grid!.grid[i] == nil)
                            }
                        }
                        if !finishedArray.contains(false)  {
                            gameComplete = true
                            if let id = puzzleID {
                                UserDefaults.standard.set(true, forKey: "\(id)")
                            } else {
                                sendToServer(puzzle: puzzleSig)
                            }
                            for i in grid!.buttonGrid {
                                i.isEnabled = false
                            }
                            let alert = UIAlertController(title: "Puzzle complete!", message: "You solved the puzzle! Would you like to play again?", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Yes", style: .default) {action in
                                self.resetGame()
                            })
                            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                } else {
                    // try swap
                    if lastSelected != (gridSize * gridSize) {
                        if (checker(position: lastSelected, card: grid!.grid[location]!) || lastSelected > (gridSize * gridSize)) && (checker(position: location, card: activeCard!) ||  location > (gridSize * gridSize)) {
                            grid!.grid[lastSelected] = grid!.grid[location]
                            var image = grid!.grid[lastSelected]!.getFilename()
                            var color = grid!.grid[lastSelected]!.getColor()
                            grid!.buttonGrid[lastSelected].setAttrs(image: UIImage(named: image), bgColor: color)
                            grid!.buttonGrid[lastSelected].setBorder(width: 0, color: .black)
                            grid!.grid[location] = activeCard
                            image = grid!.grid[location]!.getFilename()
                            color = grid!.grid[location]!.getColor()
                            grid!.buttonGrid[location].setAttrs(image: UIImage(named: image), bgColor: color)
                            grid!.buttonGrid[location].setBorder(width: 0, color: .black)
                        } else {
                            let alert = UIAlertController(title: nil, message: "Those tiles can't be swapped.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                            impact.impactOccurred()
                            self.present(alert, animated: true)
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
                grid!.buttonGrid[(gridSize * gridSize)].setAttrs(image: UIImage(named: image), bgColor: color)
            } else {
                grid!.grid[(gridSize * gridSize)] = nil
                grid!.buttonGrid[(gridSize * gridSize)].setAttrs(image: UIImage(named: "none.png"), bgColor: .white)
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
            let alert = UIAlertController(title: "Puzzle not finished!", message: "Are you sure you want a new puzzle? All progress on this one will be lost.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default) {action in
                self.resetGame()
            })
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            impact.impactOccurred()
            self.present(alert, animated: true)
        }
    }
    
    @objc func goToHome() {
        if gameComplete {
            performSegue(withIdentifier: "ToHome", sender: self)
        } else {
            let alert = UIAlertController(title: "Puzzle not finished!", message: "Are you sure you want to quit? All progress on this puzzle will be lost.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default) {action in
                self.performSegue(withIdentifier: "ToHome", sender: self)
            })
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            impact.impactOccurred()
            self.present(alert, animated: true)
        }
    }
    
    @objc func goToSelect() {
        if gameComplete {
            performSegue(withIdentifier: "ToSelect", sender: self)
        } else {
            let alert = UIAlertController(title: "Puzzle not finished!", message: "Are you sure you want to quit? All progress on this puzzle will be lost.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default) {action in
                self.performSegue(withIdentifier: "ToSelect", sender: self)
            })
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            impact.impactOccurred()
            self.present(alert, animated: true)
        }
    }
    
}
