//
//  Grid.swift
//  Psakse
//
//  Created by Daniel Marriner on 29/06/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import Foundation
import AppKit

class Grid: NSObject {
    var dWidth = 0
    var gridSize = 5
    var grid:[Card?] = Array(repeating: nil, count:30)
    var buttonGrid = [NSButton]()
    
    init(gridSize: Int, dWidth: Int) {
        self.gridSize = gridSize
        self.grid = Array(repeating: nil, count:((gridSize * gridSize) + gridSize))
        self.dWidth = dWidth
    }
    
    func create(view: NSView) {
        let gridMargin = 20
        let tileMargin = 5
        let mainGrid = drawMainGrid(gridMargin: gridMargin, tileMargin: tileMargin)
        view.addSubview(mainGrid)
        let sideGrid = drawSideGrid(gridMargin: gridMargin, tileMargin: tileMargin)
        view.addSubview(sideGrid)
    }
    
    private func drawMainGrid(gridMargin: Int, tileMargin: Int) -> NSView {
        let gridHeight = Int(dWidth) - (2 * gridMargin)
        let gridView = NSView(frame: CGRect(x: gridMargin, y: gridMargin, width: gridHeight, height: gridHeight))
        let layer = CALayer()
        layer.backgroundColor = .black
        gridView.layer = layer
        let tileHeight = (gridHeight - ((gridSize - 1) * tileMargin)) / gridSize
        for i in 0..<(gridSize * gridSize) {
            let gridX = i % gridSize
            let gridY = Int(i / gridSize)
            let x = gridX * (tileHeight + tileMargin)
            let y = gridY * (tileHeight + tileMargin)
            let button = createButton(x: x, y: y, height: tileHeight, tag: i)
            buttonGrid.append(button)
            gridView.addSubview(button)
        }
        return gridView
    }
    
    private func drawSideGrid(gridMargin: Int, tileMargin: Int) -> NSView {
        let gridWidth = Int(dWidth) - (2 * gridMargin)
        let tileHeight = (gridWidth - ((gridSize - 1) * tileMargin)) / gridSize
        let gridView = NSView(frame: CGRect(x: gridMargin, y: ((gridMargin * 2) + gridWidth), width: gridWidth, height: tileHeight + (2 * tileMargin)))
        let layer = CALayer()
        layer.backgroundColor = .black
        gridView.layer = layer
        for i in 0..<5 {
            let gridX = i % gridSize
            let x = gridX * (tileHeight + tileMargin)
            let button = createButton(x: x, y: 5, height: tileHeight, tag: i + (gridSize * gridSize))
            buttonGrid.append(button)
            gridView.addSubview(button)
        }
        return gridView
    }
    
    private func createButton(x: Int, y: Int, height: Int, tag: Int) -> NSButton {
        let button = NSButton(frame: CGRect(x: x, y: y, width: height, height: height))
        button.layer?.backgroundColor = NSColor.white.cgColor
//        button.adjustsImageWhenDisabled = false
        button.title = String(tag)
        button.tag = tag
        button.setBorder(width: 0, color: .black)
        return button
    }
    
    func drawControls() {
        
    }
    
}
