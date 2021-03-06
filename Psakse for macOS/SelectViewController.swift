//
//  SelectViewController.swift
//  Psakse
//
//  Created by Daniel Marriner on 10/01/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import AppKit

class SelectViewController: NSViewController, NSTableViewDataSource {
    
    var puzzleSelected = -1
    var tableData = [Puzzle]()
    @IBOutlet weak var challengeView: NSTableView!
    @IBOutlet weak var homeView: NSButton!
    
    
    var table: NSTableView? = nil
    var override: Bool = false
    var width = 0
    var height = 0
    
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
        layer.cornerRadius = button.frame.height / 2
        button.layer = layer
        button.setBorder(width: 3, color: .darkGray)
    }
    
    @objc func goToHome() {
        performSegue(withIdentifier: "ToHome", sender: self)
        self.view.window?.windowController?.close()
    }
    
    override func viewDidLoad() {
        
        // Clear all stored data
        let debug = false
        if debug {
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
        
        let width = 500
        let height = 750
        self.view.window?.setFrame(NSRect(x: 0, y: 0, width: width, height: height), display: true)
        let layer = CALayer()
        layer.backgroundColor = NSColor.white.cgColor
        self.view.layer = layer
        
        setupButtonView(button: homeView, title: "Home", color: .Green, action: #selector(goToHome))
        
        challengeView.dataSource = self
        challengeView.delegate = self
        challengeView.target = self
        challengeView.doubleAction = #selector(doubleClick)
//        getJson()
        Puzzle.fetchAll { puzzles in
            self.tableData = puzzles
//            DispatchQueue.main.sync {
            self.challengeView.reloadData()
//            }
        }
    }
    
    override func viewDidAppear() {
        puzzleSelected = -1
        challengeView.reloadData()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToScriptedPuzzle" {
            let destinationViewController = segue.destinationController as! GameViewController
            destinationViewController.puzzle = tableData[puzzleSelected]
        }
    }
}

extension SelectViewController: NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = challengeView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Cell"), owner: nil) as? NSTableCellView
        let solved = UserDefaults.standard.bool(forKey: "\(tableData[row].id)")
        cell?.textField?.stringValue = "Puzzle \(row + 1)" + (solved ? " - Solved" : "")
        return cell
    }
    
    @objc func doubleClick(_ sender: AnyObject) {
        guard challengeView.selectedRow >= 0 else {
            return
        }
        puzzleSelected = challengeView.selectedRow
        performSegue(withIdentifier: "ToScriptedPuzzle", sender: self)
        self.view.window?.windowController?.close()
    }
}
