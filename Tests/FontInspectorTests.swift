//
//  FontInspectorTests.swift
//  BonMot
//
//  Created by Zev Eisenberg on 11/2/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

@testable import BonMot
import XCTest

#if !os(watchOS)
class FontInspectorTests: XCTestCase {

    let systemFont = BONFont.systemFont(ofSize: 24)
    let garamond: BONFont = {
        EBGaramondLoader.loadFontIfNeeded()
        return BONFont(name: "EBGaramond12-Regular", size: 24)!
    }()

    override func setUp() {
        super.setUp()
        EBGaramondLoader.loadFontIfNeeded()
    }

    func testHasFeature() throws {
        XCTAssertTrue(garamond.has(feature: NumberCase.lower))
        try XCTSkipIf(true, "systemFont testing is not consistent")
        XCTAssertTrue(systemFont.has(feature: SmallCaps.fromLowercase))
        XCTAssertTrue(systemFont.has(feature: SmallCaps.disabled))
        XCTAssertFalse(systemFont.has(feature: NumberCase.lower))
    }

    /// This test is disabled on macOS because, although it works locally,
    /// the font reports _slightly_ different feature availability on the build
    /// machine. Perhaps it is installed on the build machine? Possible fix: use
    /// CTFontManagerCreateFontDescriptorFromData() to ensure that the copy of
    /// EBGaramond12 that is used in the test is definitely the one included in
    /// the test bundle.
    func testAvailableFeatures() throws {
        try XCTSkipIf(true, "This control string is no longer accurate.")
        let garamondControlString = [
            "Available font features of EBGaramond12-Regular",
            "",
            "All Typographic Features",
            "    Exclusive: false",
            "    Selectors:",
            "    * On (default)",
            "",
            "Ligatures",
            "    Exclusive: false",
            "    Selectors:",
            "    * Common Ligatures (default)",
            "    * Rare Ligatures",
            "    * Historical Ligatures",
            "",
            "Number Spacing",
            "    Exclusive: true",
            "    Selectors:",
            "    * Monospaced Numbers",
            "    * Proportional Numbers",
            "    * No Change (default)",
            "",
            "Vertical Position",
            "    Exclusive: true",
            "    Selectors:",
            "    * Normal Vertical Position (default)",
            "    * Superiors/Superscripts",
            "    * Inferiors/Subscripts",
            "    * Ordinals",
            "    * Scientific Inferiors",
            "",
            "Contextual Fractional Forms",
            "    Exclusive: true",
            "    Selectors:",
            "    * No Fractional Forms (default)",
            "    * Diagonal",
            "",
            "Number Case",
            "    Exclusive: true",
            "    Selectors:",
            "    * Old-Style Figures",
            "    * Lining Figures",
            "    * No Change (default)",
            "",
            "Text Spacing",
            "    Exclusive: true",
            "    Selectors:",
            "    * No Change (default)",
            "    * No Kerning",
            "",
            "Case-Sensitive Layout",
            "    Exclusive: false",
            "    Selectors:",
            "    * Capital Forms",
            "",
            "Alternative Stylistic Sets",
            "    Exclusive: false",
            "    Selectors:",
            "    * Cyrillic alternate de, el and elj",
            "    * Stylistic Set 2",
            "    * Stylistic Set 5",
            "    * Stylistic Set 6",
            "    * Stylistic Set 7",
            "    * Stylistic Set 20",
            "",
            "Contextual Alternates",
            "    Exclusive: false",
            "    Selectors:",
            "    * Contextual Alternates (default)",
            "",
            "Lower Case",
            "    Exclusive: true",
            "    Selectors:",
            "    * No Change (default)",
            "    * Small Capitals",
            "",
            "Upper Case",
            "    Exclusive: true",
            "    Selectors:",
            "    * No Change (default)",
            "    * Small Capitals",
            ].joined(separator: "\n")
        XCTAssertEqual(garamond.availableFontFeatures(includeIdentifiers: false), garamondControlString)
    }
}
#endif
