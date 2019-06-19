//
//  HomeViewController.swift
//  Psakse-2
//
//  Created by Daniel Marriner on 09/01/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit
import CoreGraphics

class HomeViewController: UIViewController {
    
    @objc func goToGame() {
        performSegue(withIdentifier: "ToGame", sender: self)
    }
    
    @objc func goToPuzzleSelect() {
        performSegue(withIdentifier: "ToPuzzleSelect", sender: self)
    }
    
    func createMenu() {
        let options = ["Tutorial", "Challenge Mode", "Random Puzzle"]
        for i in 0..<options.count {
            let x = (Int)(UIScreen.main.bounds.width / 2) - 100
            let y = ((i + 3) * (Int)(UIScreen.main.bounds.height) / (options.count + 3)) - 30
            let button = UIButton(frame: CGRect(x: x, y: y, width: 200, height: 60))
            button.adjustsImageWhenDisabled = false
            button.setTitle(options[i], for: .normal)
            switch i {
            case 0:
                button.backgroundColor = GameViewController.Colors.Purple.getColor()
                button.addTarget(self, action: #selector(comingSoon), for: .touchUpInside)
                break
            case 1:
                button.backgroundColor = GameViewController.Colors.Yellow.getColor()
                button.addTarget(self, action: #selector(goToPuzzleSelect), for: .touchUpInside)
                break
            case 2:
                button.backgroundColor = GameViewController.Colors.Green.getColor()
                button.addTarget(self, action: #selector(goToGame), for: .touchUpInside)
                break
            default:
                break
            }
            //        button.addTarget(self, action: #selector(newGame), for: .touchUpInside)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.setTitleColor(UIColor.darkGray, for: .normal)
            button.layer.borderColor = UIColor.darkGray.cgColor
            button.layer.borderWidth = 3
            button.layer.cornerRadius = 30
            self.view.addSubview(button)
        }
        let width = (Int)(UIScreen.main.bounds.width) - 60
        let y = ((Int)(UIScreen.main.bounds.height) / (options.count + 3)) - 30
        let logo = UIImageView(frame: CGRect(x: 30, y: y, width: width, height: 150))
        logo.image = UIImage(named: "logo_large_alt.png")
        logo.contentMode = UIView.ContentMode.scaleAspectFit
        self.view.addSubview(logo)
    }
    
    @objc func comingSoon() {
        let alert = UIAlertController(title: nil, message: "This feature is coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yay!", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        createMenu()
    }

}
