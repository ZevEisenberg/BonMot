//
//  DemoStrings.swift
//  BonMot
//
//  Created by Brian King on 8/26/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

import BonMot
import UIKit

typealias StringStyle = BonMot.StringStyle

enum DemoStrings {

    // A Simple Example
    static let simpleExample = "MY PRECIOUS"
        .styled(
            with:
            .tracking(.point(6)),
            .font(UIFont(name: "AvenirNextCondensed-Bold", size: 16)!),
            .alignment(.center),
            .color(BONColor(hex: 0x2769dd)),
            .adapt(.control)
    )

    /// Style a string, with both global and range-based overrides, from an XML
    /// source. This is the most common use case for styling substrings of
    /// localized strings, where searching for and replacing substrings on a
    /// per-language basis is cumbersome.
    static let xmlExample: NSAttributedString = {

        // This would typically come from NSLocalizedString
        let localizedString = """
            I want to be different. If everyone is wearing <black><BON:noBreakSpace/>black,<BON:noBreakSpace/></black> I want to be wearing <red><BON:noBreakSpace/>red.<BON:noBreakSpace/></red>
            <signed><BON:emDash/>Maria Sharapova</signed> <racket/>
            """

        // Define a colored image that's slightly shifted to account for the line height
        let accessibleRacketImage = UIImage(named: "Tennis Racket")!
        // The racket is purely for decoration, so make the accessibility system ignore it
        accessibleRacketImage.accessibilityLabel = ""
        let racket = accessibleRacketImage.styled(with:
            .color(.raizlabsRed), .baselineOffset(-4.0))

        // Define styles
        let accent = StringStyle(.font(BONFont(name: "SuperClarendon-Black", size: 18)!))
        let black = accent.byAdding(.color(.white), .backgroundColor(.black))
        let red = accent.byAdding(.color(.white), .backgroundColor(.raizlabsRed))
        let signed = accent.byAdding(.color(.raizlabsRed))

        // Define the base style with xml rules for all tags
        let baseStyle = StringStyle(
            .font(BONFont(name: "GillSans-Light", size: 18)!),
            .lineHeightMultiple(1.8),
            .color(.darkGray),
            .adapt(.control),
            .xmlRules([
                .style("black", black),
                .style("red", red),
                .style("signed", signed),
                .enter(element: "racket", insert: racket),
                ]
            )
        )
        return localizedString.styled(with: baseStyle)
    }()

    static let xmlWithEmphasis: NSAttributedString = {
        let string = "You can parse HTML with <strong>strong</strong>, <em>em</em>, and even <strong><em>nested strong and em</em></strong> tags."
        let emphasis = StringStyle(.emphasis(.italic), .color(.raizlabsRed))
        let strong = StringStyle(.emphasis(.bold), .color(.raizlabsRed))
        let style = StringStyle(
            .font(.systemFont(ofSize: 17)),
            .color(.black),
            .xmlRules([
                .style("em", emphasis),
                .style("strong", strong),
                ])
        )
        let ret = string.styled(with: style)
        return ret
    }()

    /// Compose a string piecewise from different components. If you are using
    /// localized strings, you may not want to use this approach, since it does
    /// not work well in cases where different languages have different
    /// sentence structure. Instead, use XML as in the previous example. Use
    /// composition only if you absolutely need to build the string from pieces.
    static let compositionExample: NSAttributedString = {
        // Define a colored image that's slightly shifted to account for the line height
        let accessibleBoatImage = UIImage(named: "boat")!
        accessibleBoatImage.accessibilityLabel = "boat"
        let boat = accessibleBoatImage.styled(with:
            .color(.raizlabsRed))

        let baseStyle = StringStyle(
            .alignment(.center),
            .color(.black)
        )

        let preamble = baseStyle.byAdding(
            .font(BONFont(name: "AvenirNext-Bold", size: 14)!),
            .adapt(.body)
        )

        let bigger = baseStyle.byAdding(
            .font(BONFont(name: "AvenirNext-Heavy", size: 64)!),
            .adapt(.control)
        )

        return NSAttributedString.composed(of: [
            "You’re going to need a\n".styled(with: preamble),
            "Bigger\n".localizedUppercase.styled(with: bigger),
            boat,
            ], baseStyle: baseStyle)
    }()

    static let imagesExample: NSAttributedString = {

        func accessibleImage(named name: String) -> UIImage {
            let image = UIImage(named: name)!
            image.accessibilityLabel = name
            return image
        }

        let bee = accessibleImage(named: "bee")
        let oar = accessibleImage(named: "oar")
        let knot = accessibleImage(named: "knot")

        return NSAttributedString.composed(of: [
            "2".styled(with: .baselineOffset(8)),
            bee,
            oar,
            knot,
            "2".styled(with: .baselineOffset(8)),
            bee,
        ], baseStyle: StringStyle(
            .font(UIFont(name: "HelveticaNeue-Bold", size: 24)!),
            .adapt(.control)
        ))
    }()

    static let noBreakSpaceExample: NSAttributedString = {
        let noSpaceTextStyle = StringStyle(
            .font(.systemFont(ofSize: 17)),
            .adapt(.control),
            .color(.darkGray),
            .baselineOffset(10)
        )

        return NSAttributedString.composed(
            of: [
                ("barn", "This"),
                ("bee", "string"),
                ("bug", "is"),
                ("circuit", "separated"),
                ("cut", "by"),
                ("discount", "images"),
                ("gift", "and"),
                ("pin", "no-break"),
                ("robot", "spaces"),
                ].map {
                    NSAttributedString.composed(of: [
                        UIImage(named: $0)!,
                        Special.noBreakSpace,
                        $1.styled(with: noSpaceTextStyle),
                        ])
        }, separator: " ")
    }()

    /// A whimsical example using baseline offset and some math.
    static let heartsExample = NSAttributedString.composed(of: (0..<20).map { i in
        let offset: CGFloat = 15 * sin((CGFloat(i) / 20.0) * 7.0 * CGFloat.pi)
        return "❤️".styled(with: .baselineOffset(offset))
        })

    static let indentationExamples: [NSAttributedString] = {

        /// Using an image as a bullet.
        let imageIndentation = NSAttributedString.composed(
            of: [
                UIImage(named: "robot")!,
                Tab.headIndent(4.0),
                "“It’s OK to ask for help. When doing a final exam, all the work must be yours, but in engineering, the point is to get the job done, and people are happy to help. Corollaries: You should be generous with credit, and you should be happy to help others.”",
                Special.lineSeparator,
                Special.emDash,
                "Radia Perlman",
            ],
            baseStyle: StringStyle(
                .font(UIFont(name: "AvenirNextCondensed-Medium", size: 18.0)!),
                .adapt(.control)
            ))

        /// Using text as a bullet.
        let stringIndentation = NSAttributedString.composed(
            of: [
                "🍑 →",
                Tab.headIndent(4.0),
                "You can also use strings (including emoji) for bullets, and they will still properly indent the appended text by the right amount.",
            ],
            baseStyle: StringStyle(
                .font(UIFont(name: "AvenirNextCondensed-Medium", size: 18.0)!),
                .color(.darkGray),
                .adapt(.control)
            ))

        /// Parse a bulleted list out of HTML which uses <li> tags. Note the use
        /// of `enter` and `exit` style rules to insert bullet characters. and
        /// line breaks. As a bonus, <code> tags are formatted using a different
        /// font and background color.
        let xmlIndentation: NSAttributedString = {
            let listItemStyle = StringStyle(
                .font(UIFont(name: "AvenirNextCondensed-Medium", size: 18.0)!),
                .adapt(.control),
                .paragraphSpacingAfter(10.0)
            )

            let codeStyle = StringStyle(
                .font(UIFont(name: "Menlo-Regular", size: 16.0)!),
                .backgroundColor(BONColor.blue.withAlphaComponent(0.1)),
                .adapt(.control)
            )

            let bulletString = NSAttributedString.composed(of: ["🍑 →", Tab.headIndent(4.0)])
            let rules: [XMLStyleRule] = [
                .style("li", listItemStyle),
                .style("code", codeStyle),
                .enter(element: "li", insert: bulletString),
                .exit(element: "li", insert: "\n"),
            ]

            let xml = "<li>This list is defined with XML and displayed in a single <code>UILabel</code>.</li><li>Each row is represented with an <code>&lt;li&gt;</code> tag.</li><li>Attributed strings define the string to use for bullets.</li><li>The text style is also specified for the <code>&lt;li&gt;</code> and <code>&lt;code&gt;</code> tags.</li>"

            // Use this method of parsing XML if the content is not under your
            // control, since you are less likely to catch edge cases while
            // developing. This way, you can handle parsing errors gracefully.
            guard let string = try? NSAttributedString.composed(ofXML: xml, rules: rules) else {
                fatalError("Unable to load XML \(xml)")
            }
            return string
        }()

        return [
            imageIndentation,
            stringIndentation,
            xmlIndentation,
        ]
    }()

    /// This example uses XML to combine many features, including special
    /// characters and line spacing, and it uses single-character kerning to
    /// move the period at the end of the sentence closer to the preceding
    /// character.
    static let advancedXMLAndKerningExample: NSAttributedString = {

        let fullStyle = StringStyle(
            .alignment(.center),
            .color(.raizlabsRed),
            .font(BONFont(name: "AvenirNext-Medium", size: 16)!),
            .adapt(.body),
            .lineSpacing(20),
            .xmlRules([
                .style("large", StringStyle(
                    .font(BONFont(name: "AvenirNext-Heavy", size: 64)!),
                    .lineSpacing(40),
                    .adapt(.control))),
                .style("kern", StringStyle(
                    .tracking(.adobe(-80))
                    )),
                ])
        )

        // XML makes it hard to read. It says: "GO AHEAD, MAKE MY DAY."
        let phrase = """
            GO<BON:noBreakSpace/>AHEAD,
            <large>MAKE
            MY
            DA<kern>Y.</kern></large>
            """

        let attributedString = phrase.styled(with: fullStyle)
        return attributedString
    }()

    /// Demonstrate specifying Dynamic Type sizing behavior and custom styles
    /// via IBDesignable in Interface Builder. To see this example in action,
    /// play with the iOS Text Size slider and see how the UI elements react.
    static let dynamicTypeUIKitExample = DemoStrings.customStoryboard(identifier: "CatalogViewController")
        .attributedString(from: "Dynamic UIKit elements with custom fonts")

    /// Demonstrate how BonMot interacts with system preferred text styles.
    static let preferredFontsExample = DemoStrings.customStoryboard(identifier: "PreferredFonts")
        .attributedString(from: "Preferred Fonts")

    // Demonstrate different number styles and spacings.
    static let figureStylesExample: NSAttributedString = {

        let garamondStyle = StringStyle(
            .font(UIFont(name: "EBGaramond12-Regular", size: 24)!),
            .lineHeightMultiple(1.2),
            .adapt(.body)
        )

        let digits = "\n0123456789"

        return NSAttributedString.composed(of: [
            "Number Styles".styled(with: garamondStyle, .smallCaps(.fromLowercase), .color(.raizlabsRed)),
            digits.styled(with: garamondStyle, .numberCase(.lower), .numberSpacing(.monospaced)),
            digits.styled(with: garamondStyle, .numberCase(.upper), .numberSpacing(.monospaced)),
            digits.styled(with: garamondStyle, .numberCase(.lower), .numberSpacing(.proportional)),
            digits.styled(with: garamondStyle, .numberCase(.upper), .numberSpacing(.proportional)),
        ])
    }()

    // Demonstrate ordinals.
    static let ordinalsExample: NSAttributedString = {

        let garamondStyle = StringStyle(
            .font(UIFont(name: "EBGaramond12-Regular", size: 24)!),
            .lineHeightMultiple(1.2),
            .adapt(.body)
        )

        let string = "Today is my <number>111<ordinal>th</ordinal></number> birthday!"
        return string.styled(with: garamondStyle.byAdding(
            .xmlRules([
                .style("number", garamondStyle.byAdding(.color(.raizlabsRed), .numberCase(.upper))),
                .style("ordinal", garamondStyle.byAdding(.ordinals(true))),
                ])
            )
        )
    }()

    // Demonstrate fractions.
    static let fractionsExample: NSAttributedString = {

        let garamondStyle = StringStyle(
            .font(UIFont(name: "EBGaramond12-Regular", size: 24)!),
            .numberCase(.upper),
            .lineHeightMultiple(1.2),
            .adapt(.body)
        )

        let string = "1336 <fraction>6/10</fraction> + <fraction>4/10</fraction> = 1337"
        return string.styled(with: garamondStyle.byAdding(
            .xmlRules([
                .style("fraction", garamondStyle.byAdding(.fractions(.diagonal), .color(.raizlabsRed), .numberCase(.lower))),
                ])
            )
        )
    }()

    // Demonstrate scientific inferiors.
    static let scientificInferiorsExample: NSAttributedString = {

        let garamondStyle = StringStyle(
            .font(UIFont(name: "EBGaramond12-Regular", size: 24)!),
            .lineHeightMultiple(1.2),
            .adapt(.body)
        )

        let string = "<name>Johnny</name> was a little boy, but <name>Johnny</name> is no more, for what he thought was <chemical>H<number>2</number>O</chemical> was really <chemical>H<number>2</number>SO<number>4</number></chemical>."
        return string.styled(with: garamondStyle.byAdding(
            .xmlRules([
                .style("name", garamondStyle.byAdding(.smallCaps(.fromLowercase))),
                .style("chemical", garamondStyle.byAdding(.color(.raizlabsRed))),
                .style("number", garamondStyle.byAdding(.scientificInferiors(true))),
                ])
            )
        )
    }()

    // Demonstrate stylistic alternates.
    static let stylisticAlternatesExample: NSAttributedString = {
        let systemFontStyle = StringStyle(
            .font(.systemFont(ofSize: 18)),
            .adapt(.body)
        )

        let password = "68Il14"
        let string = "My password, <callout>\(password)</callout>, is much easier to read with stylistic alternate set six enabled: <password>\(password)</password>."

        let callout = StringStyle(.color(.raizlabsRed))
        return string.styled(with: systemFontStyle, .xmlRules([
            .style("callout", callout),
            .style("password", callout.byAdding(.stylisticAlternates(.six(on: true)))),
            ])
        )
    }()

    // Demonstrate accessibility speech attributes.
    static let accessibilitySpeechExamples: [NSAttributedString] = {

        let style = StringStyle(
            .font(UIFont(name: "EBGaramond12-Regular", size: 24)!),
            .paragraphSpacingAfter(12.0),
            .adapt(.body),
            .xmlRules([
                .style("punctuation", StringStyle(.color(.raizlabsRed))),
                .style("emoji", StringStyle(.font(.systemFont(ofSize: 24)))),
                .style("speak-punctuation", StringStyle(.speaksPunctuation(true))),
                .style("high-pitch", StringStyle(.speakingPitch(2.0))),
                .style("low-pitch", StringStyle(.speakingPitch(0.0), .color(.raizlabsRed))),
                .style("el-GR", StringStyle(.speakingLanguage("el-GR"))),
                .style("en-US", StringStyle(.speakingLanguage("en-US"))),
                .style("es-DO", StringStyle(.speakingLanguage("es-DO"))),
                .style("fr-FR", StringStyle(.speakingLanguage("fr-FR"))),
                .style("pt-PT", StringStyle(.speakingLanguage("pt-PT"))),
                .style("ru-RU", StringStyle(.speakingLanguage("ru-RU"))),
                .style("uk-UA", StringStyle(.speakingLanguage("uk-UA"))),
                .style("zh-TW", StringStyle(.speakingLanguage("zh-TW"))),
                ]))

        let stringsArrays = [
            [
                "<speak-punctuation>With VoiceOver<punctuation>,</punctuation> this string<punctuation>,</punctuation> well<punctuation>,</punctuation> reads its<punctuation>…</punctuation>punctuation<punctuation>!</punctuation></speak-punctuation>",
                ],
            [
                "<high-pitch>Helium is less dense than air, making my voice higher. </high-pitch><low-pitch>And with sulfur hexafluoride, my voice gets really low, and somehow, I’m still funny. Ha ha ha.</low-pitch>",
                ],
            [
                "<el-GR><emoji>🇬🇷</emoji> Εδώ είναι ο σωστός τρόπος για να προφέρει Ελληνικά.</el-GR>",
                "<en-US>\n<emoji>🇺🇸</emoji> Here is the correct way to pronounce American English.</en-US>",
                "<es-DO>\n<emoji>🇩🇴</emoji> Aquí está la manera correcta de pronunciar el español.</es-DO>",
                "<fr-FR>\n<emoji>🇫🇷</emoji> Voici comment prononcer correctement le français.</fr-FR>",
                "<pt-PT>\n<emoji>🇵🇹</emoji> Aqui está a maneira correta de pronunciar português.</pt-PT>",
                "<ru-RU>\n<emoji>🇷🇺</emoji> Вот как правильно произносить русский.</ru-RU>",
                "<uk-UA>\n<emoji>🇺🇦</emoji> Ось як правильно вимовляти Український.</uk-UA>",
                "<zh-TW>\n<emoji>🇹🇼</emoji> 这里是正确的做法发音中文.</zh-TW>",
                ],
        ]

        return stringsArrays.map { $0.joined().styled(with: style) }
    }()

}

extension DemoStrings {

    /// Embed an attribute for the storyboard identifier to link to. This is
    /// a good example of embedding custom attributes in an attributed string,
    /// although it might not be the best UIKit design pattern.
    ///
    /// - Parameter theIdentifier: The identifier of the storyboard in question.
    /// - Returns: A string style that contains the extra storyboard attribute.
    static func customStoryboard(identifier theIdentifier: String) -> StringStyle {
        return StringStyle(.extraAttributes([NSAttributedString.Key("Storyboard"): theIdentifier]))
    }

}
