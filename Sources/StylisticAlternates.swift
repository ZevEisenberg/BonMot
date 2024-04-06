//
//  StylisticAlternates.swift
//  BonMot
//
//  Created by Zev Eisenberg on 11/4/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

// This is not supported on watchOS
#if os(iOS) || os(tvOS) || os(OSX)

    /// Different stylistic alternates available for customizing a font.
    /// Typically, a font will support a small subset of these alternates, and
    /// what they mean in a particular font is up to the font's creator. For
    /// example, in Apple's San Francisco font, turn on alternate set "six" to
    /// enable high-legibility alternates for ambiguous characters like: 0lI164.
    public struct StylisticAlternates {

        var one: Bool?
        var two: Bool?
        var three: Bool?
        var four: Bool?
        var five: Bool?
        var six: Bool?
        var seven: Bool?
        var eight: Bool?
        var nine: Bool?
        var ten: Bool?
        var eleven: Bool?
        var twelve: Bool?
        var thirteen: Bool?
        var fourteen: Bool?
        var fifteen: Bool?
        var sixteen: Bool?
        var seventeen: Bool?
        var eighteen: Bool?
        var nineteen: Bool?
        var twenty: Bool?

        public init() { }

    }

    // Convenience constructors
    extension StylisticAlternates {

        public static func one(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.one = isOn
            return alts
        }

        public static func two(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.two = isOn
            return alts
        }

        public static func three(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.three = isOn
            return alts
        }

        public static func four(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.four = isOn
            return alts
        }

        public static func five(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.five = isOn
            return alts
        }

        public static func six(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.six = isOn
            return alts
        }

        public static func seven(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.seven = isOn
            return alts
        }

        public static func eight(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.eight = isOn
            return alts
        }

        public static func nine(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.nine = isOn
            return alts
        }

        public static func ten(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.ten = isOn
            return alts
        }

        public static func eleven(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.eleven = isOn
            return alts
        }

        public static func twelve(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.twelve = isOn
            return alts
        }

        public static func thirteen(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.thirteen = isOn
            return alts
        }

        public static func fourteen(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.fourteen = isOn
            return alts
        }

        public static func fifteen(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.fifteen = isOn
            return alts
        }

        public static func sixteen(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.sixteen = isOn
            return alts
        }

        public static func seventeen(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.seventeen = isOn
            return alts
        }

        public static func eighteen(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.eighteen = isOn
            return alts
        }

        public static func nineteen(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.nineteen = isOn
            return alts
        }

        public static func twenty(on isOn: Bool) -> StylisticAlternates {
            var alts = StylisticAlternates()
            alts.twenty = isOn
            return alts
        }

    }

    extension StylisticAlternates {

        mutating public func add(other theOther: StylisticAlternates) {
            // swiftlint:disable operator_usage_whitespace
            one       = theOther.one       ?? one
            two       = theOther.two       ?? two
            three     = theOther.three     ?? three
            four      = theOther.four      ?? four
            five      = theOther.five      ?? five
            six       = theOther.six       ?? six
            seven     = theOther.seven     ?? seven
            eight     = theOther.eight     ?? eight
            nine      = theOther.nine      ?? nine
            ten       = theOther.ten       ?? ten
            eleven    = theOther.eleven    ?? eleven
            twelve    = theOther.twelve    ?? twelve
            thirteen  = theOther.thirteen  ?? thirteen
            fourteen  = theOther.fourteen  ?? fourteen
            fifteen   = theOther.fifteen   ?? fifteen
            sixteen   = theOther.sixteen   ?? sixteen
            seventeen = theOther.seventeen ?? seventeen
            eighteen  = theOther.eighteen  ?? eighteen
            nineteen  = theOther.nineteen  ?? nineteen
            twenty    = theOther.twenty    ?? twenty
            // swiftlint:enable operator_usage_whitespace
        }

        public func byAdding(other theOther: StylisticAlternates) -> StylisticAlternates {
            var varSelf = self
            varSelf.add(other: theOther)
            return varSelf
        }

    }

    extension StylisticAlternates: FontFeatureProvider {

        // swiftlint:disable:next cyclomatic_complexity
        public func featureSettings() -> [(type: Int, selector: Int)] {
            var selectors = [Int]()

            if let one = one {
                selectors.append(one ? kStylisticAltOneOnSelector : kStylisticAltOneOffSelector)
            }
            if let two = two {
                selectors.append(two ? kStylisticAltTwoOnSelector : kStylisticAltTwoOffSelector)
            }
            if let three = three {
                selectors.append(three ? kStylisticAltThreeOnSelector : kStylisticAltThreeOffSelector)
            }
            if let four = four {
                selectors.append(four ? kStylisticAltFourOnSelector : kStylisticAltFourOffSelector)
            }
            if let five = five {
                selectors.append(five ? kStylisticAltFiveOnSelector : kStylisticAltFiveOffSelector)
            }
            if let six = six {
                selectors.append(six ? kStylisticAltSixOnSelector : kStylisticAltSixOffSelector)
            }
            if let seven = seven {
                selectors.append(seven ? kStylisticAltSevenOnSelector : kStylisticAltSevenOffSelector)
            }
            if let eight = eight {
                selectors.append(eight ? kStylisticAltEightOnSelector : kStylisticAltEightOffSelector)
            }
            if let nine = nine {
                selectors.append(nine ? kStylisticAltNineOnSelector : kStylisticAltNineOffSelector)
            }
            if let ten = ten {
                selectors.append(ten ? kStylisticAltTenOnSelector : kStylisticAltTenOffSelector)
            }
            if let eleven = eleven {
                selectors.append(eleven ? kStylisticAltElevenOnSelector : kStylisticAltElevenOffSelector)
            }
            if let twelve = twelve {
                selectors.append(twelve ? kStylisticAltTwelveOnSelector : kStylisticAltTwelveOffSelector)
            }
            if let thirteen = thirteen {
                selectors.append(thirteen ? kStylisticAltThirteenOnSelector : kStylisticAltThirteenOffSelector)
            }
            if let fourteen = fourteen {
                selectors.append(fourteen ? kStylisticAltFourteenOnSelector : kStylisticAltFourteenOffSelector)
            }
            if let fifteen = fifteen {
                selectors.append(fifteen ? kStylisticAltFifteenOnSelector : kStylisticAltFifteenOffSelector)
            }
            if let sixteen = sixteen {
                selectors.append(sixteen ? kStylisticAltSixteenOnSelector : kStylisticAltSixteenOffSelector)
            }
            if let seventeen = seventeen {
                selectors.append(seventeen ? kStylisticAltSeventeenOnSelector : kStylisticAltSeventeenOffSelector)
            }
            if let eighteen = eighteen {
                selectors.append(eighteen ? kStylisticAltEighteenOnSelector : kStylisticAltEighteenOffSelector)
            }
            if let nineteen = nineteen {
                selectors.append(nineteen ? kStylisticAltNineteenOnSelector : kStylisticAltNineteenOffSelector)
            }
            if let twenty = twenty {
                selectors.append(twenty ? kStylisticAltTwentyOnSelector : kStylisticAltTwentyOffSelector)
            }

            return selectors.map { (type: kStylisticAlternativesType, selector: $0) }
        }

    }

    extension StylisticAlternates {

        public static func + (lhs: StylisticAlternates, rhs: StylisticAlternates) -> StylisticAlternates {
            return lhs.byAdding(other: rhs)
        }

    }
#endif
