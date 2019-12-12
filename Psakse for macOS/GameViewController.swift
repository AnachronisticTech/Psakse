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
    var fixedTiles: [Int] = []
    var state: [State] = []
    var gameComplete = false
    var puzzleID: String? = nil
    var override: String? = nil
    var puzzleSig: String = ""
    
    @IBOutlet weak var mainGrid: NSView!
    @IBOutlet weak var subGrid: NSView!
    @IBOutlet weak var backView: NSButton!
    @IBOutlet weak var newView: NSButton!
    @IBOutlet weak var undoView: NSButton!
    @IBOutlet weak var resetView: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = 500
        let height = 750
        self.view.window?.setFrame(NSRect(x: 0, y: 0, width: width, height: height), display: true)
        let layer = CALayer()
        layer.backgroundColor = NSColor.white.cgColor
        self.view.layer = layer
        
        mainGrid.layer = CALayer()
        mainGrid.layer?.backgroundColor = .black
        subGrid.layer = CALayer()
        subGrid.layer?.backgroundColor = .black
        
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
    
    func moveConflictWarning() {
        let alertView = NSAlert()
        alertView.alertStyle = .warning
        alertView.messageText = "That tile can't be placed there"
        alertView.addButton(withTitle: "Ok")
        alertView.runModal()
    }
    
    func swapConflictWarning() {
        let alertView = NSAlert()
        alertView.alertStyle = .warning
        alertView.messageText = "Those tiles can't be swapped."
        alertView.addButton(withTitle: "Ok")
        alertView.runModal()
    }
    
    func puzzleCompleteAlert() {
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
