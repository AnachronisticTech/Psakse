//
//  ViewController.swift
//  Psakse
//
//  Created by Daniel Marriner on 24/12/2018.
//  Copyright © 2018 Daniel Marriner. All rights reserved.
//

import UIKit
import CoreGraphics

class GameViewController: UIViewController {
    
    let gridSize = 5
    let wildcards = 2
//    var numberSymbols = 4
//    var numberColors = 4
    var grid:Grid? = nil
    var deck:Deck? = nil
    var activeCard:Card? = nil
    var lastSelected = -1
    var state: [State] = []
    var gameComplete = false
    var puzzleID: String? = nil
    var override: String? = nil
    var puzzleSig: String = ""
    let impact = UIImpactFeedbackGenerator()
    
    @IBOutlet weak var mainGrid: UIView!
    @IBOutlet weak var subGrid: UIView!
    @IBOutlet weak var backView: UIButton!
    @IBOutlet weak var newView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        resetGame()
    }
    
    func setupButtonView(button: UIButton, title: String, color: Colors, action: Selector) {
        button.backgroundColor = color.getColor()
        button.adjustsImageWhenDisabled = false
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBorder(width: 3, color: .darkGray)
        button.layer.cornerRadius = 10
    }
    
    func moveConflictWarning() {
        let alert = UIAlertController(title: nil, message: "That tile can't be placed there.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        impact.impactOccurred()
        self.present(alert, animated: true)
    }
    
    func swapConflictWarning() {
        let alert = UIAlertController(title: nil, message: "Those tiles can't be swapped.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        impact.impactOccurred()
        self.present(alert, animated: true)
    }
    
    func puzzleCompleteAlert() {
        let alert = UIAlertController(title: "Puzzle complete!", message: "You solved the puzzle! Would you like to play again?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) {action in
            self.resetGame()
        })
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
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
