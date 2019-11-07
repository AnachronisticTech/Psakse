//
//  FlippedView.swift
//  Psakse for MacOS
//
//  Created by Daniel Marriner on 24/07/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import Foundation
import AppKit

class FlippedView: NSView {
    override var isFlipped: Bool {
        get {
            return true
        }
    }
}
