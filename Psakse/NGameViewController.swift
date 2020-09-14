//
//  NGameViewController.swift
//  Psakse
//
//  Created by Daniel Marriner on 14/09/2020.
//  Copyright © 2020 Daniel Marriner. All rights reserved.
//

import UIKit

class NGameViewController: UIViewController {
    
    @IBOutlet weak var mainGrid: UIView!
    @IBOutlet weak var subGrid: UIView!
    @IBOutlet weak var backView: UIButton!
    @IBOutlet weak var newView: UIButton!

    let impact = UIImpactFeedbackGenerator()

    @objc func select(sender: UIButton!) {
        let index = sender.tag == -2 ? -2 : sender.tag - 1
        guard !game.fixedLocations.contains(index) else { return }
        game.selectCard(at: index)
    }

    let gridsize = 5
    var game: Game!
    var grid: NGrid!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grid = NGrid(mainGrid: mainGrid, subGrid: subGrid)
        for button in grid.buttons {
            button.addTarget(self, action: #selector(select), for: .touchUpInside)
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
}

extension NGameViewController: GameObserver {
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
        } else {
            print("couldn't find deck button")
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
