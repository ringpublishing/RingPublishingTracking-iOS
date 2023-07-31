//
//  UserManager.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 21/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

protocol Userable {

    func buildUser() -> User
    func updateIDFA(idfa: UUID?)
    func updateDeviceId(deviceId: String?)
    func updateTCFV2(tcfv2: String?)
}

final class UserManager: Userable {

    private(set) var idfa: UUID?
    private(set) var deviceId: String?
    private(set) var tcfv2: String?

    func buildUser() -> User {
        return User(advertisementId: idfa?.uuidString, deviceId: deviceId, tcfv2: tcfv2)
    }

    func updateIDFA(idfa: UUID?) {
        self.idfa = idfa
    }

    func updateDeviceId(deviceId: String?) {
        self.deviceId = deviceId
    }

    func updateTCFV2(tcfv2: String?) {
        self.tcfv2 = tcfv2
    }
}
