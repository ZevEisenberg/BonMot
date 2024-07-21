//
//  StringStyle.swift
//  BonMot
//
//  Created by Brian King on 8/31/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//
// NOTE: Keep attributes in order to help reviewability.

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

/// The primary style container for BonMot, responsible for encapsulating any
/// attributes that are intended to be used with `NSAttributedString`.
public struct StringStyle {

    public var extraAttributes: StyleAttributes = [:]
    public var font: BONFont?
    public var link: URL?
    public var backgroundColor: BONColor?
    public var color: BONColor?
    public var underline: (NSUnderlineStyle, BONColor?)?
    public var strikethrough: (NSUnderlineStyle, BONColor?)?
    public var baselineOffset: CGFloat?

    public var lineSpacing: CGFloat?
    public var paragraphSpacingAfter: CGFloat?
    public var alignment: NSTextAlignment?
    public var firstLineHeadIndent: CGFloat?
    public var headIndent: CGFloat?
    public var tailIndent: CGFloat?
    public var lineBreakMode: NSLineBreakMode?
    public var lineBreakStrategy: NSParagraphStyle.LineBreakStrategy?
    public var minimumLineHeight: CGFloat?
    public var maximumLineHeight: CGFloat?
    public var baseWritingDirection: NSWritingDirection?
    public var lineHeightMultiple: CGFloat?
    public var paragraphSpacingBefore: CGFloat?
    public var hyphenationFactor: Float?
    public var allowsDefaultTighteningForTruncation: Bool?

    #if os(iOS) || os(tvOS) || os(watchOS)
    public var speaksPunctuation: Bool?
    public var speakingLanguage: String?
    public var speakingPitch: Double?
    public var speakingPronunciation: String?
    public var shouldQueueSpeechAnnouncement: Bool?
    public var headingLevel: HeadingLevel?
    #endif

    public var ligatures: Ligatures?

    #if os(OSX) || os(iOS) || os(tvOS)
    public var fontFeatureProviders: [FontFeatureProvider] = []

    public var numberCase: NumberCase?
    public var numberSpacing: NumberSpacing?
    public var fractions: Fractions?

    public var superscript: Bool?
    public var `subscript`: Bool?
    public var ordinals: Bool?
    public var scientificInferiors: Bool?

    public var smallCaps: Set<SmallCaps> = []

    public var stylisticAlternates: StylisticAlternates = StylisticAlternates()
    public var contextualAlternates: ContextualAlternates = ContextualAlternates()
    #endif
    #if os(iOS) || os(tvOS)
    public var adaptations: [AdaptiveStyle] = []
    #endif

    public var emphasis: Emphasis?
    public var tracking: Tracking?
    public var xmlStyler: XMLStyler?
    public var transform: Transform?

    public init() {}
}

extension StringStyle {

    /// A `StyleAttributes` dictionary representing the current style.
    public var attributes: StyleAttributes {
        var theAttributes = extraAttributes

        theAttributes.update(possibleValue: font, forKey: .font)
        theAttributes.update(possibleValue: link, forKey: .link)
        theAttributes.update(possibleValue: backgroundColor, forKey: .backgroundColor)
        theAttributes.update(possibleValue: color, forKey: .foregroundColor)
        theAttributes.update(possibleValue: underline?.0.rawValue, forKey: .underlineStyle)
        theAttributes.update(possibleValue: underline?.1, forKey: .underlineColor)
        theAttributes.update(possibleValue: strikethrough?.0.rawValue, forKey: .strikethroughStyle)
        theAttributes.update(possibleValue: strikethrough?.1, forKey: .strikethroughColor)
        theAttributes.update(possibleValue: baselineOffset, forKey: .baselineOffset)
        theAttributes.update(possibleValue: ligatures?.rawValue, forKey: .ligature)

        #if os(iOS) || os(tvOS) || os(watchOS)
        theAttributes.update(possibleValue: speaksPunctuation, forKey: .accessibilitySpeechPunctuation)
        theAttributes.update(possibleValue: speakingLanguage, forKey: .accessibilitySpeechLanguage)
        theAttributes.update(possibleValue: speakingPitch, forKey: .accessibilitySpeechPitch)
            if #available(iOS 11, tvOS 11, watchOS 4, *) {
                theAttributes.update(possibleValue: speakingPronunciation, forKey: .accessibilitySpeechIPANotation)
                theAttributes.update(possibleValue: shouldQueueSpeechAnnouncement as NSNumber?, forKey: .accessibilitySpeechQueueAnnouncement)
                theAttributes.update(possibleValue: headingLevel?.rawValue as NSNumber?, forKey: .accessibilityTextHeadingLevel)
            }
        #endif

        let paragraph = StringStyle.paragraph(from: theAttributes)
        paragraph.lineSpacing = lineSpacing ?? paragraph.lineSpacing
        paragraph.paragraphSpacing = paragraphSpacingAfter ?? paragraph.paragraphSpacing
        paragraph.alignment = alignment ?? paragraph.alignment
        paragraph.firstLineHeadIndent = firstLineHeadIndent ?? paragraph.firstLineHeadIndent
        paragraph.headIndent = headIndent ?? paragraph.headIndent
        paragraph.tailIndent = tailIndent ?? paragraph.tailIndent
        paragraph.lineBreakMode = lineBreakMode ?? paragraph.lineBreakMode
        paragraph.lineBreakStrategy = lineBreakStrategy ?? paragraph.lineBreakStrategy
        paragraph.minimumLineHeight = minimumLineHeight ?? paragraph.minimumLineHeight
        paragraph.maximumLineHeight = maximumLineHeight ?? paragraph.maximumLineHeight
        paragraph.baseWritingDirection = baseWritingDirection ?? paragraph.baseWritingDirection
        paragraph.lineHeightMultiple = lineHeightMultiple ?? paragraph.lineHeightMultiple
        paragraph.paragraphSpacingBefore = paragraphSpacingBefore ?? paragraph.paragraphSpacingBefore
        paragraph.hyphenationFactor = hyphenationFactor ?? paragraph.hyphenationFactor
        paragraph.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation ?? paragraph.allowsDefaultTighteningForTruncation

        if paragraph != NSParagraphStyle.default {
            theAttributes.update(possibleValue: paragraph, forKey: .paragraphStyle)
        }

        #if os(iOS) || os(tvOS) || os(OSX)
            // Apply the features to the font present
            let preFeaturedFont = theAttributes[.font] as? BONFont
            var featureProviders = fontFeatureProviders

            featureProviders += [numberCase].compactMap { $0 } as [FontFeatureProvider]
            featureProviders += [numberSpacing].compactMap { $0 } as [FontFeatureProvider]
            featureProviders += [fractions].compactMap { $0 } as [FontFeatureProvider]
            featureProviders += [superscript].compactMap { $0 }.map { ($0 ? VerticalPosition.superscript : VerticalPosition.normal) } as [FontFeatureProvider]
            featureProviders += [`subscript`].compactMap { $0 }.map { ($0 ? VerticalPosition.`subscript` : VerticalPosition.normal) } as [FontFeatureProvider]
            featureProviders += [ordinals].compactMap { $0 }.map { $0 ? VerticalPosition.ordinals : VerticalPosition.normal } as [FontFeatureProvider]
            featureProviders += [scientificInferiors].compactMap { $0 }.map { $0 ? VerticalPosition.scientificInferiors : VerticalPosition.normal } as [FontFeatureProvider]
            featureProviders += smallCaps.map { $0 as FontFeatureProvider }
            featureProviders += [stylisticAlternates as FontFeatureProvider]
            featureProviders += [contextualAlternates as FontFeatureProvider]

            let featuredFont = preFeaturedFont?.font(withFeatures: featureProviders)
            theAttributes.update(possibleValue: featuredFont, forKey: .font)
        #endif

        if let font = theAttributes[.font] as? BONFont, let emphasis = emphasis {
            let descriptor = font.fontDescriptor
            let existingTraits = descriptor.symbolicTraits
            let newTraits = existingTraits.union(emphasis.symbolicTraits)

            // Explicit cast to optional because withSymbolicTraits returns an
            // optional on Mac, but not on iOS.
            let newDescriptor: BONFontDescriptor? = descriptor.withSymbolicTraits(newTraits)
            if let newDesciptor = newDescriptor {
                let newFont = BONFont(descriptor: newDesciptor, size: 0)
                theAttributes.update(possibleValue: newFont, forKey: .font)
            }
        }

        #if os(iOS) || os(tvOS)
            // Apply any adaptations
            for adaptation in adaptations {
                theAttributes = adaptation.embed(in: theAttributes)
            }
        #endif

        // Apply tracking
        if let tracking = tracking {
            let styledFont = theAttributes[.font] as? BONFont
            theAttributes.update(possibleValue: tracking.kerning(for: styledFont), forKey: .kern)
            #if os(iOS) || os(tvOS)
                // Add the tracking as an adaptation
                theAttributes = EmbeddedTransformationHelpers.embed(transformation: tracking, to: theAttributes)
            #endif
        }

        return theAttributes
    }

    /// Create an `NSAttributedString` from the specified string.
    /// - parameter from: The `String` to style.
    /// - parameter existingAttributes: The existing attributes, if any, to use
    ///                                 as default values for the style.
    ///
    /// - returns: A new `NSAttributedString`
    public func attributedString(from theString: String, existingAttributes: StyleAttributes? = nil) -> NSAttributedString {
        if let xmlStyler = xmlStyler {
            let builder = XMLBuilder(
                string: theString,
                styler: xmlStyler,
                options: [],
                baseStyle: self
            )
            if let attributedString = try? builder.parseAttributedString() {
                return attributedString
            }
        }
        let tagsApplied = NSAttributedString(string: theString, attributes: supplyDefaults(for: existingAttributes))

        guard let transform = transform else {
            return tagsApplied
        }

        let mutable = tagsApplied.mutableStringCopy()
        let fullRange = NSRange(location: 0, length: mutable.length)
        mutable.enumerateAttributes(in: fullRange, options: [], using: { (_, range, _) in
            let substring = mutable.attributedSubstring(from: range).string
            let transformed = transform.transformer(substring)
            mutable.replaceCharacters(in: range, with: transformed)
        })

        return mutable
    }

}

extension StringStyle {

    /// Update the `extraAttributes` in the style object. This is used to
    /// provide the default values configured in UI elements, which the style
    /// can override.
    ///
    /// - parameter extraAttributes: The attributes to add to the style before
    ///                              applying the other properties.
    public mutating func add(extraAttributes attributes: StyleAttributes) {
        for (key, value) in attributes {
            extraAttributes[key] = value
        }
    }

    /// Update the receiver with values specified in `stringStyle`. Any value
    /// configured in `stringStyle` will overwrite the values specified in the
    /// receiver.
    ///
    /// - parameter stringStyle: The style with which to update this style.
    public mutating func add(stringStyle theStringStyle: StringStyle) {
        add(extraAttributes: theStringStyle.extraAttributes)
        font = theStringStyle.font ?? font
        link = theStringStyle.link ?? link
        backgroundColor = theStringStyle.backgroundColor ?? backgroundColor
        color = theStringStyle.color ?? color
        underline = theStringStyle.underline ?? underline
        strikethrough = theStringStyle.strikethrough ?? strikethrough
        baselineOffset = theStringStyle.baselineOffset ?? baselineOffset

        ligatures = theStringStyle.ligatures ?? ligatures

        #if os(iOS) || os(tvOS) || os(watchOS)
        speaksPunctuation = theStringStyle.speaksPunctuation ?? speaksPunctuation
        speakingLanguage = theStringStyle.speakingLanguage ?? speakingLanguage
        speakingPitch = theStringStyle.speakingPitch ?? speakingPitch
            if #available(iOS 11, tvOS 11, watchOS 4, *) {
                speakingPronunciation = theStringStyle.speakingPronunciation ?? speakingPronunciation
                shouldQueueSpeechAnnouncement = theStringStyle.shouldQueueSpeechAnnouncement ?? shouldQueueSpeechAnnouncement
                headingLevel = theStringStyle.headingLevel ?? headingLevel
            }
        #endif

        lineSpacing = theStringStyle.lineSpacing ?? lineSpacing
        paragraphSpacingAfter = theStringStyle.paragraphSpacingAfter ?? paragraphSpacingAfter
        alignment = theStringStyle.alignment ?? alignment
        firstLineHeadIndent = theStringStyle.firstLineHeadIndent ?? firstLineHeadIndent
        headIndent = theStringStyle.headIndent ?? headIndent
        tailIndent = theStringStyle.tailIndent ?? tailIndent
        lineBreakMode = theStringStyle.lineBreakMode ?? lineBreakMode
        lineBreakStrategy = theStringStyle.lineBreakStrategy ?? lineBreakStrategy
        minimumLineHeight = theStringStyle.minimumLineHeight ?? minimumLineHeight
        maximumLineHeight = theStringStyle.maximumLineHeight ?? maximumLineHeight
        baseWritingDirection = theStringStyle.baseWritingDirection ?? baseWritingDirection
        lineHeightMultiple = theStringStyle.lineHeightMultiple ?? lineHeightMultiple
        paragraphSpacingBefore = theStringStyle.paragraphSpacingBefore ?? paragraphSpacingBefore
        hyphenationFactor = theStringStyle.hyphenationFactor ?? hyphenationFactor
        allowsDefaultTighteningForTruncation = theStringStyle.allowsDefaultTighteningForTruncation ?? allowsDefaultTighteningForTruncation

        #if os(iOS) || os(tvOS) || os(OSX)
            fontFeatureProviders.append(contentsOf: theStringStyle.fontFeatureProviders)

            numberCase = theStringStyle.numberCase ?? numberCase
            numberSpacing = theStringStyle.numberSpacing ?? numberSpacing
            fractions = theStringStyle.fractions ?? fractions

            superscript = theStringStyle.superscript ?? superscript
            `subscript` = theStringStyle.`subscript` ?? `subscript`
            ordinals = theStringStyle.ordinals ?? ordinals
            scientificInferiors = theStringStyle.scientificInferiors ?? scientificInferiors

            smallCaps = theStringStyle.smallCaps.isEmpty ? smallCaps : theStringStyle.smallCaps

            stylisticAlternates.add(other: theStringStyle.stylisticAlternates)
            contextualAlternates.add(other: theStringStyle.contextualAlternates)
        #endif

        if let newEmphasis = theStringStyle.emphasis, let existingEmphasis = emphasis {
            // If we have both new and existing, merge them
            emphasis = existingEmphasis.union(newEmphasis)
        }
        else if let newEmphasis = theStringStyle.emphasis {
            // If we have only new, just replace existing
            emphasis = newEmphasis
        }

        #if os(iOS) || os(tvOS)
            adaptations.append(contentsOf: theStringStyle.adaptations)
        #endif
        tracking = theStringStyle.tracking ?? tracking
        xmlStyler = theStringStyle.xmlStyler ?? xmlStyler
        transform = theStringStyle.transform ?? transform
    }

    public func byAdding(stringStyle style: StringStyle) -> StringStyle {
        var newStyle = self
        newStyle.add(stringStyle: style)
        return newStyle
    }

}

public extension StringStyle {

    /// Supply the receiver's attributes as default values for the passed
    /// `StyleAttributes` dictionary. This will also perform some merging of
    /// values. This includes `NSParagraphStyle` and the receiver's attributes.
    ///
    /// - parameter for: The object with which to overwrite the defaults.
    /// - returns: The new attributes
    func supplyDefaults(for attributes: StyleAttributes?) -> StyleAttributes {
        guard var attributes = attributes else {
            return self.attributes
        }
        for (key, value) in self.attributes {
            switch (key, value, attributes[key]) {
            case (.paragraphStyle, let paragraph as NSParagraphStyle, let otherParagraph as NSParagraphStyle):
                attributes[.paragraphStyle] = paragraph.supplyDefaults(for: otherParagraph)
            case (BonMotTransformationsAttributeName,
                var transformations as [Any],
                let otherTransformations as [Any]):
                transformations.append(contentsOf: otherTransformations)
                attributes[BonMotTransformationsAttributeName] = transformations
            case let (key, value, nil):
                attributes.update(possibleValue: value, forKey: key)
            default:
                break
            }
        }
        return attributes
    }

    /// A helper to extract an `NSMutableParagraphStyle` from a value in an
    /// attributes dictionary.
    /// - parameter from: the attributes dictionary from which to extract the
    ///                   paragraph style.
    /// - returns: A mutable copy of an `NSParagraphStyle`, or a new
    ///            `NSMutableParagraphStyle` if the value is `nil`.
    static func paragraph(from styleAttributes: StyleAttributes) -> NSMutableParagraphStyle {
        let theObject = styleAttributes[.paragraphStyle]
        let result: NSMutableParagraphStyle
        if let paragraphStyle = theObject as? NSMutableParagraphStyle {
            result = paragraphStyle
        }
        else if let paragraphStyle = theObject as? NSParagraphStyle {
            result = paragraphStyle.mutableParagraphStyleCopy()
        }
        else {
            result = NSMutableParagraphStyle()
        }
        return result
    }

 }

extension NSParagraphStyle {

    // swiftlint:disable cyclomatic_complexity
    /// Update the passed `NSParagraphStyle`'s properties with the value in this
    /// the receiver (only if the supplied `NSParagraphStyle`'s value for a
    /// given property is the default value).
    ///
    /// - Parameter paragraphStyle: The paragraph style to update.
    /// - Returns: The updated paragraph style.
    func supplyDefaults(for paragraphStyle: NSParagraphStyle) -> NSParagraphStyle {
        let defaults = NSParagraphStyle.default
        let paragraph = paragraphStyle.mutableParagraphStyleCopy()
        if paragraph.lineSpacing == defaults.lineSpacing { paragraph.lineSpacing = lineSpacing }
        if paragraph.paragraphSpacing == defaults.paragraphSpacing { paragraph.paragraphSpacing = paragraphSpacing }
        if paragraph.alignment == defaults.alignment { paragraph.alignment = alignment }
        if paragraph.firstLineHeadIndent == defaults.firstLineHeadIndent { paragraph.firstLineHeadIndent = firstLineHeadIndent }
        if paragraph.headIndent == defaults.headIndent { paragraph.headIndent = headIndent }
        if paragraph.tailIndent == defaults.tailIndent { paragraph.tailIndent = tailIndent }
        if paragraph.lineBreakMode == defaults.lineBreakMode { paragraph.lineBreakMode = lineBreakMode }
        if paragraph.lineBreakStrategy == defaults.lineBreakStrategy { paragraph.lineBreakStrategy = lineBreakStrategy }
        if paragraph.minimumLineHeight == defaults.minimumLineHeight { paragraph.minimumLineHeight = minimumLineHeight }
        if paragraph.maximumLineHeight == defaults.maximumLineHeight { paragraph.maximumLineHeight = maximumLineHeight }
        if paragraph.baseWritingDirection == defaults.baseWritingDirection { paragraph.baseWritingDirection = baseWritingDirection }
        if paragraph.lineHeightMultiple == defaults.lineHeightMultiple { paragraph.lineHeightMultiple = lineHeightMultiple }
        if paragraph.paragraphSpacingBefore == defaults.paragraphSpacingBefore { paragraph.paragraphSpacingBefore = paragraphSpacingBefore }
        if paragraph.hyphenationFactor == defaults.hyphenationFactor { paragraph.hyphenationFactor = hyphenationFactor }
        if paragraph.tabStops == defaults.tabStops { paragraph.tabStops = tabStops }
        if paragraph.allowsDefaultTighteningForTruncation == defaults.allowsDefaultTighteningForTruncation { paragraph.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation }
        return paragraph
    }
    // swiftlint:enable cyclomatic_complexity

}

extension Dictionary {

    /// Set a given value in a `Dictionary`, but only if that value is non-nil.
    ///
    /// - Parameters:
    ///   - value: The new value to insert into the dictionary if it is non-nil.
    ///   - key: The key for which to set the value.
    internal mutating func update(possibleValue value: Value?, forKey key: Key) {
        if let value = value {
            self[key] = value
        }
    }

}
