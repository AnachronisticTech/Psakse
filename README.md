# Psakse (iOS game)

## Summary

Psakse is a tile-based single-player puzzle game. The object of the game is to fill a 5x5 grid with tiles from a deck. Each tile has a colour and a symbol, and there exist four colours each with two of every symbol in the deck. Some of the tiles are removed from the deck at the start of the game, and the player must fill the board with the remaining tiles, however tiles can only be placed adjacent to each other if they match in either colour or symbol or both. There are also two wild tiles which can be placed anywhere on the board. Tiles can be moved at any point, provided the move is valid. The puzzle begins with three randomly chosen (non-wild) tiles placed on the board in random valid positions; these tiles are fixed and cannot be moved by the player. The puzzle is solved when the entire board is filled and there are no invalid tiles.

![Solved game of Psakse](images/solved.jpg)

A solved game of Psakse. Yellow-bordered tiles are fixed. Pink dot tiles are wild. Notice, each tile must match _all_ its adjacent tiles excepting diagonals.

![An original board game of Psakse](images/original.jpg)

There are four slots apart from the main grid where a player can store tiles until later; these spaces don't require tiles to match their neighbours, but they are few compared to the number of spaces on the main board.

## Installation

The app must be built from source in Xcode on MacOS and deployed to an iOS device with an active developer profile enabled. You can register for a free developer account on the https://developer.apple.com/ website and download Xcode from the Mac App Store. Once Xcode and the device are set up to deploy and test apps, clone the repository and open the .xcodeproj file. The game can be loaded onto the device by selecting the device from the list of simulators in the top left corner of Xcode. _Note: this requires a device running at least iOS 12 by default, though you can lower this in the settings of the app since it doesn't rely on any new features._ 
