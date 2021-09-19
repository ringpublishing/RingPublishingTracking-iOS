//
//  AppTracking.swift
//  AppTracking
//
//  Created by Adam Szeremeta on 06/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Functionality related to current aplication state
public extension AppTracking {

    // MARK: Dynamic tracking properties

    /// Update application user identifier for tracking purpose.
    /// If user is not logged in, pass nil as 'userId'.
    ///
    /// - Parameters:
    ///   - ssoSystemName: Name of SSO system used to login
    ///   - userId: User identifier
    func updateUserData(ssoSystemName: String, userId: String?) {
        // TODO: Implementation missing
    }

    /// Update application structure path used to identify application screen, for example "home_screen".
    ///
    /// - Parameter currentAppArea: String
    func updateApplicationStructurePath(currentStructurePath: String) {
        Logger.log("Updating application structure path to: '\(currentStructurePath)'")

        // TODO: Implementation missing
    }

    /// Update application structure path used to identify application screen, for example "home_screen".
    ///
    /// - If you want to have maintain your app navigation hierarchy, you can pass multiple paths which will be joined together.
    ///
    /// - Parameter currentAppArea: String
    func updateApplicationStructurePath(currentStructurePath: [String]) {
        let joinedPath = currentStructurePath.joined(separator: "/")

        updateApplicationStructurePath(currentStructurePath: joinedPath)
    }

    /// Update ad space name of the application, for example "ads/list/sport"
    ///
    /// - Parameter currentAdvertisementArea: String
    func updateApplicationAdvertisementArea(currentAdvertisementArea: String) {
        Logger.log("Updating application advertisement area to: '\(currentAdvertisementArea)'")

        // TODO: Implementation missing
    }
}
