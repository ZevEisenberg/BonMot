//
//  TextAlignmentConstraint.swift
//  BonMot
//
//  Created by Cameron Pulsford on 10/4/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

#if !os(watchOS)

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

/// Used to align various UI controls (anything with a font or attribute text)
/// by properties that are not available with stock constraints:
/// - cap height (the tops of capital letters)
/// - x-height (the height of a lowercase "x")
@objc(BONTextAlignmentConstraint)
public class TextAlignmentConstraint: NSLayoutConstraint {

    @objc(BONTextAlignmentConstraintAttribute)
    public enum TextAttribute: Int, CustomStringConvertible {

        case unspecified
        case top
        case capHeight
        case xHeight
        case firstBaseline
        case lastBaseline
        case bottom

        var layoutAttribute: NSLayoutConstraint.Attribute {
            switch self {
            case .top, .capHeight, .firstBaseline, .xHeight:
                return .top
            case .lastBaseline, .bottom:
                return .bottom
            case .unspecified:
                return .notAnAttribute
            }
        }

        static private let ibInspectableMapping: [String: TextAttribute] = [
            "unspecified": .unspecified,
            "top": .top,
            "capheight": .capHeight,
            "xheight": .xHeight,
            "firstbaseline": .firstBaseline,
            "lastbaseline": .lastBaseline,
            "bottom": .bottom,
        ]

        public var description: String {
            switch self {
            case .unspecified:
                return "unspecified"
            case .top:
                return "top"
            case .capHeight:
                return "cap height"
            case .xHeight:
                return "x-height"
            case .firstBaseline:
                return "first baseline"
            case .lastBaseline:
                return "last baseline"
            case .bottom:
                return "bottom"
            }
        }

        init(ibInspectableString string: String) {
            self = TextAttribute.ibInspectableMapping[string] ?? .unspecified
        }

    }

    @IBInspectable public var firstAlignment: String? {
        didSet {
            firstItemAttribute = TextAttribute(ibInspectableString: firstAlignment?.normalized ?? "")
        }
    }

    @IBInspectable public var secondAlignment: String? {
        didSet {
            secondItemAttribute = TextAttribute(ibInspectableString: secondAlignment?.normalized ?? "")
        }
    }

    public private(set) var firstItemAttribute: TextAttribute = .unspecified
    public private(set) var secondItemAttribute: TextAttribute = .unspecified
    private var item1: AnyObject!
    private var item2: AnyObject!

    private static var kvoContext = 0

    // The class part of these selectors are ignored; it is there simply to satisfy Xcode's selector syntax.
    private static let fontSelector = #selector(getter: BONTextField.font)

    #if canImport(AppKit)
        private static let attributedTextSelector = #selector(getter: NSTextField.attributedStringValue)
    #else
        private static let attributedTextSelector = #selector(getter: UITextField.attributedText)
    #endif

    /// Construct a new `TextAlignmentConstraint`.
    ///
    /// - Parameters:
    ///   - view1: The view for the left side of the constraint equation.
    ///   - attr1: The attribute of the view for the left side of the constraint equation.
    ///   - relation: The relationship between the left and right side of the constraint equation.
    ///   - view2: The view for the right side of the constraint equation.
    ///   - attr2: The attribute of the view for the right side of the constraint equation.
    /// - Returns: A constraint object relating the two provided views with the
    ///            specified relation and attributes.
    public static func with(
        item view1: AnyObject, attribute attr1: TextAttribute, relatedBy relation: NSLayoutConstraint.Relation, toItem view2: AnyObject, attribute attr2: TextAttribute) -> TextAlignmentConstraint {
        let constraint = TextAlignmentConstraint(
            item: view1,
            attribute: attr1.layoutAttribute,
            relatedBy: relation,
            toItem: view2,
            attribute: attr2.layoutAttribute,
            multiplier: 1,
            constant: 0)

        constraint.item1 = view1
        constraint.item2 = view2
        constraint.firstItemAttribute = attr1
        constraint.secondItemAttribute = attr2

        constraint.setupObservers()
        constraint.updateConstant()

        return constraint
    }

    deinit {
        tearDownObservers()
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        setupObservers()
        updateConstant()
    }

    private func setupObservers() {
        for keyPath in fontKeyPaths {
            addObserver(self, forKeyPath: keyPath, options: [], context: &Self.kvoContext)
        }
    }

    private func tearDownObservers() {
        for keyPath in fontKeyPaths {
            removeObserver(self, forKeyPath: keyPath, context: &Self.kvoContext)
        }
    }

    private var fontKeyPaths: [String] {
        let firstItemSelector = #selector(getter: NSLayoutConstraint.firstItem)
        let secondItemSelector = #selector(getter: NSLayoutConstraint.secondItem)

        return [
            "\(firstItemSelector).\(TextAlignmentConstraint.fontSelector)",
            "\(firstItemSelector).\(TextAlignmentConstraint.attributedTextSelector)",
            "\(secondItemSelector).\(TextAlignmentConstraint.fontSelector)",
            "\(secondItemSelector).\(TextAlignmentConstraint.attributedTextSelector)",
        ]
    }

    // Can't use block-based KVO until we can use \NSLayoutConstraint.firstItem
    // swiftlint:disable:next block_based_kvo
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &Self.kvoContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        updateConstant()
    }

    private func updateConstant() {
        let distanceFromTop1 = distanceFromTop(of: firstItem!, with: firstItemAttribute)
        let distanceFromTop2 = distanceFromTop(of: secondItem!, with: secondItemAttribute)
        let difference = distanceFromTop2 - distanceFromTop1
        constant = difference
    }

    private func distanceFromTop(of item: AnyObject, with attribute: TextAttribute) -> CGFloat {
        guard let font = font(from: item) else {
            return 0
        }

        let topToBaseline = font.ascender
        let distanceFromTop: CGFloat

        switch attribute {
        case .capHeight:
            distanceFromTop = topToBaseline - font.capHeight
        case .xHeight:
            distanceFromTop = topToBaseline - font.xHeight
        case .top:
            distanceFromTop = 0
        case .firstBaseline, .lastBaseline, .bottom:
            fatalError("\(attribute) alignment is not currently supported with \(self). Please check https://github.com/Rightpoint/BonMot/issues/37 for progress on this issue.")
        case .unspecified:
            fatalError("Attempt to reason about unspecified constraint attribute")
        }

        return distanceFromTop
    }

    private func font(from item: AnyObject) -> BONFont? {
        var font: BONFont?

        if item.responds(to: TextAlignmentConstraint.fontSelector) {
            font = item.perform(TextAlignmentConstraint.fontSelector).takeUnretainedValue() as? BONFont
        }

        return font
    }
}

private extension String {

    var normalized: String {
        var n = self.lowercased()
        n = n.components(separatedBy: CharacterSet.letters.inverted).joined(separator: "")
        n = n.components(separatedBy: CharacterSet.whitespacesAndNewlines).joined(separator: "")
        return n
    }

}

#endif
