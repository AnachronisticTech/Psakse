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
        self.backgroundColor = .white
        self.setBorder(width: 0, color: .white)
    }
    
    func setAttrs(image: UIImage?, bgColor: UIColor) {
        self.setImage(image, for: .normal)
        self.backgroundColor = bgColor
    }
    
    func setBorder(width: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
}
