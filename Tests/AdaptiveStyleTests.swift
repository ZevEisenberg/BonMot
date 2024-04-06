//
//  AdaptiveStyleTests.swift
//  BonMot
//
//  Created by Brian King on 9/2/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

@testable import BonMot
#if canImport(UIKit) && (os(iOS) || os(tvOS))
import UIKit
import XCTest

@available(iOS 10.0, *)
let defaultTraitCollection = UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory.large)

// These tests rely on iOS 10.0 APIs. Test method needs to be updated to run on iOS 9.0
@available(iOS 10.0, *)
class AdaptiveStyleTests: XCTestCase {

    func testFontControlSizeAdaptation() {
        let inputFont = UIFont(name: "Avenir-Book", size: 28)!
        let style = StringStyle(.font(inputFont), .adapt(.control))
        print(style.attributes)
        let testAttributes = { (contentSizeCategory: BonMotContentSizeCategory) -> StyleAttributes in
            let traitCollection = UITraitCollection(preferredContentSizeCategory: contentSizeCategory)
            return NSAttributedString.adapt(attributes: style.attributes, to: traitCollection)
        }
        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraSmall), query: \.pointSize, float: 25)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.small), query: \.pointSize, float: 26)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.medium), query: \.pointSize, float: 27)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.large), query: \.pointSize, float: 28)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraLarge), query: \.pointSize, float: 30)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraLarge), query: \.pointSize, float: 32)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraExtraLarge), query: \.pointSize, float: 34)

        // Ensure the accessibility ranges are capped at XXXL
        let sizes = [
            UIContentSizeCategory.accessibilityMedium,
            UIContentSizeCategory.accessibilityLarge,
            UIContentSizeCategory.accessibilityExtraLarge,
            UIContentSizeCategory.accessibilityExtraExtraLarge,
            UIContentSizeCategory.accessibilityExtraExtraExtraLarge,
            ]
        for size in sizes {
            BONAssert(attributes: testAttributes(size), query: \.pointSize, float: 34)
        }
    }

    func testFontBodySizeAdaptation() {
        let inputFont = UIFont(name: "Avenir-Book", size: 28)!
        let style = StringStyle(.font(inputFont), .adapt(.body))
        let testAttributes = { (contentSizeCategory: BonMotContentSizeCategory) -> StyleAttributes in
            let traitCollection = UITraitCollection(preferredContentSizeCategory: contentSizeCategory)
            let attributes = style.attributes
            return NSAttributedString.adapt(attributes: attributes, to: traitCollection)
        }
        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraSmall), query: \.pointSize, float: 25)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.small), query: \.pointSize, float: 26)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.medium), query: \.pointSize, float: 27)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.large), query: \.pointSize, float: 28)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraLarge), query: \.pointSize, float: 30)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraLarge), query: \.pointSize, float: 32)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraExtraLarge), query: \.pointSize, float: 34)

        // Ensure body keeps growing
        BONAssert(attributes: testAttributes(UIContentSizeCategory.accessibilityMedium), query: \.pointSize, float: 39)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.accessibilityLarge), query: \.pointSize, float: 44)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.accessibilityExtraLarge), query: \.pointSize, float: 51)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.accessibilityExtraExtraLarge), query: \.pointSize, float: 58)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.accessibilityExtraExtraExtraLarge), query: \.pointSize, float: 64)
    }

    func testPreferredFontDoesNotAdapt() {
        let font = UIFont.preferredFont(forTextStyle: titleTextStyle, compatibleWith: defaultTraitCollection)
        let style = StringStyle(.font(font))
        let testAttributes = { (contentSizeCategory: BonMotContentSizeCategory) -> StyleAttributes in
            let traitCollection = UITraitCollection(preferredContentSizeCategory: contentSizeCategory)
            return NSAttributedString.adapt(attributes: style.attributes, to: traitCollection)
        }
        // Ensure the font doesn't change sizes since it was added to the chain as a font, and `.preferred` was not added.
        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraSmall), query: \.pointSize, float: font.pointSize)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.small), query: \.pointSize, float: font.pointSize)
    }

    func testTextStyleAdapt() {
        let style = StringStyle(.textStyle(titleTextStyle), .adapt(.preferred))
        let testAttributes = { (contentSizeCategory: BonMotContentSizeCategory) -> StyleAttributes in
            let traitCollection = UITraitCollection(preferredContentSizeCategory: contentSizeCategory)
            return NSAttributedString.adapt(attributes: style.attributes, to: traitCollection)
        }
        // Ensure the font doesn't change sizes since it was added to the chain as a font, and `.preferred` was not added.

        // iPhone SE on 11.0+ has slightly different expected values
        if UIDevice.current.userInterfaceIdiom == .phone,
            UIScreen.main.bounds.height == 568,
            ProcessInfo().operatingSystemVersion.majorVersion >= 11 {
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraSmall), query: \.pointSize, float: 25)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.small), query: \.pointSize, float: 26)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.medium), query: \.pointSize, float: 26)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.large), query: \.pointSize, float: 26)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraLarge), query: \.pointSize, float: 27)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraLarge), query: \.pointSize, float: 28)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraExtraLarge), query: \.pointSize, float: 30)
        }
        else {
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraSmall), query: \.pointSize, float: 25)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.small), query: \.pointSize, float: 26)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.medium), query: \.pointSize, float: 27)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.large), query: \.pointSize, float: 28)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraLarge), query: \.pointSize, float: 30)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraLarge), query: \.pointSize, float: 32)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraExtraLarge), query: \.pointSize, float: 34)
        }
    }

    func testPreferredFontWithPreferredAdaptation() {
        let font = UIFont.preferredFont(forTextStyle: titleTextStyle, compatibleWith: defaultTraitCollection)
        let style = StringStyle(.font(font), .adapt(.preferred))
        let testAttributes = { (contentSizeCategory: BonMotContentSizeCategory) -> StyleAttributes in
            let traitCollection = UITraitCollection(preferredContentSizeCategory: contentSizeCategory)
            return NSAttributedString.adapt(attributes: style.attributes, to: traitCollection)
        }
        // Ensure the font doesn't change sizes since it was added to the chain as a font, and `.preferred` was not added.

        // iPhone SE on 11.0+ has slightly different expected values
        if UIDevice.current.userInterfaceIdiom == .phone,
            UIScreen.main.bounds.height == 568,
            ProcessInfo().operatingSystemVersion.majorVersion >= 11 {
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraSmall), query: \.pointSize, float: 25)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.small), query: \.pointSize, float: 26)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.medium), query: \.pointSize, float: 26)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.large), query: \.pointSize, float: 26)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraLarge), query: \.pointSize, float: 27)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraLarge), query: \.pointSize, float: 28)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraExtraLarge), query: \.pointSize, float: 30)
        }
        else {
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraSmall), query: \.pointSize, float: 25)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.small), query: \.pointSize, float: 26)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.medium), query: \.pointSize, float: 27)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.large), query: \.pointSize, float: 28)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraLarge), query: \.pointSize, float: 30)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraLarge), query: \.pointSize, float: 32)
            BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraExtraLarge), query: \.pointSize, float: 34)
        }
    }

    func testFontMetricsAdaptation() {
        // Test is still always run (and fails) on the iOS 10 simulator despite
        // the availability annotation.
        guard ProcessInfo().operatingSystemVersion.majorVersion > 10 else {
            return
        }

        let inputFont = UIFont(name: "Avenir-Book", size: 28)!
        let style = StringStyle(.font(inputFont), .adapt(.fontMetrics(textStyle: .headline, maxPointSize: nil)))
        print(style.attributes)

        let testAttributes = { (contentSizeCategory: BonMotContentSizeCategory) -> StyleAttributes in
            let traitCollection = UITraitCollection(preferredContentSizeCategory: contentSizeCategory)
            return NSAttributedString.adapt(attributes: style.attributes, to: traitCollection)
        }

        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraSmall), query: \.pointSize, float: 24)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.small), query: \.pointSize, float: 25)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.medium), query: \.pointSize, float: 27)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.large), query: \.pointSize, float: 28)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraLarge), query: \.pointSize, float: 31)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraLarge), query: \.pointSize, float: 33)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraExtraLarge), query: \.pointSize, float: 37)
    }

    func testFontMetricsWithMaxPointSizeAdaptation() {
        // Test is still always run (and fails) on the iOS 10 simulator despite
        // the availability annotation.
        guard ProcessInfo().operatingSystemVersion.majorVersion > 10 else {
            return
        }

        let inputFont = UIFont(name: "Avenir-Book", size: 28)!
        let style = StringStyle(.font(inputFont), .adapt(.fontMetrics(textStyle: .headline, maxPointSize: 30)))
        print(style.attributes)

        let testAttributes = { (contentSizeCategory: BonMotContentSizeCategory) -> StyleAttributes in
            let traitCollection = UITraitCollection(preferredContentSizeCategory: contentSizeCategory)
            return NSAttributedString.adapt(attributes: style.attributes, to: traitCollection)
        }

        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraSmall), query: \.pointSize, float: 24)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.small), query: \.pointSize, float: 25)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.medium), query: \.pointSize, float: 27)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.large), query: \.pointSize, float: 28)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraLarge), query: \.pointSize, float: 30)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraLarge), query: \.pointSize, float: 30)
        BONAssert(attributes: testAttributes(UIContentSizeCategory.extraExtraExtraLarge), query: \.pointSize, float: 30)
    }

    func testAdobeAdaptiveTracking() {
        let font = UIFont(name: "Avenir-Book", size: 30)!
        let chain = StringStyle(.font(font), .adapt(.control), .tracking(.adobe(300)))
        let attributes = chain.attributes

        let testKernAdaptation = { (contentSizeCategory: BonMotContentSizeCategory) -> CGFloat in
            let traitCollection = UITraitCollection(preferredContentSizeCategory: contentSizeCategory)
            let adaptedAttributes = NSAttributedString.adapt(attributes: attributes, to: traitCollection)
            return adaptedAttributes[.kern] as? CGFloat ?? 0
        }

        XCTAssertEqual(testKernAdaptation(UIContentSizeCategory.extraSmall), 8.1, accuracy: 0.0001)
        XCTAssertEqual(testKernAdaptation(UIContentSizeCategory.large), 9, accuracy: 0.0001)
        XCTAssertEqual(testKernAdaptation(UIContentSizeCategory.extraExtraExtraLarge), 10.8, accuracy: 0.0001)
    }

    /// Test that font feature settings overrides persist through
    /// Dynamic Type adaptation
    func testFeatureSettingsAdaptation() {
        EBGaramondLoader.loadFontIfNeeded()
        let partsLine: UInt = #line; let partsTuples: [(part: StringStyle.Part, representsDefault: Bool)] = [
            (.numberCase(.upper), false),
            (.numberCase(.lower), false),
            (.numberSpacing(.monospaced), false),
            (.numberSpacing(.proportional), false),
            (.fractions(.disabled), true),
            (.fractions(.diagonal), false),
            (.superscript(true), false),
            (.superscript(false), true),
            (.`subscript`(true), false),
            (.`subscript`(false), true),
            (.ordinals(true), false),
            (.ordinals(false), true),
            (.scientificInferiors(true), false),
            (.scientificInferiors(false), true),
            (.smallCaps(.disabled), true),
            (.smallCaps(.fromUppercase), false),
            (.smallCaps(.fromLowercase), false),
            (.stylisticAlternates(.one(on: true)), false),  // these are the supported stylistic alternates for EBGaramond12-Regular
            (.stylisticAlternates(.one(on: false)), true),
            (.stylisticAlternates(.two(on: true)), false),
            (.stylisticAlternates(.two(on: false)), true),
            (.stylisticAlternates(.five(on: true)), false),
            (.stylisticAlternates(.five(on: false)), true),
            (.stylisticAlternates(.six(on: true)), false),
            (.stylisticAlternates(.six(on: false)), true),
            (.stylisticAlternates(.seven(on: true)), false),
            (.stylisticAlternates(.seven(on: false)), true),
            (.stylisticAlternates(.twenty(on: true)), false),
            (.stylisticAlternates(.twenty(on: false)), true),
            (.contextualAlternates(.contextualAlternates(on: true)), true),
            ]
        for (index, tuple) in partsTuples.enumerated() {
            let partLine = partsLine + UInt(index) + 1
            let originalAttributes = StringStyle(.font(BONFont(name: "EBGaramond12-Regular", size: 24)!), .adapt(.control)).byAdding(tuple.part).attributes
            let adaptedAttributes = NSAttributedString.adapt(attributes: originalAttributes, to: UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory.extraSmall))

            XCTAssertEqual(originalAttributes.count, 3, line: partLine)
            XCTAssertEqual(adaptedAttributes.count, 3, line: partLine)

            let originalFont = originalAttributes[.font] as? BONFont
            let adaptedFont = adaptedAttributes[.font] as? BONFont

            XCTAssertNotNil(originalFont, line: partLine)
            XCTAssertNotNil(adaptedFont, line: partLine)

            // If a font feature represents the default value, it will be stripped
            // from a font descriptor's attributes dictionary when a new descriptor
            // is created, so there is no point in testing for its presence.
            if !tuple.representsDefault {
                let originalDescriptorAttributes = originalFont?.fontDescriptor.fontAttributes
                let adaptedDescriptorAttributes = adaptedFont?.fontDescriptor.fontAttributes

                let originalFeatureAttributeArray = originalDescriptorAttributes?[BONFontDescriptorFeatureSettingsAttribute] as? NSArray
                let adaptedFeatureAttributeArray = adaptedDescriptorAttributes?[BONFontDescriptorFeatureSettingsAttribute] as? NSArray

                XCTAssertNotNil(originalFeatureAttributeArray, line: partLine)
                XCTAssertNotNil(adaptedFeatureAttributeArray, line: partLine)

                XCTAssertEqual(originalFeatureAttributeArray?.count, 1, line: partLine)
                XCTAssertEqual(adaptedFeatureAttributeArray?.count, 1, line: partLine)

                let originalFeatureAttributes = originalFeatureAttributeArray?.firstObject as? [BONFontDescriptor.FeatureKey: Int]
                let adaptedFeatureAttributes = adaptedFeatureAttributeArray?.firstObject as? [BONFontDescriptor.FeatureKey: Int]

                XCTAssertNotNil(originalFeatureAttributes, line: partLine)
                XCTAssertNotNil(adaptedFeatureAttributes, line: partLine)

                XCTAssertEqual(originalFeatureAttributes?[BONFontFeatureTypeIdentifierKey], adaptedFeatureAttributes?[BONFontFeatureTypeIdentifierKey], line: partLine)
                XCTAssertEqual(originalFeatureAttributes?[BONFontFeatureSelectorIdentifierKey], adaptedFeatureAttributes?[BONFontFeatureSelectorIdentifierKey], line: partLine)
            }
        }
    }

    func testTabAdaptation() {
        func firstTabLocation(attributedString string: NSAttributedString) -> CGFloat {
            guard let paragraph = string.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle else {
                XCTFail("Unable to get paragraph")
                return 0
            }
            return paragraph.tabStops[0].location
        }
        EBGaramondLoader.loadFontIfNeeded()
        let style = StringStyle(.font(BONFont(name: "EBGaramond12-Regular", size: 20)!), .numberSpacing(.monospaced), .adapt(.control))
        let tabTestL = NSAttributedString.composed(of: ["Q", Tab.headIndent(10)], baseStyle: style)
        XCTAssertEqual(firstTabLocation(attributedString: tabTestL), 26.12, accuracy: 0.01)
        let tabTestXS = tabTestL.adapted(to: UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory.extraSmall))
        XCTAssertEqual(firstTabLocation(attributedString: tabTestXS), 23.70, accuracy: 0.01)
        let tabTestXXXL = tabTestL.adapted(to: UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory.extraExtraExtraLarge))
        XCTAssertEqual(firstTabLocation(attributedString: tabTestXXXL), 30.95, accuracy: 0.01)
    }

    func testMergingEmbeddedTransformations() {
        let string = NSAttributedString.composed(of: [
            "Hello".styled(with: .font(UIFont(name: "Avenir-Book", size: 28)!), .tracking(.adobe(3.0))),
            ], baseStyle: StringStyle(.font(UIFont(name: "Avenir-Book", size: 28)!), .adapt(.control)))
        let attributes = string.attribute(BonMotTransformationsAttributeName, at: string.length - 1, effectiveRange: nil) as? [Any]
        XCTAssertEqual(attributes?.count, 2)
    }

    func testComplexAdaptiveComposition() {
        let string = NSAttributedString.composed(of: [
            "Hello".styled(with: .tracking(.adobe(3.0))),
            Tab.headIndent(10),
            ], baseStyle: StringStyle(.font(UIFont(name: "Avenir-Book", size: 28)!), .adapt(.control)))

        let attributes1 = string.attribute(BonMotTransformationsAttributeName, at: 0, effectiveRange: nil) as? [Any]
        let attributes2 = string.attribute(BonMotTransformationsAttributeName, at: string.length - 1, effectiveRange: nil) as? [Any]
        XCTAssertEqual(attributes1?.count, 2)
        XCTAssertEqual(attributes2?.count, 2)
    }

}

#endif
