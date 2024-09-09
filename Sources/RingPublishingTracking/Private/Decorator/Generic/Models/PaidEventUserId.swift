//
//  PaidEventUserId.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct PaidEventUserId: Encodable {

    enum CodingKeys: String, CodingKey {
        case fakeUserId = "fake_user_id"
        case realUserId = "real_user_id"
    }

    let fakeUserId: String?
    let realUserId: String?
}
