//
//  SelectViewController.swift
//  Psakse
//
//  Created by Daniel Marriner on 10/01/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit

class SelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var puzzleSelected = -1
    var tableData = [Puzzle]()
    
    @IBOutlet weak var challengeView: UITableView!
    @IBOutlet weak var homeView: UIButton!
    
    func setupButtonView(button: UIButton, title: String, color: Colors, action: Selector) {
        button.backgroundColor = color.getColor()
        button.adjustsImageWhenDisabled = false
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.setBorder(width: 3, color: .darkGray)
        button.layer.cornerRadius = button.frame.height / 2
    }
    
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
        performSegue(withIdentifier: "ToScriptedPuzzle", sender: self)
    }
    
    @objc func goToHome() {
        performSegue(withIdentifier: "ToHome", sender: self)
    }
    
    override func viewDidLoad() {
        
        // Clear all stored data
        let debug = false
        if debug {
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
        }
        
        setupButtonView(button: homeView, title: "Home", color: .Green, action: #selector(goToHome))
        
        challengeView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        challengeView.dataSource = self
        challengeView.delegate = self
        getJson()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        puzzleSelected = -1
        challengeView.reloadData()
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
