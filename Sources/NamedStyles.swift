//
//  NamedStyles.swift
//  BonMot
//
//  Created by Brian King on 8/12/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

import Foundation

/// Stores styles, and allows them to be looked up by name. Used for supporting
/// Interface builder and styling XML markup.
@objc(BONNamedStyles)
public class NamedStyles: NSObject {

    #if os(iOS) || os(tvOS)
    /// A shared repository of styles. It is used by the `bonMotStyleName`
    /// property in Interface Builder. This singleton is pre-populated with 3
    /// values for Dynamic Type: "control", "body", and "preferred".
    public static let shared: NamedStyles = {
        let control = StringStyle(
            .adapt(.control))
        let style = NamedStyles(styles: [
            "control": control,
            "body": StringStyle(.adapt(.body)),
            "preferred": StringStyle(.adapt(.preferred)),
        ])
        return style
    }()
    #else
    /// A shared repository of styles. It is used by the `bonMotStyleName`
    /// property in Interface Builder.
    public static let shared = NamedStyles()
    #endif

    /// Define a closure to be invoked when an unregistered style is requested.
    /// By default, an error is printed.
    public static var unregisteredStyleClosure: (String) -> Void = { name in
        print("Requesting unregistered style \(name)")
    }

    /// Create a new `NamedStyles` object with the specified name-to-style
    /// mapping.
    /// - parameter styles: A dictionary containing the name-to-style mapping
    public init(styles: [String: StringStyle] = [:]) {
        self.styles = styles
    }

    /// The name-to-style mapping
    public var styles: [String: StringStyle]

    /// Register a new named style for later retrieval.
    ///
    /// - Parameters:
    ///   - name: The name of the new style. If a style is already registered
    ///           for this name, it is replaced.
    ///   - style: The style to register.
    public func registerStyle(forName name: String, style: StringStyle) {
        styles[name] = style
    }

    /// Look up a style for the specified name. If no style is found,
    /// `NamedStyles.unregisteredStyleClosure` is called. This is done for error
    /// reporting and safety. We don't want to crash if no style is found, and
    /// we want to avoid adding `throws` everywhere. In general, if a style is
    /// requested by name, it will just log, and your text will be un-styled.
    ///
    /// - parameter forName: The name of the style to look up
    /// - returns: the requested style, or `nil` if none is found
    public func style(forName name: String) -> StringStyle? {
        guard let style = styles[name] else {
            NamedStyles.unregisteredStyleClosure(name)
            return nil
        }
        return style
    }

}
