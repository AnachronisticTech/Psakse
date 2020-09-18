//
//  GameViewController.swift
//  Psakse
//
//  Created by Daniel Marriner on 14/09/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var mainGrid: UIView!
    @IBOutlet weak var subGrid: UIView!
    @IBOutlet weak var backView: UIButton!
    @IBOutlet weak var newView: UIButton!

    let impact = UIImpactFeedbackGenerator()

    var game: Game!
    var grid: Grid!
    var puzzle: Puzzle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gridsize = puzzle?.gameProperties().size ?? 5
        grid = Grid(gridsize, mainGrid: mainGrid, subGrid: subGrid)
        for button in grid.buttons {
            button.addTarget(self, action: #selector(select), for: .touchUpInside)
        }
        
        // Create in game controls
        if let _ = puzzle {
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
        if let puzzle = puzzle {
            game = Game(with: puzzle)
        } else {
            game = Game()
        }
        game.addObserver(self)
        drawBoard()
    }

    func drawBoard() {
        // draw game board with tiles
        for i in 0..<game.board.count {
            let button = view.viewWithTag(i+1) as! UIButton
            if let card = game.board[i] {
                button.setAttrs(
                    image: UIImage(named: card.asset),
                    bgColor: card.color
                )
                if game.fixedLocations.contains(i) {
                    button.setBorder(width: 3, color: .yellow)
                }
            } else {
                button.setAttrs(image: nil, bgColor: .white)
            }
        }
        if let deckButton = view.viewWithTag(-2) as? UIButton {
            if let card = game.deck.first {
                deckButton.setAttrs(
                    image: UIImage(named: card.asset),
                    bgColor: card.color
                )
            } else {
                deckButton.setAttrs(
                    image: UIImage(named: "none"),
                    bgColor: .white
                )
            }
        }
    }
    
    func setupButtonView(button: UIButton, title: String, color: GameColor, action: Selector) {
        button.backgroundColor = color.color
        button.adjustsImageWhenDisabled = false
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBorder(width: 3, color: .darkGray)
        button.layer.cornerRadius = 10
    }
}

extension GameViewController {
    @objc func select(sender: UIButton!) {
        let index = sender.tag == -2 ? -2 : sender.tag - 1
        guard !game.fixedLocations.contains(index) else { return }
        game.selectCard(at: index)
    }
    
    @objc func newGame() {
        guard !game.isComplete else {
            reset()
            return
        }
        let alert = UIAlertController(
            title: "Puzzle not finished!",
            message: "Are you sure you want a new puzzle? All progress on this one will be lost.",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "Yes", style: .default) { _ in self.reset()
            }
        )
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        impact.impactOccurred()
        self.present(alert, animated: true)
    }
    
    @objc func goToHome() {
        guard !game.isComplete else {
            performSegue(withIdentifier: "ToHome", sender: self)
            return
        }
        let alert = UIAlertController(
            title: "Puzzle not finished!",
            message: "Are you sure you want to quit? All progress on this puzzle will be lost.",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "Yes", style: .default) { _ in
            self.performSegue(withIdentifier: "ToHome", sender: self)
            }
        )
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        impact.impactOccurred()
        self.present(alert, animated: true)
    }
    
    @objc func goToSelect() {
        guard !game.isComplete else {
            performSegue(withIdentifier: "ToSelect", sender: self)
            return
        }
        let alert = UIAlertController(
            title: "Puzzle not finished!",
            message: "Are you sure you want to quit? All progress on this puzzle will be lost.",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "Yes", style: .default) { _ in
            self.performSegue(withIdentifier: "ToSelect", sender: self)
            }
        )
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        impact.impactOccurred()
        self.present(alert, animated: true)
    }
}

extension GameViewController: GameObserver {
    func gameDeckDidChange(_ game: Game) {
        if let deckButton = view.viewWithTag(-2) as? UIButton {
            if let card = game.deck.first {
                // set deck image to top card
                deckButton.setAttrs(
                    image: UIImage(named: card.asset),
                    bgColor: card.color
                )
            } else {
                // disable deck button
                deckButton.isEnabled = false
                // set deck image to none
                deckButton.setAttrs(
                    image: UIImage(named: "none"),
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
        if let button = view.viewWithTag(index == -2 ? -2 : index + 1) as? UIButton {
            button.setBorder(width: 3, color: .black)
        }
    }

    func game(_ game: Game, didDeselectCardAt index: Int) {
        // remove active card border
        if let button = view.viewWithTag(index == -2 ? -2 : index + 1) as? UIButton {
            button.setBorder(width: 0, color: .black)
        }
    }
    
    func gameDidComplete(_ game: Game) {
        let alert = UIAlertController(
            title: "Puzzle complete!",
            message: "You solved the puzzle! Would you like to play again?",
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: "Yes", style: .default) { _ in
                self.reset()
            }
        )
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        self.present(alert, animated: true)
    }
    
    func gameDidDetectSwapConflict(_ game: Game) {
        let alert = UIAlertController(
            title: nil,
            message: "Those tiles can't be swapped.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        impact.impactOccurred()
        self.present(alert, animated: true)
    }
    
    func gameDidDetectMoveConflict(_ game: Game) {
        let alert = UIAlertController(
            title: nil,
            message: "That tile can't be placed there.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        impact.impactOccurred()
        self.present(alert, animated: true)
    }
}
