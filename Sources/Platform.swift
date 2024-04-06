//
//  Platform.swift
//  BonMot
//
//  Created by Brian King on 9/22/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

#if canImport(AppKit)
    import AppKit
    public typealias BONColor = NSColor
    public typealias BONImage = NSImage
    public typealias BONTextField = NSTextField

    public typealias BONFont = NSFont
    public typealias BONFontDescriptor = NSFontDescriptor
    public typealias BONSymbolicTraits = NSFontDescriptor.SymbolicTraits
    let BONFontDescriptorFeatureSettingsAttribute = NSFontDescriptor.AttributeName.featureSettings
    let BONFontFeatureTypeIdentifierKey = NSFontDescriptor.FeatureKey.typeIdentifier
    let BONFontFeatureSelectorIdentifierKey = NSFontDescriptor.FeatureKey.selectorIdentifier
#elseif canImport(UIKit)
    import UIKit
    public typealias BONColor = UIColor
    public typealias BONImage = UIImage

    public typealias BONFont = UIFont
    public typealias BONFontDescriptor = UIFontDescriptor
    public typealias BONSymbolicTraits = UIFontDescriptor.SymbolicTraits
    let BONFontDescriptorFeatureSettingsAttribute = UIFontDescriptor.AttributeName.featureSettings
    let BONFontFeatureTypeIdentifierKey = UIFontDescriptor.FeatureKey.featureIdentifier
    let BONFontFeatureSelectorIdentifierKey = UIFontDescriptor.FeatureKey.typeIdentifier

    #if os(iOS) || os(tvOS)
        public typealias BONTextField = UITextField
    #endif
#endif

public typealias StyleAttributes = [NSAttributedString.Key: Any]

#if os(iOS) || os(tvOS)
    public typealias BonMotTextStyle = UIFont.TextStyle
    public typealias BonMotContentSizeCategory = UIContentSizeCategory
#endif

// This key is defined here because it needs to be used in non-adaptive code.
public let BonMotTransformationsAttributeName = NSAttributedString.Key("BonMotTransformations")

extension BONSymbolicTraits {
    #if os(iOS) || os(tvOS) || os(watchOS)
        static var italic: BONSymbolicTraits {
            return .traitItalic
        }
        static var bold: BONSymbolicTraits {
            return .traitBold
        }
        static var expanded: BONSymbolicTraits {
            return .traitExpanded
        }
        static var condensed: BONSymbolicTraits {
            return .traitCondensed
        }
        static var vertical: BONSymbolicTraits {
            return .traitVertical
        }
        static var uiOptimized: BONSymbolicTraits {
            return .traitUIOptimized
        }
        static var tightLineSpacing: BONSymbolicTraits {
            return .traitTightLeading
        }
        static var looseLineSpacing: BONSymbolicTraits {
            return .traitLooseLeading
        }
    #else
        static var uiOptimized: BONSymbolicTraits {
            return .UIOptimized
        }
        static var tightLineSpacing: BONSymbolicTraits {
            return .tightLeading
        }
        static var looseLineSpacing: BONSymbolicTraits {
            return .looseLeading
        }
    #endif
}
