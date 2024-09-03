//
//  RingPublishingTracking.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 06/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Functionality related to current aplication state
public extension RingPublishingTracking {

    /// Update application user identifier for tracking purpose.
    /// If user is not logged in, pass nil as 'userId'.
    ///
    /// - Parameters:
    ///   - ssoSystemName: Name of SSO system used to login
    ///   - userId: User identifier
    ///   - userEmail: User email address
    func updateUserData(ssoSystemName: String, userId: String?, userEmail: String?) {
        let obscuredId: String? = userId == nil ? nil : String(repeating: "*", count: userId?.count ?? 0)
        Logger.log("Updating application user data, SSO: '\(ssoSystemName)' and userId: '\(obscuredId.logable)'")

        eventsService?.updateUserData(userId: userId, email: userEmail)
    }

    /// Update user active subscription status
    ///
    /// - Parameter isActiveSubscriber: Bool
    func updateActiveSubscriber(_ isActiveSubscriber: Bool?) {
        eventsService?.updateActiveSubscriber(isActiveSubscriber)
    }

    /// Update SSO system name
    ///
    /// - Parameter ssoSystemName: String
    func updateSSO(ssoSystemName: String?) {
        eventsService?.updateSSO(ssoSystemName: ssoSystemName)
    }

    /// User logged out, clear user data
    func logout() {
        eventsService?.updateUserData(userId: nil, email: nil)
    }

    /// Update ad space name of the application, for example "ads/list/sport"
    ///
    /// - Parameter currentAdvertisementArea: String
    func updateApplicationAdvertisementArea(currentAdvertisementArea: String) {
        Logger.log("Updating application advertisement area to: '\(currentAdvertisementArea)'")

        eventsService?.updateApplicationAdvertisementArea(currentAdvertisementArea)
    }
}
