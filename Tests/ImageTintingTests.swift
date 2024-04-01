//
//  ImageTintingTests.swift
//  BonMot
//
//  Created by Zev Eisenberg on 9/28/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

import SnapshotTesting
import XCTest

@testable import BonMot

#if !os(watchOS)
class ImageTintingTests: XCTestCase {

    override func setUp() async throws {
//        isRecording = true; #warning("Don't commit me!")
    }

    func logoImage() throws -> BONImage {
        #if canImport(AppKit)
        let imageForTest = testBundle.image(forResource: "rz-logo-black")
        #elseif canImport(UIKit)
        let imageForTest = UIImage(named: "rz-logo-black", in: testBundle, compatibleWith: nil)
        #endif
        return try XCTUnwrap(imageForTest)
    }

    var raizlabsRed: BONColor {
        #if canImport(AppKit)
        NSColor(deviceRed: 0.92549, green: 0.352941, blue: 0.301961, alpha: 1.0)
        #elseif canImport(UIKit)
        UIColor(red: 0.92549, green: 0.352941, blue: 0.301961, alpha: 1.0)
        #endif
    }

    let accessibilityDescription = "I’m the very model of a modern accessible image."

    func testImageTinting() throws {
        let blackImageName = "rz-logo-black"
        let testNameSuffix: String

        #if canImport(AppKit)
            let sourceImage = try XCTUnwrap(Bundle.module.image(forResource: blackImageName))
            let testTintedImage = sourceImage.tintedImage(color: raizlabsRed)
            testNameSuffix = "AppKit"
        #elseif canImport(UIKit)
            let sourceImage = try XCTUnwrap(UIImage(named: blackImageName, in: testBundle, compatibleWith: nil))
            let testTintedImage = sourceImage.tintedImage(color: raizlabsRed)
            testNameSuffix = "UIKit"
        #endif

        assertSnapshot(of: try testTintedImage.snapshotForTesting(), as: .image, testName: #function + "_" + testNameSuffix)
    }

    func testTintingInAttributedString() throws {
        let imageForTest = try logoImage()

        let testNameSuffix: String

        #if canImport(AppKit)
            let tintableImage = imageForTest
            tintableImage.isTemplate = true
            testNameSuffix = "AppKit"
        #elseif canImport(UIKit)
            let tintableImage = imageForTest.withRenderingMode(.alwaysTemplate)
            testNameSuffix = "UIKit"
        #endif

        let tintedString = NSAttributedString.composed(of: [
            tintableImage.styled(with: .color(raizlabsRed)),
            ])

        let tintResult = try tintedString.snapshotForTesting()

        assertSnapshot(of: try tintResult.snapshotForTesting(), as: .image, testName: #function + "_" + testNameSuffix)
    }

    func testNotTintingInAttributedString() throws {
        var imageForTest = try logoImage()

        let testNameSuffix: String

        #if canImport(AppKit)
        imageForTest.isTemplate = false
            testNameSuffix = "AppKit"
        #elseif canImport(UIKit)
        imageForTest = imageForTest.withRenderingMode(.alwaysOriginal)
            testNameSuffix = "UIKit"
        #endif


        let tintString = NSAttributedString.composed(of: [
            imageForTest.styled(with: .color(raizlabsRed)),
            ])

        let tintResult = try tintString.snapshotForTesting()

        assertSnapshot(of: try tintResult.snapshotForTesting(), as: .image, testName: #function + "_" + testNameSuffix)
    }

    func testAccessibilityIOSAndTVOS() throws {
        let imageForTest = try logoImage()

        #if os(iOS) || os(tvOS)
            imageForTest.accessibilityLabel = accessibilityDescription
            let tintedImage = imageForTest.tintedImage(color: raizlabsRed)
            XCTAssertEqual(tintedImage.accessibilityLabel, accessibilityDescription)
            XCTAssertEqual(tintedImage.accessibilityLabel, tintedImage.accessibilityLabel)
        #endif
    }

    #if canImport(AppKit)
    func testAccessibilityMacOS() throws {
        let imageForTest = try logoImage()

            imageForTest.accessibilityDescription = accessibilityDescription
            let tintedImage = imageForTest.tintedImage(color: raizlabsRed)
            XCTAssertEqual(tintedImage.accessibilityDescription, accessibilityDescription)
            XCTAssertEqual(tintedImage.accessibilityDescription, tintedImage.accessibilityDescription)
    }
    #endif
}
#endif

extension BONImage {
    func snapshotForTesting() throws -> BONImage {
#if canImport(AppKit)
        let renderedCGImage = try XCTUnwrap(
            self.cgImage(
                forProposedRect: nil,
                context: nil,
                hints: [
                    // The image will use the DPI of the display of the machine it is running on. That's 144dpi for Retina, 72dpi for non-Retina, and it could potentially be other values as well. Force to 72dpi non-Retina for testing.
                    .init(rawValue: NSDeviceDescriptionKey.resolution.rawValue): CGSize(width: 72, height: 72),
                ]
            )
        )
        return NSImage(cgImage: renderedCGImage, size: size)
#else
        return self
#endif
    }
}
