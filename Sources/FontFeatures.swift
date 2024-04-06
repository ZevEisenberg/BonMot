//
//  FontFeatures.swift
//  BonMot
//
//  Created by Brian King on 8/31/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

// This is not supported on watchOS
#if os(iOS) || os(tvOS) || os(OSX)

    /// Protocol to provide values to be used by `UIFontFeatureTypeIdentifierKey`
    /// and `UIFontFeatureSelectorIdentifierKey`. You can typically find these
    /// values in CoreText.SFNTLayoutTypes.
    public protocol FontFeatureProvider {
        func featureSettings() -> [(type: Int, selector: Int)]
    }

    extension BONFont {

        /// Create a new font and attempt to enable the specified font features.
        /// The returned font will have all features enabled that it supports.
        /// - parameter withFeatures: the features to attempt to enable on the
        ///                           font.
        /// - returns: a new font with the specified features enabled.
        public func font(withFeatures featureProviders: [FontFeatureProvider]) -> BONFont {

            guard featureProviders.count > 0 else {
                return self
            }

            let newFeatures = featureProviders.flatMap { $0.featureAttributes() }

            guard newFeatures.count > 0 else {
                return self
            }

            var fontAttributes = fontDescriptor.fontAttributes
            var features = fontAttributes[BONFontDescriptorFeatureSettingsAttribute] as? [[BONFontDescriptor.FeatureKey: Any]] ?? []

            features.append(contentsOf: newFeatures)
            fontAttributes[BONFontDescriptorFeatureSettingsAttribute] = features

            let descriptor = BONFontDescriptor(fontAttributes: fontAttributes)
            #if canImport(AppKit)
                return BONFont(descriptor: descriptor, size: pointSize)!
            #else
                return BONFont(descriptor: descriptor, size: pointSize)
            #endif
        }

    }

    /// A feature provider for changing the number case, also known as "figure
    /// style".
    public enum NumberCase: FontFeatureProvider {

        /// Uppercase numbers, also known as "lining figures", are the same height
        /// as uppercase letters, and they do not extend below the baseline.
        case upper

        /// Lowercase numbers, also known as "oldstyle figures", are similar in
        /// size and visual weight to lowercase letters, allowing them to
        /// blend in better in a block of text. They may have descenders
        /// which drop below the typographic baseline.
        case lower

        public func featureSettings() -> [(type: Int, selector: Int)] {
            switch self {
            case .upper:
                return [(type: kNumberCaseType, selector: kUpperCaseNumbersSelector)]
            case .lower:
                return [(type: kNumberCaseType, selector: kLowerCaseNumbersSelector)]
            }
        }

    }

    /// A feature provider for changing the number spacing, also known as
    /// "figure spacing".
    public enum NumberSpacing: FontFeatureProvider {

        /// Monospaced numbers, also known as "tabular figures", each take up
        /// the same amount of horizontal space, meaning that different numbers
        /// will line up when arranged in columns.
        case monospaced

        /// Proportionally spaced numbers, also known as "proportional figures",
        /// are of variable width. This makes them look better in most cases,
        /// but they should be avoided when numbers need to line up in columns.
        case proportional

        public func featureSettings() -> [(type: Int, selector: Int)] {
            switch self {
            case .monospaced:
                return [(type: kNumberSpacingType, selector: kMonospacedNumbersSelector)]
            case .proportional:
                return [(type: kNumberSpacingType, selector: kProportionalNumbersSelector)]
            }
        }

    }

    /// A feature provider for displaying a fraction.
    public enum Fractions: FontFeatureProvider {

        /// No fraction formatting.
        case disabled

        /// Diagonal Fractions, when written on paper, are written on one line
        /// with the numerator diagonally above and to the left of the
        /// denominator, with the slash ("/") between them.
        case diagonal

        /// Vertical Fractions, when written on paper, are written on one line
        /// with the numerator directly above the
        /// denominator, with a line lying horizontally between them.
        case vertical

        public func featureSettings() -> [(type: Int, selector: Int)] {
            switch self {
            case .disabled:
                return [(type: kFractionsType, selector: kNoFractionsSelector)]
            case .diagonal:
                return [(type: kFractionsType, selector: kDiagonalFractionsSelector)]
            case .vertical:
                return [(type: kFractionsType, selector: kVerticalFractionsSelector)]
            }
        }

    }

    /// A feature provider for changing the vertical position of characters
    /// using predefined styles in the font, such as superscript and subscript.
    public enum VerticalPosition: FontFeatureProvider {

        /// No vertical position adjustment is applied.
        case normal

        /// Superscript (superior) glyph variants are used, as in footnotes¹.
        case superscript

        /// Subscript (inferior) glyph variants are used: vₑ.
        case `subscript`

        /// Ordinal glyph variants are used, as in the common typesetting of 4th.
        case ordinals

        /// Scientific inferior glyph variants are used: H₂O
        case scientificInferiors

        public func featureSettings() -> [(type: Int, selector: Int)] {
            let selector: Int
            switch self {
            case .normal: selector = kNormalPositionSelector
            case .superscript: selector = kSuperiorsSelector
            case .`subscript`: selector = kInferiorsSelector
            case .ordinals: selector = kOrdinalsSelector
            case .scientificInferiors: selector = kScientificInferiorsSelector
            }
            return [(type: kVerticalPositionType, selector: selector)]
        }

    }

    /// A feature provider for changing small caps behavior.
    /// - Note: `fromUppercase` and `fromLowercase` can be combined: they are not
    /// mutually exclusive.
    public enum SmallCaps: FontFeatureProvider {

        /// No small caps are used.
        case disabled

        /// Uppercase letters in the source string are replaced with small caps.
        /// Lowercase letters remain unmodified.
        case fromUppercase

        /// Lowercase letters in the source string are replaced with small caps.
        /// Uppercase letters remain unmodified.
        case fromLowercase

        public func featureSettings() -> [(type: Int, selector: Int)] {
            switch self {
            case .disabled:
                return [
                    (type: kLowerCaseType, selector: kDefaultLowerCaseSelector),
                    (type: kUpperCaseType, selector: kDefaultUpperCaseSelector),
                ]
            case .fromUppercase:
                return [(type: kUpperCaseType, selector: kUpperCaseSmallCapsSelector)]
            case .fromLowercase:
                return [(type: kLowerCaseType, selector: kLowerCaseSmallCapsSelector)]
            }
        }

    }

    extension FontFeatureProvider {

        /// - returns: an array of dictionaries, each representing one feature
        ///            for the attributes key in the font attributes dictionary.
        func featureAttributes() -> [[BONFontDescriptor.FeatureKey: Any]] {
            let featureSettings = self.featureSettings()
            return featureSettings.map {
                [
                    BONFontFeatureTypeIdentifierKey: $0.type,
                    BONFontFeatureSelectorIdentifierKey: $0.selector,
                    ]
            }
        }

    }

#endif
