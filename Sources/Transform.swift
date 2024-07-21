//
//  Transform.swift
//  BonMot
//
//  Created by Zev Eisenberg on 3/24/17.
//  Copyright © 2017 Rightpoint. All rights reserved.
//

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

public enum Transform {

    public typealias TransformFunction = (String) -> String

    case lowercase
    case uppercase
    case capitalized

    case lowercaseWithLocale(Locale)
    case uppercaseWithLocale(Locale)
    case capitalizedWithLocale(Locale)
    case custom(TransformFunction)

    var transformer: TransformFunction {
        switch self {
        case .lowercase: return { string in string.localizedLowercase }
        case .uppercase: return { string in string.localizedUppercase }
        case .capitalized: return { string in string.localizedCapitalized }

        case .lowercaseWithLocale(let locale): return { string in string.lowercased(with: locale) }
        case .uppercaseWithLocale(let locale): return { string in string.uppercased(with: locale) }
        case .capitalizedWithLocale(let locale): return { string in string.capitalized(with: locale) }

        case .custom(let transform): return transform
        }
    }

}
