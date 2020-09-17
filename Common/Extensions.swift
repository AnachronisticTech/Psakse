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
        return self.map({ "\($0)" }).reduce("", +)
    }
}

public extension Array where Element == String {
    func contentsToString() -> String {
        return self.reduce("", +)
    }
}

public extension Int {
    func twoDigitPad() -> String {
        guard self < 10 else { return "\(self)" }
        guard self > -10 else { return "\(self)" }
        return "\(self < 0 ? "-" : "")0\(String(self).replacingOccurrences(of: "-", with: ""))"
    }
}
