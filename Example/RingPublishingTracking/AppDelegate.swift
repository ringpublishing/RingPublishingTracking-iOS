//
//  AppDelegate.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 06/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import UIKit
import RingPublishingTracking

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var window: UIWindow? = {
        return UIWindow(frame: UIScreen.main.bounds)
    }()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Example

        // Initialize RingPublishingTracking module before your app wants to send any events.
        // The earlier you will do it - the earlier you will receive assigned 'trackingIdentifier'
        // from SDK by 'RingPublishingTrackingDelegate'

        // We are enabling debug mode by default in demo app

        let debugModeEnabled = true

        // Configuration data

        let tenantId = "<YOUR_TENANT_ID>"
        let apiKey = "<YOUR_API_KEY>"
        let applicationRootPath = "RingPublishingTrackingDemo"
        let applicationDefaultStructurePath = ["Default"]
        let applicationDefaultAdvertisementArea = "DemoAdvertisementArea"

        // Prepare module configuration

        let configuration = RingPublishingTrackingConfiguration(tenantId: tenantId,
                                                                apiKey: apiKey,
                                                                apiUrl: nil,
                                                                applicationRootPath: applicationRootPath,
                                                                applicationDefaultStructurePath: applicationDefaultStructurePath,
                                                                applicationDefaultAdvertisementArea: applicationDefaultAdvertisementArea)

        // Set debug mode before initialzing module

        RingPublishingTracking.shared.setDebugMode(enabled: debugModeEnabled)

        // Initialize RingPublishingTracking module

        RingPublishingTracking.shared.initialize(configuration: configuration, delegate: self)

        return true
    }
}

// MARK: RingPublishingTrackingDelegate
extension AppDelegate: RingPublishingTrackingDelegate {

    func ringPublishingTracking(_ ringPublishingTracking: RingPublishingTracking,
                                didAssignTrackingIdentifier identifier: TrackingIdentifier) {
        print("DEMO - RingPublishingTracking: received tracking identifier: \(identifier)")
    }
}
