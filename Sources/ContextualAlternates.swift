//
//  ContextualAlternates.swift
//  BonMot
//
//  Created by Zev Eisenberg on 11/5/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

// This is not supported on watchOS
#if os(iOS) || os(tvOS) || os(OSX)

    /// Different contextual alternates available for customizing a font. Not
    /// all fonts support all (or any) of these options.
    public struct ContextualAlternates {

        var contextualAlternates: Bool?
        var swashAlternates: Bool?
        var contextualSwashAlternates: Bool?

        public init() { }

    }

    // Convenience constructors
    extension ContextualAlternates {

        public static func contextualAlternates(on isOn: Bool) -> ContextualAlternates {
            var alts = ContextualAlternates()
            alts.contextualAlternates = isOn
            return alts
        }

        public static func swashAlternates(on isOn: Bool) -> ContextualAlternates {
            var alts = ContextualAlternates()
            alts.swashAlternates = isOn
            return alts
        }

        public static func contextualSwashAlternates(on isOn: Bool) -> ContextualAlternates {
            var alts = ContextualAlternates()
            alts.contextualSwashAlternates = isOn
            return alts
        }

    }

    extension ContextualAlternates {

        mutating public func add(other theOther: ContextualAlternates) {
            contextualAlternates = theOther.contextualAlternates ?? contextualAlternates
            swashAlternates = theOther.swashAlternates ?? swashAlternates
            contextualSwashAlternates = theOther.contextualSwashAlternates ?? contextualSwashAlternates
        }

        public func byAdding(other theOther: ContextualAlternates) -> ContextualAlternates {
            var varSelf = self
            varSelf.add(other: theOther)
            return varSelf
        }

    }

    extension ContextualAlternates: FontFeatureProvider {

        public func featureSettings() -> [(type: Int, selector: Int)] {
            var selectors = [Int]()

            if let contextualAlternates = contextualAlternates {
                selectors.append(contextualAlternates ? kContextualAlternatesOnSelector : kContextualAlternatesOffSelector)
            }
            if let swashAlternates = swashAlternates {
                selectors.append(swashAlternates ? kSwashAlternatesOnSelector : kSwashAlternatesOffSelector)
            }
            if let contextualSwashAlternates = contextualSwashAlternates {
                selectors.append(contextualSwashAlternates ? kContextualSwashAlternatesOnSelector : kContextualSwashAlternatesOffSelector)
            }

            return selectors.map { (type: kContextualAlternatesType, selector: $0) }
        }

    }

    extension ContextualAlternates {
        public static func + (lhs: ContextualAlternates, rhs: ContextualAlternates) -> ContextualAlternates {
            return lhs.byAdding(other: rhs)
        }
    }
#endif
