//
//  AppDelegate.swift
//  BonMot
//
//  Created by Brian King on 7/20/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

import BonMot
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        style()
        window?.makeKeyAndVisible()
        application.enableAdaptiveContentSizeMonitor()
        return true
    }

    func style() {
        guard let traitCollection = window?.traitCollection else {
            fatalError("There should be a traitCollection available before calling this method.")
        }
        let titleStyle = StringStyle(
            .font(UIFont.appFont(ofSize: 20)),
            .adapt(.control)
        )
        UINavigationBar.appearance().titleTextAttributes = titleStyle.attributes(adaptedTo: traitCollection)
        let barStyle = StringStyle(
            .font(UIFont.appFont(ofSize: 17)),
            .adapt(.control)
        )
        UIBarButtonItem.appearance().setTitleTextAttributes(barStyle.attributes(adaptedTo: traitCollection), for: .normal)
    }

}

extension UIColor {
    static var raizlabsRed: UIColor {
        return UIColor(hex: 0xEC594D)
    }

    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xff) / 255.0,
            green: CGFloat((hex >> 8) & 0xff) / 255.0,
            blue: CGFloat(hex & 0xff) / 255.0,
            alpha: alpha)
    }

}

extension UIFont {

    static func appFont(ofSize pointSize: CGFloat) -> UIFont {
        return UIFont(name: "Avenir-Roman", size: pointSize)!
    }

}
