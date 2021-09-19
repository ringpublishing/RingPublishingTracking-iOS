//
//  ActionsViewController.swift
//  AppTracking-Example
//
//  Created by Adam Szeremeta on 17/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit

class ActionsViewController: UIViewController, PagerViewController {

    var pageIndex: Int {
        return 1
    }

    // MARK: Actions (Login + logout)

    @IBAction func onLoginActionTouch(_ sender: Any) {

    }

    @IBAction func onLogoutActionTouch(_ sender: Any) {

    }

    // MARK: Actions (User action)

    @IBAction func onReportUserActionAsStringTouch(_ sender: Any) {

    }

    @IBAction func onReportUserActionAsDictionaryTouch(_ sender: Any) {

    }

    // MARK: Actions (Detail)

    @IBAction func onDetailFromPushActionTouch(_ sender: Any) {

    }

    @IBAction func onDetailFromSocialActionTouch(_ sender: Any) {

    }

    // MARK: Actions (Generic event)

    @IBAction func onReportGenericEventActionTouch(_ sender: Any) {

    }

    // MARK: Actions (Debug mode)

    @IBAction func onEnableDebugModeActionTouch(_ sender: Any) {

    }

    @IBAction func onDisableDebugModeActionTouch(_ sender: Any) {

    }

    // MARK: Actions (Opt-out mode)

    @IBAction func onEnableOptOutModeActionTouch(_ sender: Any) {

    }

    @IBAction func onDisableOptOutModeActionTouch(_ sender: Any) {

    }
}
