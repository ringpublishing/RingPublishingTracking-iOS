//
//  UserManager.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 21/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

protocol Userable {
    func buildUser() -> User
    func updateIDFA(idfa: UUID?)
    func updateDeviceId(deviceId: String?)
}

final class UserManager: Userable {
    private(set) var idfa: UUID?
    private(set) var deviceId: String?

    func buildUser() -> User {
        if let idfa = idfa {
            return User(advertisementId: idfa.uuidString, deviceId: nil)
        }

        if let deviceId = deviceId {
            return User(advertisementId: nil, deviceId: deviceId)
        }

        return User(advertisementId: nil, deviceId: nil)
    }

    func updateIDFA(idfa: UUID?) {
        self.idfa = idfa
    }

    func updateDeviceId(deviceId: String?) {
        self.deviceId = deviceId
    }
}
