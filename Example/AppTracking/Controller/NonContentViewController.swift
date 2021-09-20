//
//  NonContentViewController.swift
//  AppTracking-Example
//
//  Created by Adam Szeremeta on 20/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit
import AppTracking

class NonContentViewController: UIViewController, PagerViewController, TraceableScreen {

    // MARK: PagerViewController

    var pageIndex: Int {
        return 2
    }

    // MARK: TraceableScreen

    var screenTrackingData: ScreenTrackingData {
        return ScreenTrackingData(structurePath: "NonContent", advertisementArea: "NonContentAdsArea")
    }

    // MARK: Life cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Update our tracking properties for this screen

        updateTrackingProperties()

        // Report page view event

        AppTracking.shared.reportPageView(partiallyReloaded: false)
    }
}
