//
//  Grid.swift
//  Psakse
//
//  Created by Daniel Marriner on 29/06/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import Foundation
import UIKit

class Grid: NSObject {
    let dWidth = UIScreen.main.bounds.width
    var gridSize = 5
    var grid:[Card?] = Array(repeating: nil, count:30)
    var buttonGrid = [UIButton]()
    
    init(gridSize: Int) {
        self.gridSize = gridSize
        self.grid = Array(repeating: nil, count:((gridSize * gridSize) + gridSize))
    }
    
    func create(view: UIView) {
        let gridMargin = 20
        let tileMargin = 5
        let mainGrid = drawMainGrid(gridMargin: gridMargin, tileMargin: tileMargin)
        view.addSubview(mainGrid)
        let sideGrid = drawSideGrid(gridMargin: gridMargin, tileMargin: tileMargin)
        view.addSubview(sideGrid)
    }
    
    private func drawMainGrid(gridMargin: Int, tileMargin: Int) -> UIView {
        let gridHeight = Int(dWidth) - (2 * gridMargin)
        let gridView = UIView(frame: CGRect(x: gridMargin, y: (3 * gridMargin), width: gridHeight, height: gridHeight))
        gridView.backgroundColor = .black
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
    
    private func drawSideGrid(gridMargin: Int, tileMargin: Int) -> UIView {
        let gridWidth = Int(dWidth) - (2 * gridMargin)
        let tileHeight = (gridWidth - ((gridSize - 1) * tileMargin)) / gridSize
        let gridView = UIView(frame: CGRect(x: gridMargin, y: ((gridMargin * 5) + gridWidth), width: gridWidth, height: tileHeight + (2 * tileMargin)))
        gridView.backgroundColor = .black
        for i in 0..<5 {
            let gridX = i % gridSize
            let x = gridX * (tileHeight + tileMargin)
            let button = createButton(x: x, y: 5, height: tileHeight, tag: i + (gridSize * gridSize))
            buttonGrid.append(button)
            gridView.addSubview(button)
        }
        return gridView
    }
    
    private func createButton(x: Int, y: Int, height: Int, tag: Int) -> UIButton {
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
    
    func drawControls() {
        
    }
    
}
