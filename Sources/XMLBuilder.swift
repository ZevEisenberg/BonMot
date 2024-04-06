//
//  NamedStyles+XML.swift
//  BonMot
//
//  Created by Brian King on 8/29/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

extension NSAttributedString {

    /// Generate an attributed string by parsing `fragment` using the `XMLStyler`
    /// protocol to provide style and string insertions to decorate the XML. As
    /// the XML fragment is traversed, the style of each node is provided by the
    /// `XMLStyler` protocol. This style and the current style are combined to
    /// decorate the content of the node, and the added style is removed when
    /// the node is exited. The `XMLStyler` protocol can also insert
    /// `NSAttributedString`s when entering and exiting nodes to support more
    /// customized styling.
    ///
    /// The `fragment` string will be wrapped in a top level element to ensure
    /// that it is valid XML, unless `XMLParsingOptions.doNotWrapXML` is
    /// specified as an option. If the XML is not valid, an error will be thrown.
    ///
    /// - Parameters:
    ///   - fragment: The string containing the markup.
    ///   - baseStyle: The base style to use where the XML does not otherwise
    ///                specify styling options.
    ///   - styler: An optional custom styler to perform extra style operations.
    ///   - options: XML parsing options.
    /// - Returns: A styled attriubuted string.
    /// - Throws: Any errors encountered by the XML parser.
    public static func composed(ofXML fragment: String, baseStyle: StringStyle? = nil, styler: XMLStyler? = nil, options: XMLParsingOptions = []) throws -> NSAttributedString {
        let builder = XMLBuilder(
            string: fragment,
            styler: styler ?? NSAttributedString.defaultXMLStyler,
            options: options,
            baseStyle: baseStyle ?? StringStyle()
        )
        let attributedString = try builder.parseAttributedString()
        return attributedString
    }

    /// Generate an attributed string by parsing `fragment` using the collection
    /// of `XMLStyleRule`s to provide style and string insertions to decorate
    /// the XML. As the XML fragment is traversed, the style of each node is
    /// provided by the `StyleRule`s. This style and the current style are
    /// combined to decorate the content of the node, and the added style is
    /// removed when the node is exited. The `XMLStyleRule` can also insert
    /// `NSAttributedString`s when entering and exiting nodes to support more
    /// customized styling.
    ///
    /// For more complex styling behavior, implement the `XMLStyler` protocol
    /// instead.
    ///
    /// The `fragment` string will be wrapped in a top level element to ensure
    /// that it is valid XML, unless `XMLParsingOptions.doNotWrapXML` is
    /// specified as an option. If the XML is not valid, an error will be thrown.
    ///
    /// - Parameters:
    ///   - fragment: The string containing the markup.
    ///   - baseStyle: The base style to use where the XML does not otherwise
    ///                specify styling options.
    ///   - rules: Styling rules to evaluate while parsing the XML.
    ///   - options: XML parsing options.
    /// - Returns: A styled attriubted string.
    /// - Throws: Any errors encountered by the XML parser.
    public static func composed(ofXML fragment: String, baseStyle: StringStyle? = nil, rules: [XMLStyleRule], options: XMLParsingOptions = []) throws -> NSAttributedString {
        let builder = XMLBuilder(
            string: fragment,
            styler: XMLStyleRule.Styler(rules: rules),
            options: options,
            baseStyle: baseStyle ?? StringStyle()
        )
        let attributedString = try builder.parseAttributedString()
        return attributedString
    }

    /// The default `XMLStyler` to use. By default, this styler will look up
    /// element styles in the shared `NamedStyles` and insert special characters
    /// when BON-namespaced elements are encountered.
    @nonobjc public static var defaultXMLStyler: XMLStyler = {
        var rules = Special.insertionRules
        rules.append(.styles(NamedStyles.shared))
        return XMLStyleRule.Styler(rules: rules)
    }()

}

extension Special {

    /// Rules describing how to insert values from `Special` into attributed strings.
    public static var insertionRules: [XMLStyleRule] {
        let rulePairs: [[XMLStyleRule]] = allCases.map {
            let elementName = "BON:\($0.name)"
            // Add the insertion rule and a style rule so we don't look up the style and generate a warning
            return [XMLStyleRule.enter(element: elementName, insert: $0), XMLStyleRule.style(elementName, StringStyle())]
        }
        return rulePairs.flatMap { $0 }
    }

}

/// A simple set of styling rules for styling XML. If your needs are more
/// complicated, use the `XMLStyler` protocol.
public enum XMLStyleRule {

    /// A collection of named styles.
    case styles(NamedStyles)

    /// A name/style pairing.
    case style(String, StringStyle)

    /// A name with a block that returns style based on `attributes` dictionary.
    case styleBlock(String, ([String: String]) -> StringStyle)

    /// A `Composable` to insert before entering tags whose name equals `element`.
    case enter(element: String, insert: Composable)

    /// A block that returns `Composable` to insert before entering tags whose name equals `element`, based on
    /// `attributes` dictionary.
    case enterBlock(element: String, insert: ([String: String]) -> Composable)

    /// A `Composable` to insert before exiting tags whose name equals `element`.
    case exit(element: String, insert: Composable)

    /// A block that returns `Composable` to insert before exiting tags whose name equals `element`.
    case exitBlock(element: String, insert: () -> Composable)

    /// An `XMLStyler` implementation for handling `XMLStyleRule`s.
    struct Styler: XMLStyler {

        let rules: [XMLStyleRule]

        func style(forElement name: String, attributes: [String: String], currentStyle: StringStyle) -> StringStyle? {
            for rule in rules {
                switch rule {
                case let .style(string, style) where string == name:
                    return style
                case let .styleBlock(string, block) where string == name:
                    return block(attributes)
                default:
                    break
                }
            }
            for rule in rules {
                if case let .styles(namedStyles) = rule {
                    return namedStyles.style(forName: name)
                }
            }
            return nil
        }

        func prefix(forElement name: String, attributes: [String: String]) -> Composable? {
            for rule in rules {
                switch rule {
                case let .enter(string, composable) where string == name:
                    return composable
                case let .enterBlock(string, block) where string == name:
                    return block(attributes)
                default: break
                }
            }
            return nil
        }

        func suffix(forElement name: String) -> Composable? {
            for rule in rules {
                switch rule {
                case let .exit(string, composable) where string == name:
                    return composable
                case let .exitBlock(string, block) where string == name:
                    return block()
                default: break
                }
            }
            return nil
        }

    }

}

/// A contract to transform an XML string into an attributed string.
public protocol XMLStyler {

    /// Return the style to apply for to the contents of the element. The style
    /// is added onto the current style
    func style(forElement name: String, attributes: [String: String], currentStyle: StringStyle) -> StringStyle?

    /// Provide a `Composable` to add into the string being built before the
    /// named element. This is done after the style for the element has been
    /// applied, but before the contents of the element.
    func prefix(forElement name: String, attributes: [String: String]) -> Composable?

    /// Provide a `Composable` to add into the string being built when leaving
    /// the element. This is done before the style of the element is removed.
    func suffix(forElement name: String) -> Composable?

}

/// Options to control the behavior of the XML parser.
public struct XMLParsingOptions: OptionSet {

    public let rawValue: Int

    // Must be explicitly declared because it has to be marked public.
    public init(rawValue: Int) { self.rawValue = rawValue }

    /// Do not wrap the fragment with a top-level element. Wrapping the XML will
    /// cause a copy of the entire XML string, so for very large strings, it is
    /// recommended that you include a root node yourself and pass this option.
    public static let doNotWrapXML = XMLParsingOptions(rawValue: 1)

}

/// Error wrapper that includes the line and column number of the error.
public struct XMLBuilderError: Error {

    /// The original XML string that was passed in to the parser.
    public let originalXML: String

    /// The error generated by XMLParser.
    public let parserError: Error?

    /// The error code, if the error domain is XMLParser.errorDomain
    public let errorCode: XMLParser.ErrorCode?

    /// The line number where the error occurred, if it can be determined.
    public let line: Int?

    /// The column where the error occurred, if it can be determined.
    public let column: Int?

}

final class BonMotXMLParser: XMLParser {

    let data: Data

    override init(data: Data) {
        self.data = data
        super.init(data: data)
    }

    var xmlAsString: String {
        String(decoding: data, as: UTF8.self)
    }
}

class XMLBuilder: NSObject, XMLParserDelegate {

    static let internalTopLevelElement = "BonMotTopLevelContainer"

    let parser: BonMotXMLParser
    let options: XMLParsingOptions
    var attributedString: NSMutableAttributedString
    var styles: [StringStyle]
    var xmlStylers: [XMLStyler]

    // The XML parser sometimes splits strings, which can break localization-sensitive
    // string transforms. Work around this by using the currentString variable to
    // accumulate partial strings, and then reading them back out as a single string
    // when the current element ends, or when a new one is started.
    var currentString: String?

    private var lastParseError: Error?

    var topStyle: StringStyle {
        guard let style = styles.last else { fatalError("Invalid Style Stack") }
        return style
    }

    var topXMLStyler: XMLStyler {
        guard let styler = xmlStylers.last else { fatalError("Invalid Style Stack") }
        return styler
    }

    init(string: String,
         styler: XMLStyler,
         options: XMLParsingOptions,
         baseStyle: StringStyle) {
        let xml = (options.contains(.doNotWrapXML) ?
            string :
            "<\(XMLBuilder.internalTopLevelElement)>\(string)</\(XMLBuilder.internalTopLevelElement)>")

        let data = Data(xml.utf8)
        self.attributedString = NSMutableAttributedString()
        self.parser = BonMotXMLParser(data: data)
        self.options = options
        self.xmlStylers = [styler]
        // Remove the XMLStyler from the base style
        var style = baseStyle
        style.xmlStyler = nil
        self.styles = [style]
        super.init()
        self.parser.shouldProcessNamespaces = false
        self.parser.shouldReportNamespacePrefixes = false
        self.parser.shouldResolveExternalEntities = false
        self.parser.delegate = self
    }

    func parseAttributedString() throws -> NSMutableAttributedString {
        guard parser.parse() else {
            // By default, we wrap bare strings in a custom XML tag because parsing requires a top-level tag. Due to this wrapping, the column numbers of thrown errors may not make sense. In order to remedy this, we store and return the full string passed to the XML parser, including any BonMot wrapping tags. That way, the error message will include a reference for comparing the column numbers. Not ideal, but better than nothing. We tried to manually adjust the column numbers, but it was fragile and complex and deemed not worth it.

            // n.b. per https://stackoverflow.com/a/38470343/255489, if the parser.parserError is NSXMLParserErrorDomain code 111, it signifies unexpected EOF.

            let lastParseNSError = lastParseError as? NSError
            let line = lastParseNSError?.userInfo["NSXMLParserErrorLineNumber"] as? Int
            let column = lastParseNSError?.userInfo["NSXMLParserErrorColumn"] as? Int
            let errorCode = lastParseNSError?.domain == XMLParser.errorDomain ? (lastParseNSError?.code).flatMap(XMLParser.ErrorCode.init) : nil

            throw XMLBuilderError(
                originalXML: parser.xmlAsString,
                parserError: lastParseError,
                errorCode: errorCode,
                line: line,
                column: column
            )
        }
        return attributedString
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        // parser.parseError may be the overall parse error, like "unexpected EOF," but not the first error encountered when parsing. The first error encountered comes through this delegate method, so this is where we grab it and store it.
        self.lastParseError = parseError
    }

    /// When a node is entered, a new style is derived from the current style
    /// and the style for the node returned by the XMLStyler. If the style
    /// contains an `XMLStyler`, it is pushed onto the `XMLStyler` stack and
    ///
    /// - Parameters:
    ///   - elementName: The name of the XML element.
    ///   - attributes: The XML attributes.
    func enter(element elementName: String, attributes: [String: String]) {
        guard elementName != XMLBuilder.internalTopLevelElement else { return }

        let xmlStyler = topXMLStyler
        let namedStyle = xmlStyler.style(forElement: elementName, attributes: attributes, currentStyle: topStyle)
        var newStyle = topStyle
        if let namedStyle = namedStyle {
            newStyle.add(stringStyle: namedStyle)
        }

        // Update the style stack. The XML styler is removed from the style and
        // added to its own stack to prevent the XML parsing from being
        // re-entrant and occuring on every character group.
        xmlStylers.append(newStyle.xmlStyler ?? topXMLStyler)
        newStyle.xmlStyler = nil
        styles.append(newStyle)

        // The prefix is looked up in the styler that styled this node, not the new styler
        if let prefix = xmlStyler.prefix(forElement: elementName, attributes: attributes) {
            prefix.append(to: attributedString, baseStyle: newStyle)
        }

    }

    func exit(element elementName: String) {
        if let suffix = topXMLStyler.suffix(forElement: elementName) {
            suffix.append(to: attributedString, baseStyle: topStyle)
        }
        styles.removeLast()
        xmlStylers.removeLast()
    }

    func foundNewString() {
        guard let newString = currentString else {
            return
        }
        let newAttributedString = topStyle.attributedString(from: newString)
        attributedString.append(newAttributedString)
        currentString = nil
    }

    @objc func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        foundNewString()
        enter(element: elementName, attributes: attributeDict)
    }

    @objc func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        foundNewString()
        guard elementName != XMLBuilder.internalTopLevelElement else { return }
        exit(element: elementName)
    }

    @objc func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentString = (currentString ?? "").appending(string)
    }

}
