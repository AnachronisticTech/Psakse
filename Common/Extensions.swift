//
//  Extensions.swift
//  Psakse
//
//  Created by Daniel Marriner on 07/11/2019.
//  Copyright © 2019 Daniel Marriner. All rights reserved.
//

import Foundation

public extension Array where Element == Int {
    func contentsToString() -> String {
        var tmp = ""
        for i in self {
            tmp += String(i)
        }
        return tmp
    }
}
