//
//  ViewController.swift
//  AppTracking
//
//  Created by Adam Szeremeta on 06/09/2021.
//

import UIKit
import AppTracking

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appTracking = AppTracking.shared
        appTracking.loggerOutput = { message in
            print("SDK message: \(message)")
        }

    }
}
