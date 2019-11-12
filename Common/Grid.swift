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
typealias Button = NSButton
#elseif os(iOS)
import UIKit
typealias View = UIView
typealias Button = UIButton
#endif

import Foundation

class Grid {
    let gridSize: Int
    let tileMargin = 5
    var grid:[Card?] = Array(repeating: nil, count:30)
    var buttonGrid = [Button]()
    
    init(gridSize: Int, mainGrid: View, subGrid: View) {
        self.gridSize = gridSize
        self.grid = Array(repeating: nil, count: (gridSize * gridSize) + gridSize)
        drawMainGrid(gridUI: mainGrid)
        drawSubGrid(gridUI: subGrid)
    }
    
    private func drawMainGrid(gridUI: View) {
        let gridHeight = Int(gridUI.frame.width)
        let tileHeight = (gridHeight - ((gridSize - 1) * tileMargin)) / gridSize
        for i in 0..<(gridSize * gridSize) {
            let gridX = i % gridSize
            let gridY = Int(i / gridSize)
            let x = gridX * (tileHeight + tileMargin)
            let y = gridY * (tileHeight + tileMargin)
            let button = createButton(x: x, y: y, height: tileHeight, tag: i)
            buttonGrid.append(button)
            gridUI.addSubview(button)
        }
    }
    private func drawSubGrid(gridUI: View) {
        let gridWidth = Int(gridUI.frame.width)
        let tileHeight = (gridWidth - ((gridSize - 1) * tileMargin)) / gridSize
        setHeight(gridUI, height: CGFloat(tileHeight))
        for i in 0..<5 {
            let gridX = i % gridSize
            let x = gridX * (tileHeight + tileMargin)
            let button = createButton(x: x, y: 5, height: tileHeight, tag: i + (gridSize * gridSize))
            buttonGrid.append(button)
            gridUI.addSubview(button)
        }
    }
    
    private func setHeight(_ gridUI: View, height: CGFloat) {
        gridUI.translatesAutoresizingMaskIntoConstraints = false
        gridUI.heightAnchor.constraint(equalToConstant: CGFloat(height + 10)).isActive = true
    }
    
    private func createButton(x: Int, y: Int, height: Int, tag: Int) -> Button {
        let button = Button(frame: CGRect(x: x, y: y, width: height, height: height))
        button.tag = tag
        button.reset()
        
        return button
    }
    
    func reset() {
        for i in 0..<buttonGrid.count {
            grid[i] = nil
            buttonGrid[i].reset()
        }
    }
}
