//
//  UIKitBehaviorTests.swift
//  BonMot
//
//  Created by Brian King on 8/16/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

import XCTest

#if os(iOS)
let defaultTextFieldFontSize: CGFloat = 17
let defaultTextViewFontSize: CGFloat = 12
#elseif os(tvOS)
let defaultTextFieldFontSize: CGFloat = 38
let defaultTextViewFontSize: CGFloat = 38
#endif

#if canImport(UIKit) && !os(watchOS)
import UIKit

class UIKitBehaviorTests: XCTestCase {

    func testLabelPropertyBehavior() {
        let largeFont = UIFont(name: "Avenir-Roman", size: 20)
        let smallFont = UIFont(name: "Avenir-Roman", size: 10)
        let label = UILabel()
        label.font = largeFont
        label.text = "Testing"

        // Ensure font information is mirrored in attributed string
        let attributedText = label.attributedText!
        let attributeFont = attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
        XCTAssertEqual(attributeFont, largeFont)

        // Change the font in the attributed string
        var attributes = attributedText.attributes(at: 0, effectiveRange: nil)
        attributes[.font] = smallFont
        label.attributedText = NSAttributedString(string: "Testing", attributes: attributes)
        // Note that the font property is updated.
        XCTAssertEqual(label.font, smallFont)

        if #available(iOS 11, tvOS 11, *) {
            // Change the text of the label
            label.text = "Testing"
            // Note that this does not revert to the original font. The font
            // set by the attributed string sticks in iOS 11+ and tvOS 11+.
            BONAssertEqualFonts(label.font, smallFont!)
        }
        else {
            // Change the text of the label
            label.text = "Testing"
            // Note that this reverts to the original font.
            BONAssertEqualFonts(label.font, largeFont!)
            // When text changes, it updates the font to the last font set to self.font
            // The getter for self.font returns the visible font.
        }
    }

    func testTextFieldFontPropertyBehavior() {
        let largeFont = UIFont(name: "Avenir-Roman", size: 20)
        let textField = UITextField()
        // Note that the font is not nil before the text property is set.
        XCTAssertNotNil(textField.font)
        XCTAssertEqual(textField.font?.pointSize, defaultTextFieldFontSize)
        textField.text = "Testing"
        // By default the font is not nil, size 17 (38 on tvOS) (Not 12 as stated in header)
        XCTAssertNotNil(textField.font)
        XCTAssertEqual(textField.font?.pointSize, defaultTextFieldFontSize)

        textField.font = largeFont
        XCTAssertEqual(textField.font?.pointSize, 20)

        // This test breaks on tvOS 11 as of beta 4: http://www.openradar.me/33742507
        if #available(tvOS 11.0, *) {
        }
        else {
            textField.font = nil
            // Note that font has a default value even though it's optional.
            XCTAssertNotNil(textField.font)
            XCTAssertEqual(textField.font?.pointSize, defaultTextFieldFontSize)
        }
    }

    func testTextViewFontPropertyBehavior() {
        let largeFont = UIFont(name: "Avenir-Roman", size: 20)
        let textField = UITextView()
        #if os(iOS)
            // Note that the font *is* nil before the text property is set.
            XCTAssertNil(textField.font)
        #elseif os(tvOS)
            // Note that the font size is not nil on tvOS.
            XCTAssertNotNil(textField.font)
        #endif
        textField.text = "Testing"
        // By default the font is nil
        XCTAssertNil(textField.font)

        textField.font = largeFont
        XCTAssertEqual(textField.font?.pointSize, 20)

        textField.font = nil
        // Note that font is not re-set like TextField()
        XCTAssertNil(textField.font)
    }

    func testButtonFontPropertyBehavior() {
        let button = UIButton()

        XCTAssertNotNil(button.titleLabel)
        XCTAssertNotNil(button.titleLabel?.font)
        XCTAssertNil(button.titleLabel?.attributedText)
    }

    // Check to see if arbitrary text survives re-configuration (spoiler: it doesn't).
    func testLabelAttributedStringAttributePreservationBehavior() {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "", attributes: ["TestAttribute": true])
        label.text = "New Text"
        label.font = UIFont(name: "Avenir-Roman", size: 10)
        let attributes = label.attributedText?.attributes(at: 0, effectiveRange: nil)
        XCTAssertNotNil(attributes)
        XCTAssertNil(attributes?["TestAttribute"])
    }

}

#endif
