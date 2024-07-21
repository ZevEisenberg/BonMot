//
//  CatalogViewController.swift
//  BonMot
//
//  Created by Brian King on 7/27/16.
//  Copyright © 2016 Rightpoint. All rights reserved.
//

import UIKit

class CatalogViewController: UIViewController {
    @IBAction func displayAlert() {
        let controller = UIAlertController(title: "Alert", message: "This is a message", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
}
