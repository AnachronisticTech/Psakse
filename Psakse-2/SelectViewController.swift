//
//  SelectViewController.swift
//  Psakse-2
//
//  Created by Daniel Marriner on 10/01/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit

class SelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	var numberOfPuzzles = 2
	var puzzleSelected = -1
	var table: UITableView? = nil
//	var puzzleArray:[Puzzle]? = nil
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return numberOfPuzzles
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
		let solved = UserDefaults.standard.bool(forKey: "\(indexPath.row)")
		if solved {
			cell.textLabel?.text = "Puzzle \(indexPath.row + 1) - Solved"
		} else {
			cell.textLabel?.text = "Puzzle \(indexPath.row + 1)"
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		puzzleSelected = indexPath.row
		for _ in 0..<numberOfPuzzles {
			performSegue(withIdentifier: "ToScriptedPuzzle", sender: self)
		}
	}
	
	@objc func goToHome() {
		performSegue(withIdentifier: "ToHome", sender: self)
	}
	
	struct Puzzle: Decodable {
		var solved: Bool
		var cardArray: [GameViewController.Card]
		var fixedArray: [Int]
		
		init(from decoder: Decoder) throws {
			var container = try decoder.unkeyedContainer()
			solved = try container.decode(Bool.self)
			var cardArrayTmp = [GameViewController.Card]()
			cardArrayTmp.append(try container.decode(GameViewController.Card.self))
			cardArray = cardArrayTmp
			fixedArray = try container.decode([Int].self)
		}
		
		let decoder = JSONDecoder()
		
		struct JSONCard: Codable {
			var symbol: String
			var color: String
		}
		
		func cardFromJSON(card: JSONCard) -> GameViewController.Card {
			let newCard = try! decoder.decode(JSONCard.self, from: <#T##Data#>)
			return newCard
		}
	}
	
	override func viewDidLoad() {
		
		let x = (Int)(UIScreen.main.bounds.width / 2) - 100
		let y = (Int)(UIScreen.main.bounds.height) - 200
		let button = UIButton(frame: CGRect(x: x, y: y, width: 200, height: 80))
		button.backgroundColor = GameViewController.Colors.Green.getColor()
		button.adjustsImageWhenDisabled = false
		button.setTitle("Home", for: .normal)
		button.addTarget(self, action: #selector(goToHome), for: .touchUpInside)
		button.titleLabel?.adjustsFontSizeToFitWidth = true
		button.setTitleColor(UIColor.darkGray, for: .normal)
		button.layer.borderColor = UIColor.darkGray.cgColor
		button.layer.borderWidth = 3
		button.layer.cornerRadius = 10
		self.view.addSubview(button)
		
		
		
		
		let width = (Int)(UIScreen.main.bounds.width) - 40
		let height = (Int)(UIScreen.main.bounds.height) - 300
		table = UITableView(frame: CGRect(x: 20, y: 60, width: width, height: height))
		table!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		table!.dataSource = self
		table!.delegate = self
		self.view.addSubview(table!)
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		puzzleSelected = -1
		table?.reloadData()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ToScriptedPuzzle" {
			let destinationViewController = segue.destination as! GameViewController
			let modeOverride = "Scripted"
			var overrideDeck = [GameViewController.Card]()
			var overrideRandArray = [Int]()
			switch puzzleSelected {
			case 0:
				//			let numberSymbols = 4
				//			let numberColors = 4
				overrideDeck = [.Normal(.Xi, .Orange),
								.Normal(.A, .Orange),
								.Normal(.Psi, .Purple),
								.Normal(.Psi, .Green),
								.Normal(.E, .Green),
								.Normal(.A, .Green),
								.Normal(.Xi, .Green),
								.Normal(.Xi, .Yellow),
								.Normal(.E, .Green),
								.Normal(.Psi, .Green),
								.Normal(.A, .Green),
								.Wild,
								.Normal(.E, .Yellow),
								.Wild,
								.Normal(.Psi, .Orange),
								.Normal(.Psi, .Orange),
								.Normal(.Psi, .Yellow),
								.Normal(.A, .Yellow),
								.Normal(.A, .Purple),
								.Normal(.Psi, .Purple),
								.Normal(.Psi, .Yellow),
								.Normal(.A, .Yellow),
								.Normal(.A, .Purple),
								.Normal(.E, .Purple),
								.Normal(.E, .Purple)]
				overrideRandArray = [9, 12, 18]
				break
			case 1:
				overrideDeck = [.Normal(.Xi, .Green),
								.Normal(.A, .Purple),
								.Normal(.E, .Yellow),
								.Normal(.Psi, .Green),
								.Normal(.Psi, .Green),
								.Normal(.Psi, .Orange),
								.Normal(.A, .Orange),
								.Normal(.A, .Green),
								.Normal(.Xi, .Green),
								.Normal(.Xi, .Orange),
								.Normal(.A, .Orange),
								.Wild,
								.Normal(.A, .Purple),
								.Wild,
								.Normal(.E, .Green),
								.Normal(.Xi, .Purple),
								.Normal(.E, .Purple),
								.Normal(.Xi, .Yellow),
								.Normal(.Xi, .Purple),
								.Normal(.Psi, .Purple),
								.Normal(.A, .Yellow),
								.Normal(.Xi, .Yellow),
								.Normal(.E, .Yellow),
								.Normal(.E, .Purple),
								.Normal(.Psi, .Purple)]
				overrideRandArray = [6, 13, 16]
			default:
				break
			}
			//			destinationViewController.numberSymbols = numberSymbols
			//			destinationViewController.numberColors = numberColors
			destinationViewController.overrideDeck = overrideDeck
			destinationViewController.overrideRandArray = overrideRandArray
			destinationViewController.mode = modeOverride
			destinationViewController.puzzleID = puzzleSelected
		}
	}
	
}
