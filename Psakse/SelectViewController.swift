//
//  SelectViewController.swift
//  Psakse-2
//
//  Created by Daniel Marriner on 10/01/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit

class SelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var puzzleSelected = -1
    var table: UITableView? = nil
    var tableData = [Puzzle]()
    var override: Bool = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        let solved = UserDefaults.standard.bool(forKey: "\(tableData[indexPath.row].id)")
        cell.textLabel?.text = "Puzzle \(indexPath.row + 1)" + (solved ? " - Solved" : "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        puzzleSelected = indexPath.row
        for _ in 0..<tableData.count {
            performSegue(withIdentifier: "ToScriptedPuzzle", sender: self)
        }
    }
    
    @objc func goToHome() {
        performSegue(withIdentifier: "ToHome", sender: self)
    }
    
    struct Puzzle: Decodable {
        var numID: String
        var id: String
        var properties: String
    }
    
    func getJson() {
        let x = URL(string: "https://anachronistic-tech.co.uk/psakse/get_puzzles.php")!
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
        
        // Clear all stored data
        //        let domain = Bundle.main.bundleIdentifier!
        //        UserDefaults.standard.removePersistentDomain(forName: domain)
        //        UserDefaults.standard.synchronize()
        
        let x = (Int)(UIScreen.main.bounds.width / 2) - 100
        let y = (Int)(UIScreen.main.bounds.height) - 200
        let button = UIButton(frame: CGRect(x: x, y: y, width: 200, height: 60))
        button.backgroundColor = Colors.Green.getColor()
        button.adjustsImageWhenDisabled = false
        button.setTitle("Home", for: .normal)
        button.addTarget(self, action: #selector(goToHome), for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBorder(width: 3, color: .darkGray)
        button.layer.cornerRadius = 30
        self.view.addSubview(button)
        
        let width = (Int)(UIScreen.main.bounds.width) - 40
        let height = (Int)(UIScreen.main.bounds.height) - 300
        table = UITableView(frame: CGRect(x: 20, y: 60, width: width, height: height))
        table!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        table!.dataSource = self
        table!.delegate = self
        self.view.addSubview(table!)
        getJson()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        puzzleSelected = -1
        table?.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToScriptedPuzzle" {
            let destinationViewController = segue.destination as! GameViewController
            let puzzle = tableData[puzzleSelected]
            destinationViewController.puzzleID = puzzle.id
            destinationViewController.override = puzzle.properties
        }
    }
    
}
