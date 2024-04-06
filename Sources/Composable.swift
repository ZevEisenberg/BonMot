//
//  Composable.swift
//  BonMot
//
//  Created by Brian King on 9/28/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

/// Describes types which know how to append themselves to an attributed string.
/// Used to provide a flexible, extensible chaining API for BonMot.
public protocol Composable {

    /// Append the receiver to a given attributed string. It is up to the
    /// receiver's type to define what it means to be appended to an attributed
    /// string. Typically, the receiver will pick up the attributes of the last
    /// character of the passed attributed string, but the `baseStyle` parameter
    /// can be used to provide additional attributes for the appended string.
    ///
    /// - Parameters:
    ///   - attributedString: The attributed string to which to append the
    ///                       receiver.
    ///   - baseStyle: Additional attributes to apply to the receiver before
    ///                appending it to the passed attributed string.
    func append(to attributedString: NSMutableAttributedString, baseStyle: StringStyle)

    /// Append the receiver to a given attributed string. It is up to the
    /// receiver's type to define what it means to be appended to an attributed
    /// string. Typically, the receiver will pick up the attributes of the last
    /// character of the passed attributed string, but the `baseStyle` parameter
    /// can be used to provide additional attributes for the appended string.
    ///
    /// - Parameters:
    ///   - attributedString: The attributed string to which to append the
    ///                       receiver.
    ///   - baseStyle: Additional attributes to apply to the receiver before
    ///                appending it to the passed attributed string.
    ///   - isLastElement: Whether the receiver is the final element that is
    ///                    being appended to an attributed string. Used in cases
    ///                    where the receiver wants to customize how it is
    ///                    appended if it knows it is the last element, chiefly
    ///                    regarding NSAttributedStringKey.kern.
    func append(to attributedString: NSMutableAttributedString, baseStyle: StringStyle, isLastElement: Bool)

}

extension Composable {

    public func append(to attributedString: NSMutableAttributedString, baseStyle: StringStyle) {
        append(to: attributedString, baseStyle: baseStyle, isLastElement: false)
    }

    /// Create an attributed string with only this composable content, and no
    /// base style.
    ///
    /// - returns: a new `NSAttributedString`
    public func attributedString() -> NSAttributedString {
        return .composed(of: [self])
    }

    /// Create a new `NSAttributedString` with the style specified.
    ///
    /// - parameter style: The style to use.
    /// - parameter overrideParts: The style parts to override on the base style.
    /// - parameter stripTrailingKerning: whether to strip NSAttributedStringKey.kern
    ///                                   from the last character of the result.
    /// - returns: A new `NSAttributedString`.
    public func styled(with style: StringStyle, _ overrideParts: StringStyle.Part..., stripTrailingKerning: Bool = true) -> NSAttributedString {
        let string = NSMutableAttributedString()
        let newStyle = style.byAdding(stringStyle: StringStyle(overrideParts))
        append(to: string, baseStyle: newStyle, isLastElement: stripTrailingKerning)
        return string
    }

    /// Create a new `NSAttributedString` with the style parts specified.
    ///
    /// - parameter parts: The style parts to use.
    /// - parameter stripTrailingKerning: whether to strip NSAttributedStringKey.kern
    ///                                   from the last character of the result.
    /// - returns: A new `NSAttributedString`.
    public func styled(with parts: StringStyle.Part..., stripTrailingKerning: Bool = true) -> NSAttributedString {
        var style = StringStyle()
        for part in parts {
            style.update(part: part)
        }
        return styled(with: style, stripTrailingKerning: stripTrailingKerning)
    }

}

extension NSAttributedString {

    /// Compose an `NSAttributedString` by concatenating every item in
    /// `composables` with `baseStyle` applied. The `separator` is inserted
    /// between every item. `baseStyle` acts as the default style, and apply to
    /// the `Composable` item only if the `Composable` does not have a style
    /// value configured.
    ///
    /// - parameter composables: An array of `Composable` to join into an
    ///                          `NSAttributedString`.
    /// - parameter baseStyle: The base style to apply to every `Composable`.
    ///                        If no `baseStyle` is supplied, no additional
    ///                        styling will be added.
    /// - parameter separator: The separator to insert between every pair of
    ///                        elements in `composables`.
    /// - returns: A new `NSAttributedString`.
    @nonobjc public static func composed(of composables: [Composable], baseStyle: StringStyle = StringStyle(), separator: Composable? = nil) -> NSAttributedString {
        let string = NSMutableAttributedString()
        string.beginEditing()
        let lastComposableIndex = composables.endIndex
        for (index, composable) in composables.enumerated() {
            composable.append(to: string, baseStyle: baseStyle, isLastElement: index == lastComposableIndex - 1)
            if let separator = separator {
                if index != composables.indices.last {
                    separator.append(to: string, baseStyle: baseStyle)
                }
            }
        }
        string.endEditing()
        return string
    }

    /// Compose an `NSAttributedString` by concatenating every item in
    /// `composables` with `baseStyle` applied. The `separator` is inserted
    /// between every item. `baseStyle` acts as the default style, and apply to
    /// the `Composable` item only if the `Composable` does not have a style
    /// value configured.
    ///
    /// - parameter composables: A list of `Composable` to join into an
    ///                          `NSAttributedString`.
    /// - parameter baseStyle: The base style to apply to every `Composable`.
    ///                        If no `baseStyle` is supplied, no additional
    ///                        styling will be added.
    /// - parameter separator: The separator to insert between every pair of
    ///                        elements in `composables`.
    /// - returns: A new `NSAttributedString`.    
    @nonobjc public static func composed(of composables: Composable..., baseStyle: StringStyle = StringStyle(), separator: Composable? = nil) -> NSAttributedString {
        return .composed(of: composables, baseStyle: baseStyle, separator: separator)
    }

    public func styled(with style: StringStyle, _ overrideParts: StringStyle.Part...) -> NSAttributedString {
        let newStyle = style.byAdding(overrideParts)
        let newAttributes = newStyle.attributes

        let mutableSelf = mutableStringCopy()
        let fullRange = NSRange(location: 0, length: mutableSelf.string.utf16.count)

        for (key, value) in newAttributes {
            mutableSelf.addAttribute(key, value: value, range: fullRange)
        }
        return mutableSelf.immutableCopy()
    }

}

extension NSAttributedString: Composable {

    /// Append this `NSAttributedString` to `attributedString`, with `baseStyle`
    /// applied as default values. This method enumerates all attribute ranges
    /// in the receiver and use `baseStyle` to supply defaults for the attributes.
    /// This effectively merges `baseStyle` and the embedded attributes, with a
    /// tie going to the embedded attributes.
    /// 
    /// See `StringStyle.supplyDefaults(for:)` for more details.
    ///
    /// - parameter to:        The attributed string to which to append the receiver.
    /// - parameter baseStyle: The `StringStyle` that is overridden by the
    ///                        receiver's attributes
    @nonobjc public final func append(to attributedString: NSMutableAttributedString, baseStyle: StringStyle, isLastElement: Bool) {
        let range = NSRange(location: 0, length: length)
        enumerateAttributes(in: range, options: []) { (attributes, range, _) in
            let substring = self.attributedSubstring(from: range)
            // Add the string with the defaults supplied by the style
            let newString = baseStyle.attributedString(from: substring.string, existingAttributes: attributes)
            attributedString.append(newString)
        }

        if isLastElement {
            attributedString.removeKerningFromLastCharacter()
        }
        else {
            attributedString.restoreKerningOnLastCharacter()
        }
    }

}

extension String: Composable {

    /// Append the receiver to `attributedString`, with `baseStyle` applied as
    /// default values. Since `String` has no style, `baseStyle` is the only 
    /// style that is used.
    ///
    /// - parameter to:        The attributed string to which to append the receiver.
    /// - parameter baseStyle: The style to use for this string.
    public func append(to attributedString: NSMutableAttributedString, baseStyle: StringStyle, isLastElement: Bool) {
        attributedString.append(baseStyle.attributedString(from: self))
        if isLastElement {
            attributedString.removeKerningFromLastCharacter()
        }
        else {
            attributedString.restoreKerningOnLastCharacter()
        }
    }

}

#if !os(watchOS)
extension BONImage: Composable {

    /// Append the receiver to `attributedString`, with `baseStyle` applied as
    /// default values. Only a few properties in `baseStyle` are relevant when
    /// styling images. These include `baselineOffset`, as well as `color` for
    /// template images. All attributes are stored in the range of the image for
    /// consistency inside the attributed string.
    ///
    /// - note: the `NSBaselineOffsetAttributeName` value is used as the
    /// `bounds.origin.y` value for the text attachment, and is removed from the
    /// attributes dictionary to fix an issue with UIKit.
    ///
    /// - note: `NSTextAttachment` is not available on watchOS.
    ///
    /// - parameter to:        The attributed string to which to append the receiver.
    /// - parameter baseStyle: The style to use.
    @nonobjc public final func append(to attributedString: NSMutableAttributedString, baseStyle: StringStyle, isLastElement: Bool) {
        let baselinesOffsetForAttachment = baseStyle.baselineOffset ?? 0
        let attachment = NSTextAttachment()

        #if canImport(AppKit)
            let imageIsTemplate = isTemplate
        #else
            let imageIsTemplate = (renderingMode != .alwaysOriginal)
        #endif

        var imageToUse = self
        if let color = baseStyle.color {
            if imageIsTemplate {
                imageToUse = tintedImage(color: color)
            }
        }
        attachment.image = imageToUse

        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: baselinesOffsetForAttachment), size: size)

        let attachmentString = NSAttributedString(attachment: attachment).mutableStringCopy()
        // Remove the baseline offset from the attributes so it isn't applied twice
        var attributes = baseStyle.attributes
        attributes[.baselineOffset] = nil
        attachmentString.addAttributes(attributes, range: NSRange(location: 0, length: attachmentString.length))

        attributedString.append(attachmentString)
    }

}
#endif

extension Special: Composable {

    /// Append the receiver's string value to `attributedString`, with `baseStyle`
    /// applied as default values.
    ///
    /// - parameter to:        The attributed string to which to append the receiver.
    /// - parameter baseStyle: The style to use.
    public func append(to attributedString: NSMutableAttributedString, baseStyle: StringStyle, isLastElement: Bool) {
        description.append(to: attributedString, baseStyle: baseStyle)
    }

}

public extension Sequence where Element: Composable {

    func joined(separator: Composable = "") -> NSAttributedString {
        return NSAttributedString.composed(of: Array(self), separator: separator)
    }

}

extension NSAttributedString.Key {

    public static let bonMotRemovedKernAttribute = NSAttributedString.Key("com.raizlabs.bonmot.removedKernAttributeRemoved")

}

extension NSMutableAttributedString {

    func removeKerningFromLastCharacter() {
        guard length != 0 else {
            return
        }

        let lastCharacterLength = string.suffix(1).utf16.count
        let lastCharacterRange = NSRange(location: length - lastCharacterLength, length: lastCharacterLength)

        guard let currentKernValue = attribute(.kern, at: lastCharacterRange.location, effectiveRange: nil) else {
            return
        }

        removeAttribute(.kern, range: lastCharacterRange)
        addAttribute(.bonMotRemovedKernAttribute, value: currentKernValue, range: lastCharacterRange)
    }

    func restoreKerningOnLastCharacter() {
        guard length != 0 else {
            return
        }

        let lastCharacterLength = string.suffix(1).utf16.count
        let lastCharacterRange = NSRange(location: length - lastCharacterLength, length: lastCharacterLength)

        guard let currentKernValue = attribute(.bonMotRemovedKernAttribute, at: lastCharacterRange.location, effectiveRange: nil) else {
            return
        }

        removeAttribute(.bonMotRemovedKernAttribute, range: lastCharacterRange)
        addAttribute(.kern, value: currentKernValue, range: lastCharacterRange)
    }

}
