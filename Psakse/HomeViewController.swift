//
//  HomeViewController.swift
//  Psakse
//
//  Created by Daniel Marriner on 09/01/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import CoreGraphics

class HomeViewController: UIViewController {
    @IBOutlet weak var tutorialView: UIButton!
    @IBOutlet weak var challengeView: UIButton!
    @IBOutlet weak var randomView: UIButton!
    
    func setupButtonView(button: UIButton, title: String, color: GameColor, action: Selector) {
        button.backgroundColor = color.color
        button.adjustsImageWhenDisabled = false
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBorder(width: 3, color: .darkGray)
        button.layer.cornerRadius = button.frame.height / 2
    }
    
    @objc func goToGame() {
        performSegue(withIdentifier: "ToGame", sender: self)
    }
    
    @objc func goToPuzzleSelect() {
        performSegue(withIdentifier: "ToPuzzleSelect", sender: self)
    }
    
    @objc func comingSoon() {
        let alert = UIAlertController(title: nil, message: "This feature is coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yay!", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        setupButtonView(button: tutorialView, title: "Tutorial", color: .Green, action: #selector(comingSoon))
        setupButtonView(button: challengeView, title: "Challenge Mode", color: .Yellow, action: #selector(goToPuzzleSelect))
        setupButtonView(button: randomView, title: "Random Puzzle", color: .Purple, action: #selector(goToGame))
    }
    
}
