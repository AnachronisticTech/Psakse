//
//  UIKitExtensions.swift
//  Psakse
//
//  Created by Daniel Marriner on 29/06/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import UIKit

public extension UIButton {
    func reset() {
        self.setTitle("", for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.setBackgroundColor(color: .white)
        self.setBorder(width: 0, color: .white)
        self.setAttrs(image: nil, bgColor: .white)
        self.adjustsImageWhenDisabled = false
        self.isEnabled = true
    }
    
    func setAttrs(image: UIImage?, bgColor: UIColor) {
        self.setImage(image, for: .normal)
        self.backgroundColor = bgColor
    }
    
    func setBorder(width: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    func setBackgroundColor(color: UIColor) {
        self.backgroundColor = color
    }
}
