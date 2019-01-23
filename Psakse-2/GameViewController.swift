//
//  ViewController.swift
//  Psakse-2
//
//  Created by Daniel Marriner on 24/12/2018.
//  Copyright © 2018 Daniel Marriner. All rights reserved.
//

import UIKit
import CoreGraphics

class GameViewController: UIViewController {
	
	let gridSizeMaster = 5
	let wildcards = 2
	var numberSymbols = 4
	var numberColors = 4
	var gridExists = false
	var grid:Grid? = nil
	var deck:Deck? = nil
	var activeCard:Card? = nil
	var lastSelected = -1
	var gameComplete = false
	var mode = "Random"
	var puzzleID = -1
	var overrideDeck:[Card]? = nil
	var overrideRandArray:[Int]? = nil
	
	class Grid: NSObject {
		var gridSize = 5
		var grid:[Card?] = Array(repeating: nil, count:30)
		var buttonGrid = [UIButton]()
		
		init(gridSize: Int) {
			self.gridSize = gridSize
			self.grid = Array(repeating: nil, count:((gridSize * gridSize) + gridSize))
		}
		
		func drawMainGrid() {
			let gridBorder = 20
			let gridHeight = (Int)(UIScreen.main.bounds.width) - (2 * gridBorder)
			let tileSpacing = 5
			let tileHeight = (gridHeight - ((self.gridSize - 1) * tileSpacing)) / self.gridSize
			for i in 0..<(self.gridSize * self.gridSize) {
				let gridX = i % self.gridSize
				let gridY = (Int)(i / self.gridSize)
				let x = gridBorder + (gridX * tileHeight) + (gridX * tileSpacing)
				let y = (gridBorder * 3) + (gridY * tileHeight) + (gridY * tileSpacing)
				let button = createButton(x: x, y: y, height: tileHeight, tag: i)
				self.buttonGrid.append(button)
			}
		}
		
		func drawMainBg() -> UIView {
			let gridBorder = 20
			let gridHeight = (Int)(UIScreen.main.bounds.width) - (2 * gridBorder)
			let rect = CGRect(x: (Int)(UIScreen.main.bounds.width) - gridHeight - gridBorder, y: (gridBorder * 3), width: gridHeight, height: gridHeight)
			let view = UIView(frame: rect)
			view.backgroundColor = UIColor.black
			return view
		}
		
		func drawSideGrid() {
			let gridBorder = 20
			let gridHeight = (Int)(UIScreen.main.bounds.width) - (2 * gridBorder)
			let tileSpacing = 5
			let tileHeight = (gridHeight - ((self.gridSize - 1) * tileSpacing)) / self.gridSize
			for i in 0..<5 {
				let gridX = i % self.gridSize
				let x = gridBorder + (gridX * tileHeight) + (gridX * tileSpacing)
				let y = gridHeight + 100
				let button = createButton(x: x, y: y, height: tileHeight, tag: (i + (self.gridSize * self.gridSize)))
				self.buttonGrid.append(button)
			}
		}
		
		func drawSideBg() -> UIView {
			let gridHeight = (Int)(UIScreen.main.bounds.width) - 40
			let rect = CGRect(x: (Int)(UIScreen.main.bounds.width) - gridHeight - 20,
							  y: gridHeight + 95,
							  width: gridHeight,
							  height: (gridHeight + 55 - ((self.gridSize) * 5)) / self.gridSize)
			let view = UIView(frame: rect)
			view.backgroundColor = UIColor.black
			return view
		}
		
		func createButton(x: Int, y: Int, height: Int, tag: Int) -> UIButton {
			let button = UIButton(frame: CGRect(x: x, y: y, width: height, height: height))
			button.backgroundColor = UIColor.white
			button.adjustsImageWhenDisabled = false
			button.setTitle("\(tag)", for: .normal)
			button.tag = tag
			button.titleLabel?.adjustsFontSizeToFitWidth = true
			button.layer.borderColor = UIColor.black.cgColor
			button.layer.borderWidth = 0
			return button
		}
		
	}
	
	enum Symbols: CaseIterable {
		case Psi
		case A
		case Xi
		case E
		
		func getFilename() -> String {
			switch self {
				case .Psi:
					return "psi.png"
				case .A:
					return "a.png"
				case .Xi:
					return "xi.png"
				case .E:
					return "e.png"
			}
		}
	}
	
	enum Colors: CaseIterable {
		case Green
		case Yellow
		case Purple
		case Orange
		
		func getColor() -> UIColor {
			switch self {
				case .Green:
					return UIColor(red: 175/255, green: 227/255, blue: 70/255, alpha: 1)
				case .Yellow:
					return UIColor(red: 255/255, green: 220/255, blue: 115/255, alpha: 1)
				case .Purple:
					return UIColor(red: 236/255, green: 167/255, blue: 238/255, alpha: 1)
				case .Orange:
					return UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 1)
			}
		}
	}
	
	enum Card: Hashable, Decodable {
		
		enum Key: CodingKey {
			case rawValue
		}
		
		enum CodingError: Error {
			case unknownValue
		}
		
		init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: Key.self)
			let rawValue = try container.decode(Int.self, forKey: .rawValue)
			switch rawValue {
			case 0:
				self = .Wild
			case 1:
				self = .Normal(.Psi, .Green)
			case 2:
				self = .Normal(.A, .Green)
			case 3:
				self = .Normal(.Xi, .Green)
			case 4:
				self = .Normal(.E, .Green)
			case 5:
				self = .Normal(.Psi, .Yellow)
			case 6:
				self = .Normal(.A, .Yellow)
			case 7:
				self = .Normal(.Xi, .Yellow)
			case 8:
				self = .Normal(.E, .Yellow)
			case 9:
				self = .Normal(.Psi, .Purple)
			case 10:
				self = .Normal(.A, .Purple)
			case 11:
				self = .Normal(.Xi, .Purple)
			case 12:
				self = .Normal(.E, .Purple)
			case 13:
				self = .Normal(.Psi, .Orange)
			case 14:
				self = .Normal(.A, .Orange)
			case 15:
				self = .Normal(.Xi, .Orange)
			case 16:
				self = .Normal(.E, .Orange)
			default:
				throw CodingError.unknownValue
			}
		}
		
		case Wild
		case Normal(Symbols, Colors)

		func matches(other: Card) -> Bool {
			switch (self, other) {
				case (.Wild, _), (_, .Wild):
					return true
				case (.Normal(let sym1, let col1), .Normal(let sym2, let col2)):
					return sym1 == sym2 || col1 == col2
			}
		}

		func getColor() -> UIColor {
			switch self {
				case .Wild:
					return UIColor(red: 255/255, green: 180/255, blue: 188/255, alpha: 1)
				case .Normal(_, let color):
					return color.getColor()
			}
		}

		func getFilename() -> String {
			switch self {
				case .Wild:
					return "dot.png"
				case .Normal(let symbol, _):
					return symbol.getFilename()
			}
		}
	}
	
	class Deck {
		
		var arr = [Card]()
		var numberSymbols: Int
		var numberColors: Int
		
		init(numberSymbols: Int, numberColors: Int) {
			self.numberSymbols = numberSymbols
			self.numberColors = numberColors
		}
		
		func populateDeck() {
//			let symbolsToRemove = 4 - numberSymbols
//			let colorsToRemove = 4 - numberColors
			
//			if symbolsToRemove != 0 {
//				var last = 4
//				while last > 0 {
//					let rand = (Int)(arc4random_uniform(UInt32(last)))
//					self.symbols.swapAt(last, rand)
//					last -= 1
//				}
//				for _ in 0...symbolsToRemove {
//					self.symbols.removeLast()
//				}
//			}
//
//			if colorsToRemove != 0 {
//				var last = 4
//				while last > 0 {
//					let rand = (Int)(arc4random_uniform(UInt32(last)))
//					self.colors.swapAt(last, rand)
//					last -= 1
//				}
//				for _ in 0...colorsToRemove {
//					self.colors.removeLast()
//				}
//			}
			
			for symbol in Symbols.allCases {
				for color in Colors.allCases {
					self.arr.append(Card.Normal(symbol, color))
					self.arr.append(Card.Normal(symbol, color))
				}
			}
//			print("\(self.arr.count) cards added to the deck")
		}
		
		func addWildCards(count: Int)  {
			for _ in 0..<count {
				self.arr.append(Card.Wild)
			}
//			print("\(count) wildcards added to the deck")
		}
		
		func removeCards(gridSize: Int, wildcards: Int) {
			let gridTotal = self.arr.count - (gridSize * gridSize) + wildcards
			for _ in 0..<gridTotal {
				self.arr.removeLast()
			}
//			print("\(self.arr.count) cards remaining in the deck")
		}
		
		func createOverrideDeck(overrideDeck: [Card]) {
			for i in 3..<overrideDeck.count {
				let card = overrideDeck[i]
				self.arr.append(card)
			}
		}
		
		func finalShuffle() {
			var last = self.arr.count - 1
			while last > 0 {
				let rand = (Int)(arc4random_uniform(UInt32(last)))
				self.arr.swapAt(last, rand)
				last -= 1
			}
//			print("Deck prepared. \(self.arr.count) cards available.")
		}
	}
	
	func resetGame() {
		gameComplete = false
		deck = Deck(numberSymbols: numberSymbols, numberColors: numberColors)
		if !gridExists {
			grid = Grid(gridSize: gridSizeMaster)
			grid!.drawMainGrid()
			grid!.drawSideGrid()
			for button in grid!.buttonGrid {
				button.addTarget(self, action: #selector(select), for: .touchUpInside)
				setButtonAttrs(button: button, image: nil, title: "", titleColor: .black, bgColor: .white, controlState: .normal)
				button.isEnabled = true
				self.view.addSubview(button)
				self.view.bringSubviewToFront(button)
			}
			let bg = grid!.drawMainBg()
			self.view.addSubview(bg)
			self.view.sendSubviewToBack(bg)
			let sgbg = grid!.drawSideBg()
			self.view.addSubview(sgbg)
			self.view.sendSubviewToBack(sgbg)
			
			var x = (Int)(UIScreen.main.bounds.width / 2) + 10
//			let y = (Int)(UIScreen.main.bounds.height) - 200
			let y = ((Int)((Double)(UIScreen.main.bounds.height) + ((Double)(UIScreen.main.bounds.width) * 0.9)) / 2) + 40
			var button = UIButton(frame: CGRect(x: x, y: y, width: 80, height: 80))
			button.backgroundColor = GameViewController.Colors.Purple.getColor()
			button.adjustsImageWhenDisabled = false
			if mode == "Random" {
				button.setTitle("New Game", for: .normal)
			} else if mode == "Scripted" {
				button.setTitle("Reset", for: .normal)
			}
			button.addTarget(self, action: #selector(newGame), for: .touchUpInside)
			button.titleLabel?.adjustsFontSizeToFitWidth = true
			button.setTitleColor(UIColor.darkGray, for: .normal)
			button.layer.borderColor = UIColor.darkGray.cgColor
			button.layer.borderWidth = 3
			button.layer.cornerRadius = 10
			self.view.addSubview(button)
			
			x = (Int)(UIScreen.main.bounds.width / 2) - 90
			button = UIButton(frame: CGRect(x: x, y: y, width: 80, height: 80))
			button.backgroundColor = GameViewController.Colors.Orange.getColor()
			button.adjustsImageWhenDisabled = false
			if mode == "Random" {
				button.setTitle("Home", for: .normal)
				button.addTarget(self, action: #selector(goToHome), for: .touchUpInside)
			} else if mode == "Scripted" {
				button.setTitle("Back", for: .normal)
				button.addTarget(self, action: #selector(goToSelect), for: .touchUpInside)
			}
			button.titleLabel?.adjustsFontSizeToFitWidth = true
			button.setTitleColor(UIColor.darkGray, for: .normal)
			button.layer.borderColor = UIColor.darkGray.cgColor
			button.layer.borderWidth = 3
			button.layer.cornerRadius = 10
			self.view.addSubview(button)
			
			gridExists = true
		} else {
			for i in 0..<grid!.buttonGrid.count {
				grid!.grid[i] = nil
				setButtonAttrs(button: grid!.buttonGrid[i], image: nil, title: "", titleColor: .white, bgColor: .white, controlState: .normal)
				setButtonBorder(button: grid!.buttonGrid[i], width: 0, color: UIColor.black.cgColor)
				grid!.buttonGrid[i].isEnabled = true
			}
		}
		
		if let premadeDeck = overrideDeck {
			var randArray = overrideRandArray!
			for i in 0..<randArray.count {
				let image = premadeDeck[i].getFilename()
				let bgcolor = premadeDeck[i].getColor()
				let position = randArray[i]
				setButtonAttrs(button: grid!.buttonGrid[position], image: UIImage(named: image), title: "", titleColor: .black, bgColor: bgcolor, controlState: .normal)
				setButtonBorder(button: grid!.buttonGrid[position], width: 3, color: UIColor.yellow.cgColor)
				grid!.buttonGrid[position].isEnabled = false
				grid!.grid[randArray[i]] = premadeDeck[i]
			}
			deck!.createOverrideDeck(overrideDeck: premadeDeck)
		} else {
			deck!.populateDeck()
			deck!.finalShuffle()
			deck!.removeCards(gridSize: gridSizeMaster, wildcards: wildcards)
			// three random starting cards section
			var randArray = [Int]()
			for _ in 1...3 {
				var randPosition = UInt32(gridSizeMaster * gridSizeMaster)
				while randArray.contains(Int(randPosition)) ||
					  randPosition == gridSizeMaster * gridSizeMaster ||
					  randArray.contains(Int(randPosition) - 1) ||
					  randArray.contains(Int(randPosition) + 1) ||
					  randArray.contains(Int(randPosition) - gridSizeMaster) ||
					  randArray.contains(Int(randPosition) + gridSizeMaster) {
					randPosition = arc4random_uniform(UInt32(gridSizeMaster * gridSizeMaster - 1))
					if randPosition == 0 {
						randPosition = 1
					}
				}
				randArray.append(Int(randPosition))
			}
			for i in randArray {
				let image = deck!.arr[0].getFilename()
				let bgcolor = deck!.arr[0].getColor()
				setButtonAttrs(button: grid!.buttonGrid[i], image: UIImage(named: image), title: "", titleColor: .black, bgColor: bgcolor, controlState: .normal)
				setButtonBorder(button: grid!.buttonGrid[i], width: 3, color: UIColor.yellow.cgColor)
				grid!.buttonGrid[i].isEnabled = false
				grid!.grid[i] = deck!.arr[0]
				deck!.arr.removeFirst()
			}
			//
			
			deck!.addWildCards(count: wildcards)
		}
		
		deck!.finalShuffle()
		let image = deck!.arr[0].getFilename()
		let bgcolor = deck!.arr[0].getColor()
		grid!.grid[(gridSizeMaster * gridSizeMaster)] = deck!.arr[0]
		setButtonAttrs(button: grid!.buttonGrid[(gridSizeMaster * gridSizeMaster)], image: UIImage(named: image), title: "", titleColor: .black, bgColor: bgcolor, controlState: .normal)
	}
	
	func setButtonAttrs(button: UIButton, image:UIImage?, title: String, titleColor: UIColor, bgColor: UIColor, controlState: UIControl.State) {
		button.setImage(image, for: controlState)
		button.setTitle(title, for: controlState)
		button.setTitleColor(titleColor, for: controlState)
		button.backgroundColor = bgColor
	}
	
	func setButtonBorder(button: UIButton, width: CGFloat, color: CGColor) {
		button.layer.borderWidth = width
		button.layer.borderColor = color
	}
	
	@objc func select(sender: UIButton!) {
		let btnsender: UIButton = sender
		if let currentActiveCard = activeCard {
			// if sender == gridSize^2 or sender == lastSelected
			// deselect
			// else if sender empty
			// try move()
			// else
			// try swap()
			if btnsender.tag == (gridSizeMaster * gridSizeMaster) || btnsender.tag == lastSelected {
				deselect()
			} else {
				let location = btnsender.tag
				if grid!.grid[location] == nil {
					// try move
					if checker(position: location, card: currentActiveCard) || location > (gridSizeMaster * gridSizeMaster) {
						grid!.grid[location] = activeCard
						setButtonAttrs(button: grid!.buttonGrid[location], image: UIImage(named: currentActiveCard.getFilename()), title: "", titleColor: .black, bgColor: currentActiveCard.getColor(), controlState: .normal)
						// clear previous
						clearTile(position: lastSelected)
					} else {
						let alert = UIAlertController(title: nil, message: "That tile can't be placed there.", preferredStyle: .alert)
						alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
						self.present(alert, animated: true)
					}
					deselect()
					var finishedArray = [Bool]()
					if deck!.arr.count == 0 {
						for i in 0..<((gridSizeMaster * gridSizeMaster) + gridSizeMaster) {
							if i < (gridSizeMaster * gridSizeMaster) {
								finishedArray.append(grid!.grid[i] != nil)
							} else {
								finishedArray.append(grid!.grid[i] == nil)
							}
						}
						if !finishedArray.contains(false)  {
							gameComplete = true
							if mode == "Scripted" {
								UserDefaults.standard.set(true, forKey: "\(puzzleID)")
							}
							for i in grid!.buttonGrid {
								i.isEnabled = false
							}
							let alert = UIAlertController(title: "Puzzle complete!", message: "You solved the puzzle! Would you like to play again?", preferredStyle: .alert)
							alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
								self.resetGame()
							}))
							alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
							self.present(alert, animated: true)
						}
					}
				} else {
					// try swap
					if lastSelected != (gridSizeMaster * gridSizeMaster) {
						if (checker(position: lastSelected, card: grid!.grid[location]!) || lastSelected > (gridSizeMaster * gridSizeMaster)) && (checker(position: location, card: activeCard!) ||  location > (gridSizeMaster * gridSizeMaster)) {
							grid!.grid[lastSelected] = grid!.grid[location]
							var image = grid!.grid[lastSelected]?.getFilename()
							var color = grid!.grid[lastSelected]?.getColor()
							setButtonAttrs(button: grid!.buttonGrid[lastSelected], image: UIImage(named: image!), title: "", titleColor: .white, bgColor: color!, controlState: .normal)
							setButtonBorder(button: grid!.buttonGrid[lastSelected], width: 0, color: UIColor.black.cgColor)
							grid!.grid[location] = activeCard
							image = grid!.grid[location]?.getFilename()
							color = grid!.grid[location]?.getColor()
							setButtonAttrs(button: grid!.buttonGrid[location], image: UIImage(named: image!), title: "", titleColor: .white, bgColor: color!, controlState: .normal)
							setButtonBorder(button: grid!.buttonGrid[location], width: 0, color: UIColor.black.cgColor)
						} else {
							let alert = UIAlertController(title: nil, message: "Those tiles can't be swapped.", preferredStyle: .alert)
							alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
							self.present(alert, animated: true)
						}
					}
					deselect()
				}
			}
		} else {
			// set card to active
			// set border
			// lastSelected = tag
			let location = btnsender.tag
			if let selectedCard = grid!.grid[location] {
				activeCard = selectedCard
				setButtonBorder(button: grid!.buttonGrid[location], width: 3, color: UIColor.black.cgColor)
			}
			lastSelected = btnsender.tag
		}
	}
	
	func deselect() {
		activeCard = nil
		setButtonBorder(button: grid!.buttonGrid[lastSelected], width: 0, color: UIColor.black.cgColor)
		lastSelected = -1
	}
	
	func clearTile(position: Int) {
		if position == (gridSizeMaster * gridSizeMaster) {
			deck!.arr.removeFirst()
			if deck!.arr.count >= 1 {
				let image = deck!.arr[0].getFilename()
				let color = deck!.arr[0].getColor()
				grid!.grid[(gridSizeMaster * gridSizeMaster)] = deck!.arr[0]
				setButtonAttrs(button: grid!.buttonGrid[(gridSizeMaster * gridSizeMaster)], image: UIImage(named: image), title: "", titleColor: .white, bgColor: color, controlState: .normal)
			} else {
				grid!.grid[(gridSizeMaster * gridSizeMaster)] = nil
				setButtonAttrs(button: grid!.buttonGrid[(gridSizeMaster * gridSizeMaster)], image: UIImage(named: "none.png"), title: "", titleColor: .white, bgColor: .white, controlState: .normal)
				grid!.buttonGrid[(gridSizeMaster * gridSizeMaster)].isEnabled = false
			}
		} else {
			grid!.grid[position] = nil
			setButtonAttrs(button: grid!.buttonGrid[position], image: nil, title: "", titleColor: .white, bgColor: .white, controlState: .normal)
		}
	}
	
	func left(x: Int) -> Int {
		return x + 1
	}
	func right(x: Int) -> Int {
		return x - 1
	}
	func up(x: Int) -> Int {
		return x + gridSizeMaster
	}
	func down(x: Int) -> Int {
		return x - gridSizeMaster
	}
	
	func checker(position: Int, card: Card) -> Bool {
		var validArray = [Bool]()
		if position < gridSizeMaster {
			if position == 0 {
//				print("\(position) is a corner, check left = \(left(x: position)), up = \(up(x: position))")
				validArray.append(checkTile(position: left(x: position), card: card))
				validArray.append(checkTile(position: up(x: position), card: card))
			} else if position == gridSizeMaster - 1 {
//				print("\(position) is a corner, check right = \(right(x: position)), up = \(up(x: position))")
				validArray.append(checkTile(position: right(x: position), card: card))
				validArray.append(checkTile(position: up(x: position), card: card))
			} else {
//				print("\(position) is an edge, check left = \(left(x: position)), right = \(right(x: position)), up = \(up(x: position))")
				validArray.append(checkTile(position: left(x: position), card: card))
				validArray.append(checkTile(position: right(x: position), card: card))
				validArray.append(checkTile(position: up(x: position), card: card))
			}
		} else if position % gridSizeMaster == 0 {
			if position == gridSizeMaster * (gridSizeMaster - 1) {
//				print("\(position) is a corner, check left = \(left(x: position)), down = \(down(x: position))")
				validArray.append(checkTile(position: left(x: position), card: card))
				validArray.append(checkTile(position: down(x: position), card: card))
			} else {
//				print("\(position) is an edge, check left = \(left(x: position)), up = \(up(x: position)), down = \(down(x: position))")
				validArray.append(checkTile(position: left(x: position), card: card))
				validArray.append(checkTile(position: up(x: position), card: card))
				validArray.append(checkTile(position: down(x: position), card: card))
			}
		} else if position % gridSizeMaster == gridSizeMaster - 1 {
			if position == (gridSizeMaster * gridSizeMaster) - 1 {
//				print("\(position) is a corner, check right = \(right(x: position)), down = \(down(x: position))")
				validArray.append(checkTile(position: right(x: position), card: card))
				validArray.append(checkTile(position: down(x: position), card: card))
			} else {
//				print("\(position) is an edge, check right = \(right(x: position)), up = \(up(x: position)), down = \(down(x: position))")
				validArray.append(checkTile(position: right(x: position), card: card))
				validArray.append(checkTile(position: up(x: position), card: card))
				validArray.append(checkTile(position: down(x: position), card: card))
			}
		} else if position > gridSizeMaster * (gridSizeMaster - 1) {
//			print("\(position) is an edge, check left = \(left(x: position)), right = \(right(x: position)), down = \(down(x: position))")
			validArray.append(checkTile(position: left(x: position), card: card))
			validArray.append(checkTile(position: right(x: position), card: card))
			validArray.append(checkTile(position: down(x: position), card: card))
		} else {
//			print("\(position) is in the centre, check left = \(left(x: position)), right = \(right(x: position)), up = \(up(x: position)), down = \(down(x: position))")
			validArray.append(checkTile(position: left(x: position), card: card))
			validArray.append(checkTile(position: right(x: position), card: card))
			validArray.append(checkTile(position: up(x: position), card: card))
			validArray.append(checkTile(position: down(x: position), card: card))
		}
		for i in validArray {
			if !i {
				return false
			}
		}
		return true
	}
	
	func checkTile(position: Int, card: Card) -> Bool {
		if position > (gridSizeMaster * gridSizeMaster) {
			return true
		}
		if let placedCard = grid!.grid[position] {
			return card.matches(other: placedCard)
		} else {
			return true
		}
	}
	
	@objc func newGame() {
		if gameComplete {
			resetGame()
		} else {
			let alert = UIAlertController(title: "Puzzle not finished!", message: "Are you sure you want a new puzzle? All progress on this one will be lost.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
				self.resetGame()
			}))
			alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
			self.present(alert, animated: true)
		}
	}
	
	@objc func goToHome() {
		if gameComplete {
			performSegue(withIdentifier: "ToHome", sender: self)
		} else {
			let alert = UIAlertController(title: "Puzzle not finished!", message: "Are you sure you want to quit? All progress on this puzzle will be lost.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
				self.performSegue(withIdentifier: "ToHome", sender: self)
			}))
			alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
			self.present(alert, animated: true)
		}
	}
	
	@objc func goToSelect() {
		if gameComplete {
			performSegue(withIdentifier: "ToSelect", sender: self)
		} else {
			let alert = UIAlertController(title: "Puzzle not finished!", message: "Are you sure you want to quit? All progress on this puzzle will be lost.", preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {action in
				self.performSegue(withIdentifier: "ToSelect", sender: self)
			}))
			alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
			self.present(alert, animated: true)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		resetGame()
	}


}
