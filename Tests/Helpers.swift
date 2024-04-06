//
//  Helpers.swift
//  BonMot
//
//  Created by Brian King on 8/29/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

@testable import BonMot
import Foundation
import XCTest

// Override Foundation's StringStyle from iOS 15+, macOS 12+, tvOS 15+, watchOS 8+.
typealias StringStyle = BonMot.StringStyle

#if os(iOS) || os(tvOS)
    import UIKit
    let titleTextStyle = UIFont.TextStyle.title1
    let differentTextStyle = UIFont.TextStyle.title2
    @available(iOS 10.0, tvOS 10.0, *)
    let largeTraitCollection = UITraitCollection(preferredContentSizeCategory: .large)
#endif

let testBundle: Bundle = {
    #if SWIFT_PACKAGE
    let testBundle = Bundle.module
    #else
    class DummyClassForTests {}
    let testBundle = Bundle(for: DummyClassForTests.self)
    #endif
    return testBundle
}()

extension BONColor {

    static var colorA: BONColor {
        return red
    }
    static var colorB: BONColor {
        return blue
    }
    static var colorC: BONColor {
        return purple
    }

}

extension BONColor {

    typealias RGBAComponents = (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)
    var rgbaComponents: RGBAComponents {
        var comps: RGBAComponents = (0, 0, 0, 0)
        getRed(&comps.r, green: &comps.g, blue: &comps.b, alpha: &comps.a)
        return comps
    }

}

extension BONFont {

    static var fontA: BONFont {
        return BONFont(name: "Avenir-Roman", size: 30)!
    }

    static var fontB: BONFont {
        return BONFont(name: "Avenir-Roman", size: 20)!
    }

}

let styleA = StringStyle(
    .font(.fontA),
    .color(.colorA)
)

let styleB = StringStyle(
    .font(.fontB),
    .color(.colorB),
    .headIndent(10),
    .tailIndent(10)
)

#if os(iOS) || os(tvOS)
let adaptiveStyle = StringStyle(
    .font(.fontA),
    .color(.colorA),
    .adapt(.body)
)
#endif

let styleBz = StringStyle(
    .font(.fontB),
    .color(.colorB),
    .headIndent(10),
    .tailIndent(10)
)

/// A fully populated style object that is updated to ensure that `update`
/// overwrites all values correctly. Values in this style object should not be
/// used by any test using `checks(for:)` to ensure no false positives.
let fullStyle: StringStyle = {
    let terribleValue = CGFloat(1000000)
    var fullStyle = StringStyle()
    fullStyle.font = BONFont(name: "Copperplate", size: 20)
    fullStyle.link = URL(string: "http://www.rightpoint.com/")
    fullStyle.backgroundColor = .colorC
    fullStyle.color = .colorC

    fullStyle.underline = (.byWord, .colorC)
    fullStyle.strikethrough = (.byWord, .colorC)

    fullStyle.baselineOffset = terribleValue

    #if os(iOS) || os(tvOS) || os(watchOS)
        fullStyle.speaksPunctuation = true
        fullStyle.speakingLanguage = "pt-BR" // Brazilian Portuguese
        fullStyle.speakingPitch = 1.5
        fullStyle.speakingPronunciation = "ˈɡɪər"
        fullStyle.shouldQueueSpeechAnnouncement = false
        fullStyle.headingLevel = .two
    #endif

    fullStyle.ligatures = .disabled // not the default value

    fullStyle.lineSpacing = terribleValue

    fullStyle.paragraphSpacingAfter = terribleValue
    fullStyle.alignment = .left
    fullStyle.firstLineHeadIndent = terribleValue
    fullStyle.headIndent = terribleValue
    fullStyle.tailIndent = terribleValue
    fullStyle.lineBreakMode = .byTruncatingMiddle
    fullStyle.minimumLineHeight = terribleValue
    fullStyle.maximumLineHeight = terribleValue
    fullStyle.baseWritingDirection = .rightToLeft
    fullStyle.lineHeightMultiple = terribleValue
    fullStyle.paragraphSpacingBefore = terribleValue
    fullStyle.hyphenationFactor = Float(terribleValue)
    fullStyle.allowsDefaultTighteningForTruncation = true

    #if os(iOS) || os(tvOS) || os(OSX)
        fullStyle.fontFeatureProviders = [NumberCase.upper, NumberSpacing.proportional, VerticalPosition.superscript]
        fullStyle.numberCase = .upper
        fullStyle.numberSpacing = .proportional
        fullStyle.fractions = .diagonal
        fullStyle.superscript = true
        fullStyle.`subscript` = true
        fullStyle.ordinals = true
        fullStyle.scientificInferiors = true
        fullStyle.smallCaps = [.fromUppercase]
        fullStyle.stylisticAlternates = .three(on: true)
        fullStyle.contextualAlternates = .contextualSwashAlternates(on: true)
    #endif
    #if os(iOS) || os(tvOS)
        fullStyle.adaptations = [.preferred, .control, .body]
    #endif
    fullStyle.tracking = .adobe(terribleValue)
    return fullStyle
}()

/// Utility to load the EBGaramond font if needed.
class EBGaramondLoader: NSObject {

    static func loadFontIfNeeded() {
        _ = loadFont
    }

    // Can't include font the normal (Plist) way for logic tests, so load it the hard way
    // Source: http://stackoverflow.com/questions/14735522/can-i-embed-a-custom-font-in-a-bundle-and-access-it-from-an-ios-framework
    // Method: https://marco.org/2012/12/21/ios-dynamic-font-loading
    private static var loadFont: Void = {
        guard let path = testBundle.path(forResource: "EBGaramond12-Regular", ofType: "otf"),
            let data = NSData(contentsOfFile: path)
            else {
                fatalError("Can not load EBGaramond12")
        }

        guard let provider = CGDataProvider(data: data) else {
            fatalError("Can not create provider")
        }
        let fontRef = CGFont(provider)

        var error: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(fontRef!, &error)

        if let error = error {
            fatalError("Unable to load font: \(error)")
        }
    }()

}

extension NSAttributedString {

    func rangesFor<T>(attribute name: String) -> [String: T] {
        var attributesByRange: [String: T] = [:]
        enumerateAttribute(NSAttributedString.Key(name), in: NSRange(location: 0, length: length), options: []) { value, range, _ in
            if let object = value as? T {
                attributesByRange["\(range.location):\(range.length)"] = object
            }
        }
        return attributesByRange
    }

    #if !os(watchOS)
    func snapshotForTesting() throws -> BONImage {
        let bigSize = CGSize(width: 10_000, height: 10_000)

        // Bug: on macOS, attached images are not taken into account
        // when measuring attributed strings: http://www.openradar.me/28639290
        let boundingRect = boundingRect(with: bigSize, options: .usesLineFragmentOrigin, context: nil)

        guard !boundingRect.isEmpty else {
            struct ImageBoundingRectEmpty: Error {}
            throw ImageBoundingRectEmpty()
        }

        #if canImport(AppKit)
        let image = NSImage(size: boundingRect.size, flipped: false) { rect in
            self.draw(with: boundingRect, options: .usesLineFragmentOrigin, context: nil)
            return true
        }
        return image
        #elseif canImport(UIKit)
        let format = UIGraphicsImageRendererFormat(for: UITraitCollection(displayScale: 1))
        return UIGraphicsImageRenderer(size: boundingRect.size, format: format).image { _ in
            self.draw(with: boundingRect, options: .usesLineFragmentOrigin, context: nil)
        }
        #endif
    }
    #endif

}
