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
}

final class UserManager: Userable {

    func buildUser() -> User {
        // TODO: missing implementation
        User()
    }
}
