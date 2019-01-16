
//
//  ViewController.swift
//  Psakse-2
//
//  Created by Daniel Marriner on 24/12/2018.
//  Copyright © 2018 Daniel Marriner. All rights reserved.
//
class ViewController: UIViewController {
    val gridSizeMaster = 5
    val wildcards = 2
    var gridExists = false
    var grid: Grid? = null
    var deck: Deck? = null
    var activeCard: Card? = null
    var lastSelected = -1
    var gameComplete = false
    
    class Grid: NSObject {
        var gridSize = 5
        var grid: List<Card?> = Array(repeating = null, count = 30)
        var buttonGrid = listOf(UIButton)()
        
        constructor(gridSize: Int) {
            this.gridSize = gridSize
            this.grid = Array(repeating = null, count = ((gridSize * gridSize) + gridSize))
        }
        
        fun drawMainGrid() {
            val gridBorder = 20
            val gridHeight = (Int)(UIScreen.main.bounds.width) - (2 * gridBorder)
            val tileSpacing = 5
            val tileHeight = (gridHeight - ((this.gridSize - 1) * tileSpacing)) / this.gridSize
            for (i in 0 until (this.gridSize * this.gridSize)) {
                val gridX = i % this.gridSize
                val gridY = (Int)(i / this.gridSize)
                val x = gridBorder + (gridX * tileHeight) + (gridX * tileSpacing)
                val y = (gridBorder * 3) + (gridY * tileHeight) + (gridY * tileSpacing)
                val button = createButton(x = x, y = y, height = tileHeight, tag = i)
                this.buttonGrid.append(button)
            }
        }
        
        fun drawMainBg() : UIView {
            val gridBorder = 20
            val gridHeight = (Int)(UIScreen.main.bounds.width) - (2 * gridBorder)
            val rect = CGRect(x = (Int)(UIScreen.main.bounds.width) - gridHeight - gridBorder, y = (gridBorder * 3), width = gridHeight, height = gridHeight)
            val view = UIView(frame = rect)
            view.backgroundColor = UIColor.black
            return view
        }
        
        fun drawSideGrid() {
            val gridBorder = 20
            val gridHeight = (Int)(UIScreen.main.bounds.width) - (2 * gridBorder)
            val tileSpacing = 5
            val tileHeight = (gridHeight - ((this.gridSize - 1) * tileSpacing)) / this.gridSize
            for (i in 0 until 5) {
                val gridX = i % this.gridSize
                val x = gridBorder + (gridX * tileHeight) + (gridX * tileSpacing)
                val y = gridHeight + 100
                val button = createButton(x = x, y = y, height = tileHeight, tag = (i + (this.gridSize * this.gridSize)))
                this.buttonGrid.append(button)
            }
        }
        
        fun drawSideBg() : UIView {
            val gridHeight = (Int)(UIScreen.main.bounds.width) - 40
            val rect = CGRect(x = (Int)(UIScreen.main.bounds.width) - gridHeight - 20, y = gridHeight + 95, width = gridHeight, height = (gridHeight + 55 - ((this.gridSize) * 5)) / this.gridSize)
            val view = UIView(frame = rect)
            view.backgroundColor = UIColor.black
            return view
        }
        
        fun createButton(x: Int, y: Int, height: Int, tag: Int) : UIButton {
            val button = UIButton(frame = CGRect(x = x, y = y, width = height, height = height))
            button.backgroundColor = UIColor.white
            button.adjustsImageWhenDisabled = false
            button.setTitle("${tag}", for = .normal)
            button.tag = tag
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.layer.borderColor = UIColor.black.cgColor
            button.layer.borderWidth = 0
            return button
        }
    }
    
    class Card {
        var symbol: String
        var color: UIColor
        var wild: Boolean
        
        constructor(symbol: String, color: UIColor, wild: Boolean) {
            this.symbol = symbol
            this.color = color
            this.wild = wild
        }
    }
    
    class Deck {
        //green RGB: (175, 227, 70)
        //yellow RGB: (255, 220, 115)
        //purple RGB: (236, 167, 238)
        //orange RGB: (255, 153, 51)
        var colors = listOf(UIColor(red = 175 / 255, green = 227 / 255, blue = 70 / 255, alpha = 1), UIColor(red = 255 / 255, green = 220 / 255, blue = 115 / 255, alpha = 1), UIColor(red = 236 / 255, green = 167 / 255, blue = 238 / 255, alpha = 1), UIColor(red = 255 / 255, green = 153 / 255, blue = 51 / 255, alpha = 1))
        var symbols = listOf("psi", "a", "xi", "e")
        var arr = listOf(Card)()
        var numberSymbols: Int
        var numberColors: Int
        
        constructor(numberSymbols: Int, numberColors: Int) {
            this.numberSymbols = numberSymbols
            this.numberColors = numberColors
        }
        
        fun populateDeck() {
            val symbolsToRemove = 4 - numberSymbols
            val colorsToRemove = 4 - numberColors
            if (symbolsToRemove != 0) {
                var last = 4
                while (last > 0) {
                    val rand = (Int)(arc4random_uniform(UInt32(last)))
                    this.symbols.swapAt(last, rand)
                    last -= 1
                }
                for (_ in 0 .. symbolsToRemove) {
                    this.symbols.removeLast()
                }
            }
            if (colorsToRemove != 0) {
                var last = 4
                while (last > 0) {
                    val rand = (Int)(arc4random_uniform(UInt32(last)))
                    this.colors.swapAt(last, rand)
                    last -= 1
                }
                for (_ in 0 .. colorsToRemove) {
                    this.colors.removeLast()
                }
            }
            for (color in colors) {
                for (symbol in symbols) {
                    this.arr.append(Card(symbol = symbol, color = color, wild = false))
                    this.arr.append(Card(symbol = symbol, color = color, wild = false))
                }
            }
        }
        
        //			print("\(self.arr.count) cards added to the deck")
        fun addWildCards(count: Int) {
            val color = UIColor(red = 255 / 255, green = 180 / 255, blue = 188 / 255, alpha = 1)
            for (_ in 0 until count) {
                this.arr.append(Card(symbol = "dot", color = color, wild = true))
            }
        }
        
        //			print("\(count) wildcards added to the deck")
        fun removeCards(gridSize: Int, wildcards: Int) {
            val gridTotal = this.arr.size - (gridSize * gridSize) + wildcards
            for (_ in 0 until gridTotal) {
                this.arr.removeLast()
            }
        }
        
        //			print("\(self.arr.count) cards remaining in the deck")
        fun finalShuffle() {
            var last = this.arr.size - 1
            while (last > 0) {
                val rand = (Int)(arc4random_uniform(UInt32(last)))
                this.arr.swapAt(last, rand)
                last -= 1
            }
        }
    }
    
    //			print("Deck prepared. \(self.arr.count) cards available.")
    fun resetGame() {
        gameComplete = false
        deck = Deck(numberSymbols = 4, numberColors = 4)
        deck!!.populateDeck()
        deck!!.finalShuffle()
        deck!!.removeCards(gridSize = gridSizeMaster, wildcards = wildcards)
        if (!gridExists) {
            grid = Grid(gridSize = gridSizeMaster)
            grid!!.drawMainGrid()
            grid!!.drawSideGrid()
            for (button in grid!!.buttonGrid) {
                button.addTarget(this, action = #selector(select), for = .touchUpInside)
                setButtonAttrs(button = button, image = null, title = "", titleColor = .black, bgColor = .white, controlState = .normal)
                button.isEnabled = true
                this.view.addSubview(button)
                this.view.bringSubviewToFront(button)
            }
            val bg = grid!!.drawMainBg()
            this.view.addSubview(bg)
            this.view.sendSubviewToBack(bg)
            val sgbg = grid!!.drawSideBg()
            this.view.addSubview(sgbg)
            this.view.sendSubviewToBack(sgbg)
            gridExists = true
        } else {
            for (i in 0 until grid!!.buttonGrid.size) {
                grid!!.grid[i] = null
                setButtonAttrs(button = grid!!.buttonGrid[i], image = null, title = "", titleColor = .white, bgColor = .white, controlState = .normal)
                setButtonBorder(button = grid!!.buttonGrid[i], width = 0, color = UIColor.black.cgColor)
                grid!!.buttonGrid[i].isEnabled = true
            }
        }
        // three random starting cards section
        var randArray = listOf(Int)()
        for (_ in 1 .. 3) {
            var randPosition = UInt32(gridSizeMaster * gridSizeMaster)
            while (randArray.contains(Int(randPosition)) || randPosition == gridSizeMaster * gridSizeMaster || randArray.contains(Int(randPosition) - 1) || randArray.contains(Int(randPosition) + 1) || randArray.contains(Int(randPosition) - gridSizeMaster) || randArray.contains(Int(randPosition) + gridSizeMaster)) {
                randPosition = arc4random_uniform(UInt32(gridSizeMaster * gridSizeMaster - 1))
                if (randPosition == 0) {
                    randPosition = 1
                }
            }
            randArray.append(Int(randPosition))
        }
        for (i in randArray) {
            val image = deck!!.arr[0].symbol
            val bgcolor = deck!!.arr[0].color
            val wild = deck!!.arr[0].wild
            setButtonAttrs(button = grid!!.buttonGrid[i], image = UIImage(named = image + ".png"), title = "", titleColor = .black, bgColor = bgcolor, controlState = .normal)
            setButtonBorder(button = grid!!.buttonGrid[i], width = 3, color = UIColor.yellow.cgColor)
            grid!!.buttonGrid[i].isEnabled = false
            grid!!.grid[i] = Card(symbol = image, color = bgcolor, wild = wild)
            deck!!.arr.removeFirst()
        }
        //
        deck!!.addWildCards(count = wildcards)
        deck!!.finalShuffle()
        val image = deck!!.arr[0].symbol
        val bgcolor = deck!!.arr[0].color
        val wild = deck!!.arr[0].wild
        grid!!.grid[(gridSizeMaster * gridSizeMaster)] = Card(symbol = image, color = bgcolor, wild = wild)
        setButtonAttrs(button = grid!!.buttonGrid[(gridSizeMaster * gridSizeMaster)], image = UIImage(named = image + ".png"), title = "", titleColor = .black, bgColor = bgcolor, controlState = .normal)
    }
    
    fun setButtonAttrs(button: UIButton, image: UIImage?, title: String, titleColor: UIColor, bgColor: UIColor, controlState: UIControl.State) {
        button.setImage(image, for = controlState)
        button.setTitle(title, for = controlState)
        button.setTitleColor(titleColor, for = controlState)
        button.backgroundColor = bgColor
    }
    
    fun setButtonBorder(button: UIButton, width: CGFloat, color: CGColor) {
        button.layer.borderWidth = width
        button.layer.borderColor = color
    }
    
    @objc fun select(sender: UIButton) {
        val btnsender: UIButton = sender
        if (activeCard == null) {
            // set card to active
            // set border
            // lastSelected = tag
            val location = btnsender.tag
            if (grid!!.grid[location] != null) {
                val image = grid!!.grid[location]?.symbol
                val color = grid!!.grid[location]?.color
                val wild = grid!!.grid[location]?.wild
                activeCard = Card(symbol = image!!, color = color!!, wild = wild!!)
                setButtonBorder(button = grid!!.buttonGrid[location], width = 3, color = UIColor.black.cgColor)
            }
            lastSelected = btnsender.tag
        } else {
            // if sender == gridSize^2 or sender == lastSelected
            // deselect
            // else if sender empty
            // try move()
            // else
            // try swap()
            if (btnsender.tag == (gridSizeMaster * gridSizeMaster) || btnsender.tag == lastSelected) {
                deselect()
            } else {
                val location = btnsender.tag
                if (grid!!.grid[location] == null) {
                    // try move
                    val image = activeCard?.symbol
                    val color = activeCard?.color
                    val wild = activeCard?.wild
                    if (checker(position = location, card = activeCard!!) || location > (gridSizeMaster * gridSizeMaster)) {
                        grid!!.grid[location] = Card(symbol = image!!, color = color!!, wild = wild!!)
                        setButtonAttrs(button = grid!!.buttonGrid[location], image = UIImage(named = image !+ ".png"), title = "", titleColor = .black, bgColor = color!!, controlState = .normal)
                        // clear previous
                        clearTile(position = lastSelected)
                    } else {
                        val alert = UIAlertController(title = null, message = "That tile can't be placed there.", preferredStyle = .alert)
                        alert.addAction(UIAlertAction(title = "Ok", style = .cancel, handler = null))
                        this.present(alert, animated = true)
                    }
                    deselect()
                    var finishedArray = listOf(Bool)()
                    if (deck!!.arr.size == 0) {
                        for (i in 0 until ((gridSizeMaster * gridSizeMaster) + gridSizeMaster)) {
                            if (i < (gridSizeMaster * gridSizeMaster)) {
                                finishedArray.append(grid!!.grid[i] != null)
                            } else {
                                finishedArray.append(grid!!.grid[i] == null)
                            }
                        }
                        if (!finishedArray.contains(false)) {
                            gameComplete = true
                            for (i in grid!!.buttonGrid) {
                                i.isEnabled = false
                            }
                            val alert = UIAlertController(title = "Puzzle complete!", message = "You solved the puzzle! Would you like to play again?", preferredStyle = .alert)
                            alert.addAction(UIAlertAction(title = "Yes", style = .default, handler = { action  -> 
                                this.resetGame()
                            }))
                            alert.addAction(UIAlertAction(title = "No", style = .cancel, handler = null))
                            this.present(alert, animated = true)
                        }
                    }
                } else {
                    // try swap
                    if (lastSelected != (gridSizeMaster * gridSizeMaster)) {
                        if ((checker(position = lastSelected, card = grid!!.grid[location]!!) || lastSelected > (gridSizeMaster * gridSizeMaster)) && (checker(position = location, card = activeCard!!) || location > (gridSizeMaster * gridSizeMaster))) {
                            grid!!.grid[lastSelected] = grid!!.grid[location]
                            var image = grid!!.grid[lastSelected]?.symbol
                            var color = grid!!.grid[lastSelected]?.color
                            setButtonAttrs(button = grid!!.buttonGrid[lastSelected], image = UIImage(named = image !+ ".png"), title = "", titleColor = .white, bgColor = color!!, controlState = .normal)
                            setButtonBorder(button = grid!!.buttonGrid[lastSelected], width = 0, color = UIColor.black.cgColor)
                            grid!!.grid[location] = activeCard
                            image = grid!!.grid[location]?.symbol
                            color = grid!!.grid[location]?.color
                            setButtonAttrs(button = grid!!.buttonGrid[location], image = UIImage(named = image !+ ".png"), title = "", titleColor = .white, bgColor = color!!, controlState = .normal)
                            setButtonBorder(button = grid!!.buttonGrid[location], width = 0, color = UIColor.black.cgColor)
                        } else {
                            val alert = UIAlertController(title = null, message = "Those tiles can't be swapped.", preferredStyle = .alert)
                            alert.addAction(UIAlertAction(title = "Ok", style = .cancel, handler = null))
                            this.present(alert, animated = true)
                        }
                    }
                    deselect()
                }
            }
        }
    }
    
    fun deselect() {
        activeCard = null
        setButtonBorder(button = grid!!.buttonGrid[lastSelected], width = 0, color = UIColor.black.cgColor)
        lastSelected = -1
    }
    
    fun clearTile(position: Int) {
        if (position == (gridSizeMaster * gridSizeMaster)) {
            deck!!.arr.removeFirst()
            if (deck!!.arr.size >= 1) {
                val image = deck!!.arr[0].symbol
                val color = deck!!.arr[0].color
                val wild = deck!!.arr[0].wild
                grid!!.grid[(gridSizeMaster * gridSizeMaster)] = Card(symbol = image, color = color, wild = wild)
                setButtonAttrs(button = grid!!.buttonGrid[(gridSizeMaster * gridSizeMaster)], image = UIImage(named = image + ".png"), title = "", titleColor = .white, bgColor = color, controlState = .normal)
            } else {
                grid!!.grid[(gridSizeMaster * gridSizeMaster)] = null
                setButtonAttrs(button = grid!!.buttonGrid[(gridSizeMaster * gridSizeMaster)], image = UIImage(named = "none.png"), title = "", titleColor = .white, bgColor = .white, controlState = .normal)
                grid!!.buttonGrid[(gridSizeMaster * gridSizeMaster)].isEnabled = false
            }
        } else {
            grid!!.grid[position] = null
            setButtonAttrs(button = grid!!.buttonGrid[position], image = null, title = "", titleColor = .white, bgColor = .white, controlState = .normal)
        }
    }
    
    fun left(x: Int) : Int =
        x + 1
    
    fun right(x: Int) : Int =
        x - 1
    
    fun up(x: Int) : Int =
        x + gridSizeMaster
    
    fun down(x: Int) : Int =
        x - gridSizeMaster
    
    fun checker(position: Int, card: Card) : Boolean {
        var validArray = listOf(Bool)()
        if (position < gridSizeMaster) {
            if (position == 0) {
                //				print("\(position) is a corner, check left = \(left(x: position)), up = \(up(x: position))")
                validArray.append(checkTile(position = left(x = position), card = card))
                validArray.append(checkTile(position = up(x = position), card = card))
            } else if (position == gridSizeMaster - 1) {
                //				print("\(position) is a corner, check right = \(right(x: position)), up = \(up(x: position))")
                validArray.append(checkTile(position = right(x = position), card = card))
                validArray.append(checkTile(position = up(x = position), card = card))
            } else {
                //				print("\(position) is an edge, check left = \(left(x: position)), right = \(right(x: position)), up = \(up(x: position))")
                validArray.append(checkTile(position = left(x = position), card = card))
                validArray.append(checkTile(position = right(x = position), card = card))
                validArray.append(checkTile(position = up(x = position), card = card))
            }
        } else if (position % gridSizeMaster == 0) {
            if (position == gridSizeMaster * (gridSizeMaster - 1)) {
                //				print("\(position) is a corner, check left = \(left(x: position)), down = \(down(x: position))")
                validArray.append(checkTile(position = left(x = position), card = card))
                validArray.append(checkTile(position = down(x = position), card = card))
            } else {
                //				print("\(position) is an edge, check left = \(left(x: position)), up = \(up(x: position)), down = \(down(x: position))")
                validArray.append(checkTile(position = left(x = position), card = card))
                validArray.append(checkTile(position = up(x = position), card = card))
                validArray.append(checkTile(position = down(x = position), card = card))
            }
        } else if (position % gridSizeMaster == gridSizeMaster - 1) {
            if (position == (gridSizeMaster * gridSizeMaster) - 1) {
                //				print("\(position) is a corner, check right = \(right(x: position)), down = \(down(x: position))")
                validArray.append(checkTile(position = right(x = position), card = card))
                validArray.append(checkTile(position = down(x = position), card = card))
            } else {
                //				print("\(position) is an edge, check right = \(right(x: position)), up = \(up(x: position)), down = \(down(x: position))")
                validArray.append(checkTile(position = right(x = position), card = card))
                validArray.append(checkTile(position = up(x = position), card = card))
                validArray.append(checkTile(position = down(x = position), card = card))
            }
        } else if (position > gridSizeMaster * (gridSizeMaster - 1)) {
            //			print("\(position) is an edge, check left = \(left(x: position)), right = \(right(x: position)), down = \(down(x: position))")
            validArray.append(checkTile(position = left(x = position), card = card))
            validArray.append(checkTile(position = right(x = position), card = card))
            validArray.append(checkTile(position = down(x = position), card = card))
        } else {
            //			print("\(position) is in the centre, check left = \(left(x: position)), right = \(right(x: position)), up = \(up(x: position)), down = \(down(x: position))")
            validArray.append(checkTile(position = left(x = position), card = card))
            validArray.append(checkTile(position = right(x = position), card = card))
            validArray.append(checkTile(position = up(x = position), card = card))
            validArray.append(checkTile(position = down(x = position), card = card))
        }
        for (i in validArray) {
            if (!i) {
                return false
            }
        }
        return true
    }
    
    fun checkTile(position: Int, card: Card) : Boolean {
        if (position > (gridSizeMaster * gridSizeMaster)) {
            return true
        }
        val cardImage = card.symbol
        val cardColor = card.color
        val cardWild = card.wild
        val placedImage: String
        val placedColor: UIColor
        val placedWild: Boolean
        val placedCard = grid!!.grid[position]
        if (placedCard != null) {
            placedImage = placedCard.symbol
            placedColor = placedCard.color
            placedWild = placedCard.wild
        } else {
            return true
        }
        if (cardImage == placedImage) {
            return true
        } else if (cardColor == placedColor) {
            return true
        } else if (cardWild || placedWild) {
            return true
        } else {
            return false
        }
    }
    
    @IBAction fun newGameButon(sender: Any) {
        if (gameComplete) {
            resetGame()
        } else {
            val alert = UIAlertController(title = "Puzzle not finished!", message = "Are you sure you want a new puzzle? All progress on this one will be lost.", preferredStyle = .alert)
            alert.addAction(UIAlertAction(title = "Yes", style = .default, handler = { action  -> 
                this.resetGame()
            }))
            alert.addAction(UIAlertAction(title = "No", style = .cancel, handler = null))
            this.present(alert, animated = true)
        }
    }
    
    override fun viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        resetGame()
    }
}
