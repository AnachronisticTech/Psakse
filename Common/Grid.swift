//
//  Grid.swift
//  Psakse
//
//  Created by Daniel Marriner on 29/06/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

#if os(macOS)
import AppKit
typealias View = NSView
#elseif os(iOS)
import UIKit
typealias View = UIView
#endif

import Foundation

class Grid<T: View> {
    let gridsize: Int
    let tileMargin = 5
    var tiles = [T]()
    
    init(_ gridSize: Int = 5, mainGrid: View, subGrid: View? = nil) {
        self.gridsize = gridSize
        drawMainGrid(gridUI: mainGrid)
        guard let subGrid = subGrid else { return }
        drawSubGrid(gridUI: subGrid)
    }
    
    private func drawMainGrid(gridUI: View) {
        let gridHeight = Int(gridUI.frame.width)
        let tileHeight = (gridHeight - ((gridsize - 1) * tileMargin)) / gridsize
        for i in 0..<(gridsize ^^ 2) {
            let gridX = i % gridsize
            let gridY = Int(i / gridsize)
            let x = gridX * (tileHeight + tileMargin)
            let y = gridY * (tileHeight + tileMargin)
            let button = createTile(x: x, y: y, size: tileHeight, tag: i+1)
            tiles.append(button)
            gridUI.addSubview(button)
        }
    }
    private func drawSubGrid(gridUI: View) {
        let gridWidth = Int(gridUI.frame.width)
        let tileHeight = (gridWidth - (4 * tileMargin)) / 5
        setHeight(of: gridUI, to: CGFloat(tileHeight))
        for i in 0..<5 {
            let gridX = i % 5
            let x = gridX * (tileHeight + tileMargin)
            let tag = i == 0 ? -2 : i + (gridsize ^^ 2)
            let button = createTile(x: x, y: tileMargin, size: tileHeight, tag: tag)
            tiles.append(button)
            gridUI.addSubview(button)
        }
    }
    
    private func setHeight(of gridUI: View, to height: CGFloat) {
        gridUI.translatesAutoresizingMaskIntoConstraints = false
        gridUI.heightAnchor.constraint(equalToConstant: CGFloat(height + CGFloat(2 * tileMargin))).isActive = true
    }
    
    private func createTile(x: Int, y: Int, size: Int, tag: Int) -> T {
        let tile = T(frame: CGRect(x: x, y: y, width: size, height: size))
        tile.tag = tag
        return tile
    }

    func reset(_ handler: (T) -> Void) {
        for i in 0..<tiles.count {
            handler(tiles[i])
        }
    }
}
