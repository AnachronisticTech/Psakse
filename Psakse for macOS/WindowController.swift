//
//  WindowController.swift
//  Psakse for MacOS
//
//  Created by Daniel Marriner on 23/07/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import Foundation
import AppKit

class WindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        if let window = window { //}, let screen = window.screen {
            window.title = "Psakse"
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        shouldCascadeWindows = false
    }
}
