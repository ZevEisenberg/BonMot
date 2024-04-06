//
//  StringStyle+Part.swift
//  BonMot
//
//  Created by Brian King on 9/1/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

extension StringStyle {

    /// Each `Part` encapsulates one setting in a `StringStyle`. It is used
    /// in a DSL for building `StringStyle` across BonMot.
    public enum Part {

        case extraAttributes(StyleAttributes)
        case font(BONFont)
        case link(URL)
        case backgroundColor(BONColor)
        case color(BONColor)
        case underline(NSUnderlineStyle, BONColor?)
        case strikethrough(NSUnderlineStyle, BONColor?)
        case baselineOffset(CGFloat)

        #if os(iOS) || os(tvOS) || os(watchOS)

        /// If set to `true`, when the string is read aloud, all punctuation will
        /// be spoken aloud as well.
        case speaksPunctuation(Bool)

        /// The BCP 47 language code that you would like the system to use when
        /// reading this string aloud. A BCP 47 language code is generally of
        /// the form “language-REGION”, e.g. “en-US”. You can see a [list of
        /// languages and regions](http://www.iana.org/assignments/language-subtag-registry/language-subtag-registry)
        /// and learn more about [BCP 47](https://www.rfc-editor.org/rfc/rfc5646.txt).
        case speakingLanguage(String)

        /// The pitch of the voice used to read the text aloud. The range is
        /// 0 to 2, where 0 is the lowest, 2 is the highest, and 1 is the default.
        case speakingPitch(Double)

        /// The IPA pronunciation of the given range.
        case speakingPronunciation(String)

        /// Whether the spoken text is queued behind, or interrupts, existing spoken content.
        case shouldQueueSpeechAnnouncement(Bool)

        /// The accessibility heading level of the text.
        case headingLevel(HeadingLevel)
        #endif

        case ligatures(Ligatures)

        case alignment(NSTextAlignment)
        case tracking(Tracking)
        case lineSpacing(CGFloat)
        case paragraphSpacingAfter(CGFloat)
        case firstLineHeadIndent(CGFloat)
        case headIndent(CGFloat)
        case tailIndent(CGFloat)
        case lineBreakMode(NSLineBreakMode)
        case lineBreakStrategy(NSParagraphStyle.LineBreakStrategy)
        case minimumLineHeight(CGFloat)
        case maximumLineHeight(CGFloat)
        case baseWritingDirection(NSWritingDirection)
        case lineHeightMultiple(CGFloat)
        case paragraphSpacingBefore(CGFloat)
        case allowsDefaultTighteningForTruncation(Bool)

        /// Values from 0 to 1 will result in varying levels of hyphenation,
        /// with higher values resulting in more aggressive (i.e. more frequent)
        /// hyphenation.
        ///
        /// Hyphenation is attempted when the ratio of the text width (as broken
        /// without hyphenation) to the width of the line fragment is less than
        /// the hyphenation factor. When the paragraph’s hyphenation factor is
        /// 0.0, the layout manager’s hyphenation factor is used instead. When
        /// both are 0.0, hyphenation is disabled.
        case hyphenationFactor(Float)

        case xml
        case xmlRules([XMLStyleRule])
        case xmlStyler(XMLStyler)
        case transform(Transform)
        #if os(iOS) || os(tvOS) || os(OSX)
        case fontFeature(FontFeatureProvider)

        case numberSpacing(NumberSpacing)
        case numberCase(NumberCase)
        case fractions(Fractions)

        case superscript(Bool)
        case `subscript`(Bool)
        case ordinals(Bool)
        case scientificInferiors(Bool)

        case smallCaps(SmallCaps)

        case stylisticAlternates(StylisticAlternates)
        case contextualAlternates(ContextualAlternates)
        #endif
        #if os(iOS) || os(tvOS)
        case textStyle(BonMotTextStyle)
        #endif
        #if os(iOS) || os(tvOS)
        case adapt(AdaptiveStyle)
        #endif

        case emphasis(Emphasis)

        // An advanced part that allows combining multiple parts as a single part
        case style(StringStyle)

    }

    /// Create a `StringStyle` from zero or more `Part`s.
    ///
    /// - Parameter parts: Zero or more `Part`s
    public init(_ parts: Part...) {
        self.init(parts)
    }

    /// Create a `StringStyle` from an array of parts
    ///
    /// - Parameter parts: An array of `StylePart`s
    public init(_ parts: [Part]) {
        self.init()
        for part in parts {
            update(part: part)
        }
    }

    /// Derive a new `StringStyle` based on this style, updated with zero or
    /// more `Part`s.
    ///
    /// - Parameter parts: Zero or more `Part`s
    /// - Returns: A newly configured `StringStyle`
    public func byAdding(_ parts: Part...) -> StringStyle {
        return byAdding(parts)
    }

    /// Derive a new `StringStyle` based on this style, updated with zero or
    /// more `Part`s.
    ///
    /// - Parameter parts: an array of `Part`s
    /// - Returns: A newly configured `StringStyle`
    public func byAdding(_ parts: [Part]) -> StringStyle {
        var style = self
        for part in parts {
            style.update(part: part)
        }
        return style
    }

    /// Update the style with the specified style part.
    ///
    /// - Parameter stylePart: The style part with which to update the receiver.
    mutating func update(part stylePart: Part) {
        switch stylePart {
        case let .extraAttributes(attributes):
            self.add(extraAttributes: attributes)
        case let .font(font):
            self.font = font
        case let .link(link):
            self.link = link
        case let .backgroundColor(backgroundColor):
            self.backgroundColor = backgroundColor
        case let .color(color):
            self.color = color
        case let .underline(style, color):
            self.underline = (style, color)
        case let .strikethrough(style, color):
            self.strikethrough = (style, color)
        case let .baselineOffset(baselineOffset):
            self.baselineOffset = baselineOffset
        case let .ligatures(ligatures):
            self.ligatures = ligatures
        case let .alignment(alignment):
            self.alignment = alignment
        case let .tracking(tracking):
            self.tracking = tracking
        case let .lineSpacing(lineSpacing):
            self.lineSpacing = lineSpacing
        case let .paragraphSpacingAfter(paragraphSpacingAfter):
            self.paragraphSpacingAfter = paragraphSpacingAfter
        case let .firstLineHeadIndent(firstLineHeadIndent):
            self.firstLineHeadIndent = firstLineHeadIndent
        case let .headIndent(headIndent):
            self.headIndent = headIndent
        case let .tailIndent(tailIndent):
            self.tailIndent = tailIndent
        case let .lineBreakMode(lineBreakMode):
            self.lineBreakMode = lineBreakMode
        case let .lineBreakStrategy(lineBreakStrategy):
            self.lineBreakStrategy = lineBreakStrategy
        case let .minimumLineHeight(minimumLineHeight):
            self.minimumLineHeight = minimumLineHeight
        case let .maximumLineHeight(maximumLineHeight):
            self.maximumLineHeight = maximumLineHeight
        case let .baseWritingDirection(baseWritingDirection):
            self.baseWritingDirection = baseWritingDirection
        case let .lineHeightMultiple(lineHeightMultiple):
            self.lineHeightMultiple = lineHeightMultiple
        case let .paragraphSpacingBefore(paragraphSpacingBefore):
            self.paragraphSpacingBefore = paragraphSpacingBefore
        case .xml:
            self.xmlStyler = NSAttributedString.defaultXMLStyler
        case var .xmlRules(rules):
            rules.append(contentsOf: Special.insertionRules)
            self.xmlStyler = XMLStyleRule.Styler(rules: rules)
        case let .xmlStyler(xmlStyler):
            self.xmlStyler = xmlStyler
        case let .transform(transform):
            self.transform = transform
        case let .style(style):
            self.add(stringStyle: style)
        case let .emphasis(emphasis):
            self.emphasis = emphasis
        case let .hyphenationFactor(hyphenationFactor):
            self.hyphenationFactor = hyphenationFactor
        case let .allowsDefaultTighteningForTruncation(allowsDefaultTighteningForTruncation):
            self.allowsDefaultTighteningForTruncation = allowsDefaultTighteningForTruncation
#if os(iOS) || os(tvOS) || os(watchOS)
        case let .speaksPunctuation(speaksPunctuation):
            self.speaksPunctuation = speaksPunctuation
        case let .speakingLanguage(speakingLanguage):
            self.speakingLanguage = speakingLanguage
        case let .speakingPitch(speakingPitch):
            self.speakingPitch = speakingPitch
        case let .speakingPronunciation(speakingPronunciation):
            self.speakingPronunciation = speakingPronunciation
        case let .shouldQueueSpeechAnnouncement(shouldQueueSpeechAnnouncement):
            self.shouldQueueSpeechAnnouncement = shouldQueueSpeechAnnouncement
        case let .headingLevel(headingLevel):
            self.headingLevel = headingLevel
#endif
#if os(OSX) || os(iOS) || os(tvOS)
        case let .numberCase(numberCase):
            self.numberCase = numberCase
        case let .numberSpacing(numberSpacing):
            self.numberSpacing = numberSpacing
        case let .fractions(fractions):
            self.fractions = fractions
        case let .superscript(superscript):
            self.superscript = superscript
        case let .`subscript`(`subscript`):
            self.`subscript` = `subscript`
        case let .ordinals(ordinals):
            self.ordinals = ordinals
        case let .scientificInferiors(scientificInferiors):
            self.scientificInferiors = scientificInferiors
        case let .smallCaps(smallCaps):
            self.smallCaps.insert(smallCaps)
        case let .stylisticAlternates(stylisticAlternates):
            self.stylisticAlternates.add(other: stylisticAlternates)
        case let .contextualAlternates(contextualAlternates):
            self.contextualAlternates.add(other: contextualAlternates)
        case let .fontFeature(featureProvider):
            self.fontFeatureProviders.append(featureProvider)
#endif
#if os(iOS) || os(tvOS)
        case let .adapt(style):
            self.adaptations.append(style)
        case let .textStyle(textStyle):
            self.font = UIFont.bon_preferredFont(forTextStyle: textStyle, compatibleWith: nil)
#endif
        }
    }
}
