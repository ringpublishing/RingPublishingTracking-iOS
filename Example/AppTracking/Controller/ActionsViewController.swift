//
//  ActionsViewController.swift
//  AppTracking-Example
//
//  Created by Adam Szeremeta on 17/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit
import AppTracking

class ActionsViewController: UIViewController, PagerViewController, TraceableScreen {

    // MARK: PagerViewController

    var pageIndex: Int {
        return 1
    }

    // MARK: TraceableScreen

    var screenTrackingData: ScreenTrackingData {
        return ScreenTrackingData(structurePath: "Actions", advertisementArea: "ActionsAdsArea")
    }

    // MARK: Life cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Update our tracking properties for this screen

        updateTrackingProperties()

        // Report page view event

        AppTracking.shared.reportPageView(partiallyReloaded: false)
    }

    // MARK: Actions (Login + logout)

    @IBAction func onLoginActionTouch(_ sender: Any) {
        // When user log in we should update tracking module with his account information

        AppTracking.shared.updateUserData(ssoSystemName: "AppTrackingSSO", userId: "12345")

        // Each non content button click we can report using 'reportClick' method

        reportButtonClickEvent(sender)
    }

    @IBAction func onLogoutActionTouch(_ sender: Any) {
        // When user log out from the application we should update tracking module

        AppTracking.shared.updateUserData(ssoSystemName: "AppTrackingSSO", userId: nil)

        // Each non content button click we can report using 'reportClick' method

        reportButtonClickEvent(sender)
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

// MARK: Private
private extension ActionsViewController {

    func reportButtonClickEvent(_ sender: Any) {
        // If our click action does not have a name, we can omit it
        let actionName = (sender as? UIButton)?.titleLabel?.text

        AppTracking.shared.reportClick(selectedElementName: actionName)
    }
}
