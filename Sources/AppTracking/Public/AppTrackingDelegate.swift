//
//  AppTrackingDelegate.swift
//  AppTracking
//
//  Created by Adam Szeremeta on 16/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// AppTracking module delegate
public protocol AppTrackingDelegate: AnyObject {

    /// Delegate method informing when AppTracking module did set tracking identifier assigned to this device
    ///
    /// - Parameters:
    ///   - appTracking: AppTracking
    ///   - identifier: Assigned tracking identifier
    func appTracking(_ appTracking: AppTracking, didAssingTrackingIdentifier identifier: String)
}
