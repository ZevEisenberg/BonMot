//
//  Emphasis.swift
//  BonMot
//
//  Created by Zev Eisenberg on 2/12/18.
//  Copyright © 2018 Rightpoint. All rights reserved.
//

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public struct Emphasis: OptionSet {

    public var rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let italic = Emphasis(rawValue: 1 << 0)
    public static let bold = Emphasis(rawValue: 1 << 1)

    // Reserved for later use, if we figure out a good naming scheme and use case.
    private static let expanded = Emphasis(rawValue: 1 << 2)
    private static let condensed = Emphasis(rawValue: 1 << 3)
    private static let vertical = Emphasis(rawValue: 1 << 4)
    private static let uiOptimized = Emphasis(rawValue: 1 << 5)
    private static let tightLineSpacing = Emphasis(rawValue: 1 << 6) // AKA Tight Leading
    private static let looseLineSpacing = Emphasis(rawValue: 1 << 7) // AKA Loose Leading

}

extension Emphasis {

    var symbolicTraits: BONSymbolicTraits {
        var traits: BONSymbolicTraits = []
        if contains(.italic) {
            traits.insert(.italic)
        }
        if contains(.bold) {
            traits.insert(.bold)
        }
        if contains(.expanded) {
            traits.insert(.expanded)
        }
        if contains(.condensed) {
            traits.insert(.condensed)
        }
        if contains(.vertical) {
            traits.insert(.vertical)
        }
        if contains(.uiOptimized) {
            traits.insert(.uiOptimized)
        }
        if contains(.tightLineSpacing) {
            traits.insert(.tightLineSpacing)
        }
        if contains(.looseLineSpacing) {
            traits.insert(.looseLineSpacing)
        }

        return traits
    }

}
