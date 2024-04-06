//
//  UIFontTests.swift
//  BonMot
//
//  Created by Brian King on 7/20/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

import BonMot
import XCTest

#if os(iOS) || os(tvOS) || os(watchOS)
    let testTextStyle = UIFont.TextStyle.title3
#endif

/// Test the platform behavior of [NS|UI]Font
class BONFontBehaviorTests: XCTestCase {

    /// This tests explores how font attributes persist after construction.
    ///
    /// - note: When a font is created, attributes that are not supported are
    /// removed. It appears that font attributes only act as hints as to what
    /// features should be enabled in a font, but only if the font supports it.
    /// The features that are enabled are still in the font attributes after
    /// construction.
    func testBONFontDescriptors() {
        var attributes = BONFont(name: "Avenir-Roman", size: 10)!.fontDescriptor.fontAttributes
        attributes[BONFontDescriptorFeatureSettingsAttribute] = [
            [
                BONFontFeatureTypeIdentifierKey: 1,
                BONFontFeatureSelectorIdentifierKey: 1,
            ],
        ]
        #if canImport(AppKit)
            let newAttributes = BONFont(descriptor: BONFontDescriptor(fontAttributes: attributes), size: 0)?.fontDescriptor.fontAttributes ?? [:]
        #elseif canImport(UIKit)
            let newAttributes = BONFont(descriptor: BONFontDescriptor(fontAttributes: attributes), size: 0).fontDescriptor.fontAttributes
        #endif
        XCTAssertEqual(newAttributes.count, 2)
        XCTAssertEqual(newAttributes["NSFontNameAttribute"] as? String, "Avenir-Roman")
        XCTAssertEqual(newAttributes["NSFontSizeAttribute"] as? Int, 10)
    }
    #if os(iOS) || os(tvOS) || os(watchOS)

    /// Test what happens when a non-standard text style string is supplied.
    func testUIFontNewTextStyle() {
        var attributes = UIFont(name: "Avenir-Roman", size: 10)!.fontDescriptor.fontAttributes
        attributes[UIFontDescriptor.AttributeName.featureSettings] = [
            [
                UIFontDescriptor.FeatureKey.featureIdentifier: 1,
                UIFontDescriptor.FeatureKey.typeIdentifier: 1,
            ],
        ]
        attributes[UIFontDescriptor.AttributeName.textStyle] = "Test"
        let newAttributes = UIFont(descriptor: UIFontDescriptor(fontAttributes: attributes), size: 0).fontDescriptor.fontAttributes
        XCTAssertEqual(newAttributes.count, 2)
        XCTAssertEqual(newAttributes["NSFontNameAttribute"] as? String, "Avenir-Roman")
        XCTAssertEqual(newAttributes["NSFontSizeAttribute"] as? Int, 10)
    }

    /// Demonstrate what happens when a text style feature is added to a
    /// non-system font. (It overrides the font.)
    func testTextStyleWithOtherFont() {
        var attributes = UIFont(name: "Avenir-Roman", size: 10)!.fontDescriptor.fontAttributes
        attributes[UIFontDescriptor.AttributeName.textStyle] = testTextStyle
        let newAttributes = UIFont(descriptor: UIFontDescriptor(fontAttributes: attributes), size: 0).fontDescriptor.fontAttributes
        if #available(iOS 14.0, tvOS 14.0, macOS 11.0, watchOS 7.0, *) {
            XCTAssertEqual(newAttributes.count, 3)
        }
        else {
            XCTAssertEqual(newAttributes.count, 2)
        }
        #if !os(watchOS)
        XCTAssertEqual(newAttributes["NSCTFontUIUsageAttribute"] as? BonMotTextStyle, testTextStyle)
        #endif
        XCTAssertEqual(newAttributes["NSFontSizeAttribute"] as? Int, 10)
    }
    #endif

}
