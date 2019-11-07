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
    
    var width = 0
    var height = 0
    
    @objc func goToGame() {
        performSegue(withIdentifier: "ToGame", sender: self)
        self.view.window?.windowController?.close()
    }
    
    @objc func goToPuzzleSelect() {
        performSegue(withIdentifier: "ToPuzzleSelect", sender: self)
        self.view.window?.windowController?.close()
    }
    
    func createMenu() {
        let options = ["Tutorial", "Challenge Mode", "Random Puzzle"]
        for i in 0..<options.count {
            let x = (Int)(self.width / 2) - 100
            let y = ((i + 3) * (Int)(self.height) / (options.count + 3)) - 30
            let button = NSButton(frame: CGRect(x: x, y: y, width: 200, height: 60))
            let layer = CALayer()
            switch i {
            case 0:
                layer.backgroundColor = Colors.Green.getColor().cgColor
                button.action = #selector(comingSoon)
                break
            case 1:
                layer.backgroundColor = Colors.Yellow.getColor().cgColor
                button.action = #selector(goToPuzzleSelect)
                break
            case 2:
                layer.backgroundColor = Colors.Purple.getColor().cgColor
                button.action = #selector(goToGame)
            default:
                break
            }
            layer.cornerRadius = 30
            let text = CATextLayer()
            text.string = options[i]
            text.frame = CGRect(x: 0, y: button.bounds.height / 3.2, width: button.bounds.width, height: button.bounds.height / 2)
            text.foregroundColor = NSColor.darkGray.cgColor
            text.fontSize = 16
            text.alignmentMode = .center
            layer.addSublayer(text)
            button.layer = layer
            button.setBorder(width: 3, color: .darkGray)
            self.view.addSubview(button)
        }
        let width = (Int)(self.width) - 60
        let y = ((Int)(self.height) / (options.count + 3)) - 30
        let logo = NSImageView(frame: CGRect(x: 30, y: y, width: width, height: 150))
        logo.image = NSImage(named: "logo_large_alt.png")
        logo.imageScaling = .scaleProportionallyUpOrDown
        self.view.addSubview(logo)
    }
    
    @objc func comingSoon() {
//        let alert = UIAlertController(title: nil, message: "This feature is coming soon!", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Yay!", style: .cancel, handler: nil))
//        self.present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        let width = 500
        let height = 750
        self.view = FlippedView()
        self.view.window?.setFrame(NSRect(x: 0, y: 0, width: width, height: height), display: true)
        let layer = CALayer()
        layer.backgroundColor = NSColor.white.cgColor
        self.view.layer = layer
        self.view.setFrameSize(NSSize(width: width, height: height))
        self.width = width
        self.height = height
        createMenu()
    }
    
}
