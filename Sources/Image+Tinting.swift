//
//  Image+Tinting.swift
//  BonMot
//
//  Created by Zev Eisenberg on 9/28/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

#if !os(watchOS)

import Foundation

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public extension BONImage {

    #if canImport(AppKit)
    /// Returns a copy of the receiver where the alpha channel is maintained,
    /// but every pixel's color is replaced with `color`.
    ///
    /// - note: The returned image does _not_ have the template flag set,
    ///         preventing further tinting.
    ///
    /// - Parameter theColor: The color to use to tint the receiver.
    /// - Returns: A tinted copy of the image.
    @objc(bon_tintedImageWithColor:)
    func tintedImage(color: BONColor) -> BONImage {
        let image = NSImage(size: size, flipped: false) { rect in
            color.set()
            rect.fill()
            self.draw(
                in: rect,
                from: NSRect(origin: .zero, size: self.size),
                operation: .destinationIn,
                fraction: 1
            )
            return true
        }

        // Prevent further tinting
        image.isTemplate = false

        // Transfer accessibility description
        image.accessibilityDescription = self.accessibilityDescription

        return image
    }
    #elseif canImport(UIKit)
    /// Returns a copy of the receiver where the alpha channel is maintained,
    /// but every pixel's color is replaced with `color`.
    ///
    /// - note: The returned image does _not_ have the template flag set,
    ///         preventing further tinting.
    ///
    /// - Parameter theColor: The color to use to tint the receiver.
    /// - Returns: A tinted copy of the image.
    @objc(bon_tintedImageWithColor:)
    func tintedImage(color: BONColor) -> BONImage {
        let imageRect = CGRect(origin: .zero, size: size)
        // Save original properties
        let originalCapInsets = capInsets
        let originalResizingMode = resizingMode
        let originalAlignmentRectInsets = alignmentRectInsets

        let format = UIGraphicsImageRendererFormat(for: UITraitCollection(displayScale: scale))

        var image = UIGraphicsImageRenderer(size: size, format: format).image { rendererContext in
            color.setFill()
            UIRectFill(imageRect)
            self.draw(at: .zero, blendMode: .destinationIn, alpha: 1)
        }

        // Prevent further tinting
        image = image.withRenderingMode(.alwaysOriginal)

        // Restore original properties
        image = image.withAlignmentRectInsets(originalAlignmentRectInsets)
        if originalCapInsets != image.capInsets || originalResizingMode != image.resizingMode {
            image = image.resizableImage(withCapInsets: originalCapInsets, resizingMode: originalResizingMode)
        }

        // Transfer accessibility label (watchOS not included; does not have accessibilityLabel on UIImage).
        #if os(iOS) || os(tvOS)
            image.accessibilityLabel = self.accessibilityLabel
        #endif

        return image
    }
    #endif

}
#endif
