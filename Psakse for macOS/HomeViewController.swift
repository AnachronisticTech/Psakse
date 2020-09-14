//
//  HomeViewController.swift
//  Psakse
//
//  Created by Daniel Marriner on 09/01/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import AppKit
import CoreGraphics

class HomeViewController: NSViewController {
    @IBOutlet weak var tutorialView: NSButton!
    @IBOutlet weak var challengeView: NSButton!
    @IBOutlet weak var randomView: NSButton!
    
    func setupButtonView(button: NSButton, title: String, color: Colors, action: Selector) {
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
        layer.cornerRadius = button.frame.height / 2
        button.layer = layer
        button.setBorder(width: 3, color: .darkGray)
    }
    
    @objc func goToGame() {
        performSegue(withIdentifier: "ToGame", sender: self)
        self.view.window?.windowController?.close()
    }
    
    @objc func goToPuzzleSelect() {
        performSegue(withIdentifier: "ToPuzzleSelect", sender: self)
        self.view.window?.windowController?.close()
    }
    
    @objc func comingSoon() {
        let alertView = NSAlert()
        alertView.alertStyle = .warning
        alertView.messageText = "This feature is coming soon!"
        alertView.addButton(withTitle: "Yay")
        alertView.runModal()
    }
    
    override func viewDidLoad() {
        let layer = CALayer()
        layer.backgroundColor = NSColor.white.cgColor
        self.view.layer = layer
        setupButtonView(button: tutorialView, title: "Tutorial", color: .Green, action: #selector(comingSoon))
        setupButtonView(button: challengeView, title: "Challenge Mode", color: .Yellow, action: #selector(goToPuzzleSelect))
        setupButtonView(button: randomView, title: "Random Puzzle", color: .Purple, action: #selector(goToGame))
    }
    
}
