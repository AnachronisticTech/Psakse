//
//  NGameViewController.swift
//  Psakse for macOS
//
//  Created by Daniel Marriner on 15/09/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import AppKit

class NGameViewController: NSViewController {
    
    @IBOutlet weak var mainGrid: NSView!
    @IBOutlet weak var subGrid: NSView!
    @IBOutlet weak var backView: NSButton!
    @IBOutlet weak var newView: NSButton!

    let gridsize = 5
    var game: Game!
    var grid: NGrid!
    var puzzleID: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = 500
        let height = 750
        self.view.window?.setFrame(NSRect(x: 0, y: 0, width: width, height: height), display: true)
        let layer = CALayer()
        layer.backgroundColor = NSColor.white.cgColor
        self.view.layer = layer
        
        grid = NGrid(mainGrid: mainGrid, subGrid: subGrid)
        mainGrid.layer = CALayer()
        mainGrid.layer?.backgroundColor = .black
        subGrid.layer = CALayer()
        subGrid.layer?.backgroundColor = .black
        for button in grid.buttons {
            button.action = #selector(select)
        }
        
        // Create in game controls
        if let _ = puzzleID {
            setupButtonView(button: backView, title: "Back", color: .Orange, action: #selector(goToSelect))
            setupButtonView(button: newView, title: "Reset", color: .Purple, action: #selector(newGame))
        } else {
            setupButtonView(button: backView, title: "Home", color: .Orange, action: #selector(goToHome))
            setupButtonView(button: newView, title: "New Game", color: .Purple, action: #selector(newGame))
        }
        
        reset()
    }
    
    func reset() {
        // remove observer?
        grid.reset()
        game = Game()
        game.addObserver(self)
        drawBoard()
    }

    func drawBoard() {
        // draw game board with tiles
        for i in 0..<game.board.count {
            let button = view.viewWithTag(i+1) as! NSButton
            if let card = game.board[i] {
                button.setAttrs(
                    image: NSImage(named: card.asset),
                    bgColor: card.color
                )
                if game.fixedLocations.contains(i) {
                    button.setBorder(width: 3, color: .yellow)
                }
            } else {
                button.setAttrs(image: nil, bgColor: .white)
            }
        }
        if let deckButton = view.viewWithTag(-2) as? NSButton {
            if let card = game.deck.first {
                deckButton.setAttrs(
                    image: NSImage(named: card.asset),
                    bgColor: card.color
                )
            } else {
                deckButton.setAttrs(
                    image: NSImage(named: "none"),
                    bgColor: .white
                )
            }
        }
    }
    
    func setupButtonView(button: NSButton, title: String, color: GameColor, action: Selector) {
        let layer = CALayer()
        layer.backgroundColor = color.color.cgColor
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
}

extension NGameViewController {
    @objc func select(sender: NSButton!) {
        let index = sender.tag == -2 ? -2 : sender.tag - 1
        guard !game.fixedLocations.contains(index) else { return }
        game.selectCard(at: index)
    }
    
    @objc func newGame() {
        guard !game.isComplete else {
            reset()
            return
        }
        let alertView = NSAlert()
        alertView.alertStyle = .warning
        alertView.messageText = "Puzzle not finished!"
        alertView.informativeText = "Are you sure you want a new puzzle? All progress on this puzzle will be lost."
        alertView.addButton(withTitle: "New Puzzle")
        alertView.addButton(withTitle: "Stay")
        let result = alertView.runModal()
        switch result {
            case NSApplication.ModalResponse.alertFirstButtonReturn:
                self.reset()
            default: return
        }
    }
    
    @objc func goToHome() {
        guard !game.isComplete else {
            performSegue(withIdentifier: "ToHome", sender: self)
            self.view.window?.windowController?.close()
            return
        }
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
    
    @objc func goToSelect() {
        guard !game.isComplete else {
            performSegue(withIdentifier: "ToSelect", sender: self)
            self.view.window?.windowController?.close()
            return
        }
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

extension NGameViewController: GameObserver {
    func gameDeckDidChange(_ game: Game) {
        if let deckButton = view.viewWithTag(-2) as? NSButton {
            if let card = game.deck.first {
                // set deck image to top card
                deckButton.setAttrs(
                    image: NSImage(named: card.asset),
                    bgColor: card.color
                )
            } else {
                // disable deck button
                deckButton.isEnabled = false
                // set deck image to none
                deckButton.setAttrs(
                    image: NSImage(named: "none"),
                    bgColor: .white
                )
            }
        }
    }

    func gameBoardDidChange(_ game: Game) {
        drawBoard()
    }

    func game(_ game: Game, didSelectCardAt index: Int) {
        // set active card border
        if let button = view.viewWithTag(index == -2 ? -2 : index + 1) as? NSButton {
            button.setBorder(width: 3, color: .black)
        }
    }

    func game(_ game: Game, didDeselectCardAt index: Int) {
        // remove active card border
        if let button = view.viewWithTag(index == -2 ? -2 : index + 1) as? NSButton {
            button.setBorder(width: 0, color: .black)
        }
    }
    
    func gameDidComplete(_ game: Game) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Puzzle complete!"
        alert.informativeText = "You solved the puzzle! Would you like to play again?"
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        let result = alert.runModal()
        switch result {
            case NSApplication.ModalResponse.alertFirstButtonReturn:
                self.reset()
            default: return
        }
    }
    
    func gameDidDetectSwapConflict(_ game: Game) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Those tiles can't be swapped."
        alert.addButton(withTitle: "Ok")
        alert.runModal()
    }
    
    func gameDidDetectMoveConflict(_ game: Game) {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "That tile can't be placed there"
        alert.addButton(withTitle: "Ok")
        alert.runModal()
    }
}
