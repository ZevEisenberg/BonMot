//
//  XMLTagStyleBuilderTests.swift
//  BonMot
//
//  Created by Brian King on 8/29/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

import BonMot
import XCTest

class XMLTagStyleBuilderTests: XCTestCase {

    /// There have been concerns about XMLParser's performance. This is a
    /// baseline test, but doesn't mean much without a comparison.
    func testBasicParserPerformance() {
        let styles = NamedStyles(styles: ["A": styleA, "B": styleB])

        var hugeString = ""
        for _ in 0..<100 {
            hugeString.append("This is <A>A style</A> test for <B>B Style</B>.")
        }
        // For some reason, the `AllTheThings` target fails when things are measured. Since this measurement is not of much
        // value, it's disabled until we have enough value in the measurement to fix the build bug.
//        measure() {
            XCTAssertNotNil(try? NSAttributedString.composed(ofXML: hugeString, rules: [.styles(styles)]))
//        }
    }

    /// Test that the ranges of the composed attributed string match what is expected
    func testComposition() {
        let styles = NamedStyles(styles: ["A": styleA, "B": styleB])

        guard let attributedString = try? NSAttributedString.composed(ofXML: "This is <A>A style</A> test for <B>B Style</B>.", rules: [.styles(styles)]) else {
            XCTFail("No attributed string")
            return
        }
        XCTAssertEqual("This is A style test for B Style.", attributedString.string)
        let fonts: [String: BONFont] = attributedString.rangesFor(attribute: NSAttributedString.Key.font.rawValue)
        BONAssertEqualFonts(BONFont(name: "Avenir-Roman", size: 30)!, fonts["8:7"]!)
        BONAssertEqualFonts(BONFont(name: "Avenir-Roman", size: 20)!, fonts["25:7"]!)
        XCTAssertEqual(fonts.count, 2)
    }

    func testUnicodeInXML() {
        do {
            let attributedString = try NSAttributedString.composed(ofXML: "caf&#233;")
            XCTAssertEqual(attributedString.string, "café")
        }
        catch {
            XCTFail("Failed to create attributed string: \(error)")
        }
    }

    func testCompositionByStyle() {
        let styles = NamedStyles(styles: ["A": styleA, "B": styleB])
        let style = StringStyle(.xmlRules([.styles(styles)]))
        let attributedString = style.attributedString(from: "This is <A>A style</A> test for <B>B Style</B>.")
        XCTAssertEqual("This is A style test for B Style.", attributedString.string)
        let fonts: [String: BONFont] = attributedString.rangesFor(attribute: NSAttributedString.Key.font.rawValue)
        BONAssertEqualFonts(BONFont(name: "Avenir-Roman", size: 30)!, fonts["8:7"]!)
        BONAssertEqualFonts(BONFont(name: "Avenir-Roman", size: 20)!, fonts["25:7"]!)
        XCTAssertEqual(fonts.count, 2)
    }

    /// Verify the behavior when a style is not registered
    func testMissingTags() {
        let styles = NamedStyles()
        styles.registerStyle(forName: "A", style: styleA)

        XCTAssertNotNil(try? NSAttributedString.composed(ofXML: "This <B>style</B> is not registered and that's OK", rules: [.styles(styles)]))
    }

    func testMissingTagsByStyle() {
        let styles = NamedStyles()
        let style = StringStyle(.xmlRules([.styles(styles)]))
        let attributedString = style.attributedString(from: "This <B>style</B> is not registered and that's OK")
        XCTAssertEqual("This style is not registered and that's OK", attributedString.string)
        let fonts: [String: BONFont] = attributedString.rangesFor(attribute: NSAttributedString.Key.font.rawValue)
        XCTAssertEqual(fonts.count, 0)
    }

    func testInvalidXMLByStyle() {
        let styles = NamedStyles()
        let style = StringStyle(.xmlRules([.styles(styles)]))
        let attributedString = style.attributedString(from: "This <B>style has no closing tag and that is :(")
        XCTAssertEqual("This <B>style has no closing tag and that is :(", attributedString.string)
        let fonts: [String: BONFont] = attributedString.rangesFor(attribute: NSAttributedString.Key.font.rawValue)
        XCTAssertEqual(fonts.count, 0)
    }

    /// Verify that the string is read when fully contained
    func testFullXML() {
        let styles = NamedStyles()
        XCTAssertNotNil(try? NSAttributedString.composed(ofXML: "<Top>This is fully contained</Top>", rules: [.styles(styles)], options: [.doNotWrapXML]))
    }

    /// Basic test of some HTML-like behavior.
    func testHTMLish() {
        struct HTMLishStyleBuilder: XMLStyler {
            let namedStyles = [
                "a": styleA,
                "p": styleA,
                "p:foo": styleB,
            ]

            func style(forElement name: String, attributes: [String: String], currentStyle: StringStyle) -> StringStyle? {
                var namedStyle = namedStyles[name] ?? StringStyle()
                if let htmlClass = attributes["class"] {
                    namedStyle = namedStyles["\(name):\(htmlClass)"] ?? namedStyle
                }
                if name.lowercased() == "a" {
                    if let href = attributes["href"], let url = URL(string: href) {
                        namedStyle.link = url
                    }
                    else {
                        print("Ignoring invalid <a \(attributes)>")
                    }
                }
                return namedStyle
            }
            func prefix(forElement name: String, attributes: [String: String]) -> Composable? { return nil }
            func suffix(forElement name: String) -> Composable? { return nil }
        }

        let styler = HTMLishStyleBuilder()
        guard let attributedString = try? NSAttributedString.composed(ofXML: "This <a href='http://rightpoint.com/'>Link</a>, <p>paragraph</p>, <p class='foo'>class</p> looks like HTML.", styler: styler) else {
            XCTFail("No attributed string")
            return
        }
        let expectedFonts = [
            "5:4": styleA.font!,
            "11:9": styleA.font!,
            "22:5": styleB.font!,
        ]
        let actualFonts: [String: BONFont] = attributedString.rangesFor(attribute: NSAttributedString.Key.font.rawValue)
        XCTAssertEqual(expectedFonts, actualFonts)
        XCTAssertEqual(["5:4": URL(string: "http://rightpoint.com/")!], attributedString.rangesFor(attribute: NSAttributedString.Key.link.rawValue))
    }

    /// Ensure that the singleton is configured with some adaptive styles for easy Dynamic Type support.
    #if os(iOS) || os(tvOS)
    func testDefaultNamedStyles() {
        XCTAssertNotNil(NamedStyles.shared.style(forName: "body"))
        XCTAssertNotNil(NamedStyles.shared.style(forName: "control"))
        XCTAssertNotNil(NamedStyles.shared.style(forName: "preferred"))
    }
    #endif

    /// Test the line and column information returned in the error. Note that this is just testing our adapting of the column for the root node insertion.
    func testErrorLocation() {
        struct ParseErrorResult: Equatable {
            let originalXML: String
            let errorCode: XMLParser.ErrorCode?
            let line: Int?
            let column: Int?
        }

        func errorResult(forXML xml: String, options: XMLParsingOptions = []) -> ParseErrorResult? {
            do {
                let attributedString = try NSAttributedString.composed(ofXML: xml, options: options)
                XCTFail("compose should of thrown, got \(attributedString)")
            }
            catch let error as XMLBuilderError {
                return ParseErrorResult(
                    originalXML: error.originalXML,
                    errorCode: error.errorCode,
                    line: error.line,
                    column: error.column
                )
            }
            catch {
                XCTFail("Did not get an XMLError")
            }
            return nil
        }

        // n.b. when debugging this, the error code will give an unhelpful generic name in failure messages and when using `po` in the debugger. Use `p` in the debugger for a human-readable name.

        // n.b. failure messages here are pretty hard to interpret. Consider adding https://github.com/pointfreeco/swift-custom-dump and using XCTAssertNoDifference when debugging. I opted not to commit that because I did not want to introduce a dependency.

        XCTAssertEqual(
            errorResult(forXML: "Text <a "),
            ParseErrorResult(
                originalXML: "<BonMotTopLevelContainer>Text <a </BonMotTopLevelContainer>",
                errorCode: .nameRequiredError,
                line: 1,
                column: 34
            )
        )

        XCTAssertEqual(
            errorResult(forXML: "Text \r\n <a "),
            ParseErrorResult(
                originalXML: "<BonMotTopLevelContainer>Text \r\n <a </BonMotTopLevelContainer>",
                errorCode: .nameRequiredError,
                line: 2,
                column: 5
            )
        )

        XCTAssertEqual(
            errorResult(forXML: "<ex> <a ", options: .doNotWrapXML),
            ParseErrorResult(
                originalXML: "<ex> <a ",
                errorCode: .gtRequiredError,
                line: 1,
                column: 9
            )
        )

        XCTAssertEqual(
            errorResult(forXML: "<ex> \r\n <a ", options: .doNotWrapXML),
            ParseErrorResult(
                originalXML: "<ex> \r\n <a ",
                errorCode: .gtRequiredError,
                line: 2,
                column: 5
            )
        )
    }

    func testBONXML() {
        for value in Special.allCases {
            let xmlString = "this<BON:\(value.name)/>should embed a special character"
            let xmlAttributedString = try? NSAttributedString.composed(ofXML: xmlString)
            XCTAssertEqual(xmlAttributedString?.string, "this\(value)should embed a special character")
        }
    }

}
