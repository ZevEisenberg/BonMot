//
//  Ligatures.swift
//  BonMot
//
//  Created by Zev Eisenberg on 11/1/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

/// Different ligature styles for use in attributed strings.
public enum Ligatures: Int {

    /// No ligatures.
    case disabled = 0

    /// Default ligatures.
    case defaults = 1

    #if canImport(AppKit)
    /// All ligatures.
    case all = 2
    #endif

}
