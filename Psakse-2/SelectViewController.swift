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
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableData.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        let solved = UserDefaults.standard.bool(forKey: "\(tableData[indexPath.row].id)")
		if solved {
			cell.textLabel?.text = "Puzzle \(indexPath.row + 1) - Solved"
		} else {
			cell.textLabel?.text = "Puzzle \(indexPath.row + 1)"
		}
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
    
    struct Card: Decodable {
        var col: String
        var sym: String
        var locked: Int
    }
    
    struct Puzzle: Decodable {
        var id: Int
        var wild: Int
        var deck: [Card]
    }
	
	override func viewDidLoad() {
		
		let x = (Int)(UIScreen.main.bounds.width / 2) - 100
		let y = (Int)(UIScreen.main.bounds.height) - 200
		let button = UIButton(frame: CGRect(x: x, y: y, width: 200, height: 60))
		button.backgroundColor = GameViewController.Colors.Green.getColor()
		button.adjustsImageWhenDisabled = false
		button.setTitle("Home", for: .normal)
		button.addTarget(self, action: #selector(goToHome), for: .touchUpInside)
		button.titleLabel?.adjustsFontSizeToFitWidth = true
		button.setTitleColor(UIColor.darkGray, for: .normal)
		button.layer.borderColor = UIColor.darkGray.cgColor
		button.layer.borderWidth = 3
		button.layer.cornerRadius = 30
		self.view.addSubview(button)
		
		let width = (Int)(UIScreen.main.bounds.width) - 40
		let height = (Int)(UIScreen.main.bounds.height) - 300
		table = UITableView(frame: CGRect(x: 20, y: 60, width: width, height: height))
		table!.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
		table!.dataSource = self
		table!.delegate = self
		self.view.addSubview(table!)
        
        if let path = Bundle.main.path(forResource: "puzzles", ofType: "json") {
            do {
                let decoder = JSONDecoder()
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                tableData = try! decoder.decode([Puzzle].self, from: data)
                table!.reloadData()
            } catch {}
        }
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		puzzleSelected = -1
		table?.reloadData()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "ToScriptedPuzzle" {
			let destinationViewController = segue.destination as! GameViewController
			let modeOverride = "Scripted"
            let puzzle = tableData[puzzleSelected]
			let overrideDeck = convertToGameDeck(jsonDeck: puzzle.deck, wildcards: puzzle.wild)
			destinationViewController.overrideDeck = overrideDeck
			destinationViewController.overrideRandArray = [puzzle.deck[0].locked, puzzle.deck[1].locked, puzzle.deck[2].locked]
			destinationViewController.mode = modeOverride
			destinationViewController.puzzleID = puzzle.id
		}
	}
    
    func convertToGameDeck(jsonDeck: [Card], wildcards: Int) -> [GameViewController.Card] {
        var deck = [GameViewController.Card]()
        for i in jsonDeck {
            var card: GameViewController.Card
            switch i.col {
            case "green":
                switch i.sym {
                    case "Psi":
                        card = .Normal(.Psi, .Green)
                    case "A":
                        card = .Normal(.A, .Green)
                    case "Xi":
                        card = .Normal(.Xi, .Green)
                    default:
                        card = .Normal(.E, .Green)
                }
            case "yellow":
                switch i.sym {
                    case "Psi":
                        card = .Normal(.Psi, .Yellow)
                    case "A":
                        card = .Normal(.A, .Yellow)
                    case "Xi":
                        card = .Normal(.Xi, .Yellow)
                    default:
                        card = .Normal(.E, .Yellow)
                }
            case "purple":
                switch i.sym {
                    case "Psi":
                        card = .Normal(.Psi, .Purple)
                    case "A":
                        card = .Normal(.A, .Purple)
                    case "Xi":
                        card = .Normal(.Xi, .Purple)
                    default:
                        card = .Normal(.E, .Purple)
                }
            default:
                switch i.sym {
                    case "Psi":
                        card = .Normal(.Psi, .Orange)
                    case "A":
                        card = .Normal(.A, .Orange)
                    case "Xi":
                        card = .Normal(.Xi, .Orange)
                    default:
                        card = .Normal(.E, .Orange)
                }
            }
            deck.append(card)
        }
        for _ in 0..<wildcards {
            deck.append(.Wild)
        }
        return deck
    }
	
}
