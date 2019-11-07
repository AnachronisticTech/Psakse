//
//  SelectViewController.swift
//  Psakse-2
//
//  Created by Daniel Marriner on 10/01/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import AppKit

class SelectViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    var puzzleSelected = -1
    var table: NSTableView? = nil
    var tableData = [Puzzle]()
    var override: Bool = false
    var width = 0
    var height = 0
    
    func tableView(_ tableView: NSTableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
//    func tableView(_ tableView: NSTableView, cellForRowAt indexPath: IndexPath) -> NSTableCellView {
//        let cell = table?.makeView(withIdentifier: "cell", owner: nil) as! NSTableCellView {
//            cell.textField?.stringValue
//        }
////        let cell = NSTableCellView(style: NSTableCellView.CellStyle.default, reuseIdentifier: "Cell")
//        let solved = UserDefaults.standard.bool(forKey: "\(tableData[indexPath.item].id)")
//        cell.textLabel?.text = "Puzzle \(indexPath.row + 1)" + (solved ? " - Solved" : "")
//        return cell
//    }
    
    func tableView(_ tableView: NSTableView, didSelectRowAt indexPath: IndexPath) {
        puzzleSelected = indexPath.item
        for _ in 0..<tableData.count {
            performSegue(withIdentifier: "ToScriptedPuzzle", sender: self)
        }
    }
    
    @objc func goToHome() {
        performSegue(withIdentifier: "ToHome", sender: self)
        self.view.window?.windowController?.close()
    }
    
    struct Puzzle: Decodable {
        var numID: String
        var id: String
        var properties: String
    }
    
    func getJson() {
        let x = URL(string: "https://anachronistic-tech.co.uk/projects/psakse/get_puzzles.php")!
        let request = NSMutableURLRequest(url: x)
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            if error != nil {} else {
                if let unwrappedData = data {
                    let decoder = JSONDecoder()
                    self.tableData = try! decoder.decode([Puzzle].self, from: unwrappedData)
                    self.tableData.sort{ (lhs: Puzzle, rhs: Puzzle) -> Bool in
                        return Int(lhs.numID)! < Int(rhs.numID)!
                    }
                    DispatchQueue.main.sync(execute: {
                        self.table!.reloadData()
                    })
                }
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        let width = 500
        let height = 750
        self.view = FlippedView()
        self.view.window?.setFrame(NSRect(x: 0, y: 0, width: width, height: height), display: true)
        var layer = CALayer()
        layer.backgroundColor = NSColor.white.cgColor
        self.view.layer = layer
        self.view.setFrameSize(NSSize(width: width, height: height))
        self.width = width
        self.height = height
        
        // Clear all stored data
        //        let domain = Bundle.main.bundleIdentifier!
        //        UserDefaults.standard.removePersistentDomain(forName: domain)
        //        UserDefaults.standard.synchronize()
        
        let x = (Int)(self.width / 2) - 100
        let y = (Int)(self.height) - 200
        let button = NSButton(frame: CGRect(x: x, y: y, width: 200, height: 60))
        layer = CALayer()
        let text = CATextLayer()
        layer.backgroundColor = Colors.Green.getColor().cgColor
        layer.cornerRadius = 30
        text.string = "Home"
        text.frame = CGRect(x: 0, y: button.bounds.height / 3.2, width: button.bounds.width, height: button.bounds.height / 2)
        text.foregroundColor = NSColor.darkGray.cgColor
        text.fontSize = 16
        text.alignmentMode = .center
        layer.addSublayer(text)
        button.layer = layer
        button.action = #selector(goToHome)
        button.setBorder(width: 3, color: .darkGray)
        self.view.addSubview(button)
        
        let tWidth = (Int)(self.width) - 40
        let tHeight = (Int)(self.height) - 300
        table = NSTableView(frame: CGRect(x: 20, y: 60, width: tWidth, height: tHeight))
//        table!.register(NSTableViewCell.self, forCellReuseIdentifier: "Cell")
        table!.dataSource = self
        table!.delegate = self
        self.view.addSubview(table!)
        getJson()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToScriptedPuzzle" {
            let destinationViewController = segue.destinationController as! GameViewController
            let puzzle = tableData[puzzleSelected]
            destinationViewController.puzzleID = puzzle.id
            destinationViewController.override = puzzle.properties
        }
    }
    
}
