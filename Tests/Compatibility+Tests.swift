//
//  Compatibility+Tests.swift
//  BonMot
//
//  Created by Brian King on 9/13/16.
//  Copyright © 2016 Zev Eisenberg. All rights reserved.
//

import BonMot

#if canImport(AppKit)
    import AppKit
    let BONFontDescriptorFeatureSettingsAttribute = NSFontDescriptor.AttributeName.featureSettings
    let BONFontFeatureTypeIdentifierKey = NSFontDescriptor.FeatureKey.typeIdentifier
    let BONFontFeatureSelectorIdentifierKey = NSFontDescriptor.FeatureKey.selectorIdentifier
    typealias BONView = NSView
#elseif canImport(UIKit)
    import UIKit
    let BONFontDescriptorFeatureSettingsAttribute = UIFontDescriptor.AttributeName.featureSettings
    let BONFontFeatureTypeIdentifierKey = UIFontDescriptor.FeatureKey.featureIdentifier
    let BONFontFeatureSelectorIdentifierKey = UIFontDescriptor.FeatureKey.typeIdentifier
#endif

#if os(iOS)
typealias BONView = UIView
#endif

extension NSAttributedString.Key: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(value)
    }

}

extension BONFontDescriptor.AttributeName: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }

}
