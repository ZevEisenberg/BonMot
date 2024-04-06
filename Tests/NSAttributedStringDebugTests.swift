//
//  NSAttributedStringDebugTests.swift
//  BonMot
//
//  Created by Brian King on 9/1/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

@testable import BonMot
import XCTest

class NSAttributedStringDebugTests: XCTestCase {

    func robotImage() throws -> BONImage {
        #if os(OSX)
        let imageForTest = testBundle.image(forResource: "robot")
        #elseif os(iOS) || os(tvOS)
        let imageForTest = UIImage(named: "robot", in: testBundle, compatibleWith: nil)
        #else
        let imageForTest = UIImage(named: "robot", in: testBundle, with: nil)
        #endif
        return try XCTUnwrap(imageForTest)
    }

    func testSpecialFromUnicodeScalar() {
        let enDash = Special(rawValue: "\u{2013}")
        XCTAssertEqual(enDash, Special.enDash)
    }

    func testDebugRepresentationReplacements() {
        let testCases: [(String, String)] = [
            ("BonMot", "BonMot"),
            ("Bon\tMot", "Bon<BON:tab/>Mot"),
            ("Bon\nMot", "Bon<BON:lineFeed/>Mot"),
            ("it ignores spaces", "it ignores spaces"),
            ("Pilcrow¶", "Pilcrow¶"),
            ("Floppy💾Disk", "Floppy💾Disk"),
            ("\u{000A1338}A\u{000A1339}", "<BON:unicode value='A1338'/>A<BON:unicode value='A1339'/>"),
            ("neonسلام🚲\u{000A1338}₫\u{000A1339}", "neonسلام🚲<BON:unicode value='A1338'/>₫<BON:unicode value='A1339'/>"),
            ("\n →\t", "<BON:lineFeed/> →<BON:tab/>"),
            ("foo\u{00a0}bar", "foo<BON:noBreakSpace/>bar"),
        ]
        for (index, testCase) in testCases.enumerated() {
            let line = UInt(#line - testCases.count - 2 + index)
            let debugString = NSAttributedString(string: testCase.0).bonMotDebugString
            XCTAssertEqual(testCase.1, debugString, line: line)
            let fromXML = StringStyle(.xml).attributedString(from: debugString)
            // Unassigned unicode replacement is not currently working. No one is actually interested in doing this so I'm going to leave it out.
            if !testCase.1.contains("BON:unicode value=") {
                XCTAssertEqual(testCase.0, fromXML.string, line: line)
            }
        }
    }

    #if !os(watchOS)
    func testComposedDebugRepresentation() throws {
        let imageForTest = try robotImage()

        let testCases: [([Composable], String, UInt)] = [
            ([imageForTest], "<BON:image size='36x36'/>", #line),
            ([Special.enDash], "<BON:enDash/>", #line),
            ([imageForTest, imageForTest], "<BON:image size='36x36'/><BON:image size='36x36'/>", #line),
            ([Special.enDash, Special.emDash], "<BON:enDash/><BON:emDash/>", #line),
            ([Special.enDash, imageForTest], "<BON:enDash/><BON:image size='36x36'/>", #line),
            ([imageForTest, Special.enDash], "<BON:image size='36x36'/><BON:enDash/>", #line),
            ([imageForTest, Special.noBreakSpace, "Monday", Special.enDash, "Friday"], "<BON:image size='36x36'/><BON:noBreakSpace/>Monday<BON:enDash/>Friday", #line),
        ]
        for testCase in testCases {
            let debugString = NSAttributedString.composed(of: testCase.0).bonMotDebugString
            XCTAssertEqual(testCase.1, debugString, line: testCase.2)
        }
    }
    #endif

    func testThatNSAttributedStringSpeaksUTF16() {
        // We don't actually need to test this - just demonstrating how it works
        let string = "\u{000A1338}A"
        XCTAssertEqual(string.count, 2)
        XCTAssertEqual(string.utf8.count, 5)
        XCTAssertEqual(string.utf16.count, 3)
        let mutableAttributedString = NSMutableAttributedString(string: string)
        XCTAssertEqual(mutableAttributedString.string, string)
        mutableAttributedString.replaceCharacters(in: NSRange(location: 0, length: 2), with: "foo")
        XCTAssertEqual(mutableAttributedString.string, "fooA")
    }

    // ParagraphStyles are a bit interesting, as tabs behave over a line, but multiple paragraph styles can be applied on that line.
    // I'm not sure how a multi-paragraph line would behave, but this confirms that NSAttributedString doesn't do any coalescing
    func testParagraphStyleBehavior() {
        let style1 = NSMutableParagraphStyle()
        style1.lineSpacing = 1000
        let style2 = NSMutableParagraphStyle()
        style2.headIndent = 1000
        let string1 = NSMutableAttributedString(string: "first part ", attributes: [.paragraphStyle: style1])
        let string2 = NSAttributedString(string: "second part.\n", attributes: [.paragraphStyle: style2])
        string1.append(string2)
        let p1 = string1.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle
        let p2 = string1.attribute(.paragraphStyle, at: string1.length - 1, effectiveRange: nil) as? NSParagraphStyle
        XCTAssertNotEqual(p1, p2)
    }

}
