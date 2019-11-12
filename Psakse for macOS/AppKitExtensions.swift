//
//  AppKitExtensions.swift
//  Psakse
//
//  Created by Daniel Marriner on 29/06/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import AppKit

public extension NSButton {
    func reset() {
        self.title = ""
        self.setBackgroundColor(color: .white)
        self.setBorder(width: 0, color: .white)
        self.setAttrs(image: nil, bgColor: .white)
        self.imageScaling = .scaleProportionallyUpOrDown
        self.isEnabled = true
    }
    
    func setAttrs(image: NSImage?, bgColor: NSColor) {
        let layer = CALayer()
        layer.backgroundColor = bgColor.cgColor
        self.layer = layer
        self.layer?.contents = image?.cgImage(forProposedRect: nil, context: nil, hints: nil)
    }
    
    func setBorder(width: CGFloat, color: NSColor) {
        self.layer?.borderWidth = width
        self.layer?.borderColor = color.cgColor
    }
    
    func setBackgroundColor(color: NSColor) {
        self.layer?.backgroundColor = color.cgColor
    }
}
