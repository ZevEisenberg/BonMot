//
//  NSAttributedString+BonMot.swift
//  BonMot
//
//  Created by Brian King on 7/19/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

extension NSAttributedString {

    /// Create a copy of `self`, but replace characters in the `Special`
    /// enumeration, images, and unassigned unicode characters with a
    /// human-readable string.
    public var bonMotDebugAttributedString: NSAttributedString {
        let debug = mutableStringCopy()
        var replacements = [(range: NSRange, string: String)]()
        var index = 0

        // When looping over `string.unicodeScalars` directly, we saw
        // nondeterministic behavior where indices after the first one would
        // contain different characters than what was expected. Pulling
        /// `unicodeScalars` out first, and then looping, seems to fix it.
        let scalars = string.unicodeScalars

        for unicode in scalars {
            let replacementString: String?
            switch Special(rawValue: String(unicode)) {
            case .space?:
                replacementString = nil
            case .objectReplacementCharacter?:
                #if os(iOS) || os(tvOS) || os(OSX)
                    if let attachment = attribute(.attachment, at: index, effectiveRange: nil) as? NSTextAttachment, let image = attachment.image {
                        replacementString = String(format: "image size='%.3gx%.3g'", image.size.width, image.size.height)
                    }
                    else {
                        replacementString = Special.objectReplacementCharacter.name
                    }
                #else
                    replacementString = nil
                #endif
            case let value:
                replacementString = value?.name
            }
            let utf16Length = String(unicode).utf16.count
            if let replacementString = replacementString {
                replacements.append((NSRange(location: index, length: utf16Length), replacementString))
            }
            index += utf16Length
        }
        for replacement in replacements.reversed() {
            debug.replaceCharacters(in: replacement.range, with: "<BON:\(replacement.string)/>")
        }
        replacements = []

        let unassignedPrefix = "\\N{<unassigned-"
        let unassignedPrefixReplacement = "<BON:unicode value='"
        let unassignedSuffix = ">}"
        let unassignedSuffixReplacement = "'/>"

        var currentIndex: Int = 0
        for character in debug.string {
            let utf16LengthOfCharacter = String(character).utf16.count
            let original = String(character) as NSString
            let transformed = original.applyingTransform(StringTransform.toUnicodeName, reverse: false)
            if let transformed = transformed {
                if transformed.hasPrefix(unassignedPrefix) && transformed.hasSuffix(unassignedSuffix) {
                    let range = NSRange(location: currentIndex, length: utf16LengthOfCharacter)
                    var newString = transformed.replacingOccurrences(of: unassignedPrefix, with: unassignedPrefixReplacement)
                    newString = newString.replacingOccurrences(of: unassignedSuffix, with: unassignedSuffixReplacement)
                    replacements.append((range, newString))
                }
            }
            currentIndex += utf16LengthOfCharacter
        }

        for replacement in replacements.reversed() {
            debug.replaceCharacters(in: replacement.range, with: replacement.string)
        }

        return debug
    }

    public var bonMotDebugString: String {
        return bonMotDebugAttributedString.string
    }

}
