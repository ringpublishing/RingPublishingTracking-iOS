//
//  User.swift
//  User
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Additional data used to track user
struct User: Encodable {

    /// IDFA
    let advertisementId: String?

    /// Device ID used when `advertisementId` is not available
    let deviceId: String?

    /// TCFV2.0 Consents string
    let tcfv2: String?

    enum CodingKeys: String, CodingKey {

        case deviceId
        case advertisementId = "advId"
        case tcfv2
    }
}

extension User {

    var dictionary: [String: Any] {
        var params = [String: Any]()

        params["advId"] = advertisementId
        params["deviceId"] = deviceId
        params["tcfv2"] = tcfv2

        return params
    }

    var sizeInBytes: UInt {
        dictionary.jsonSizeInBytes
    }
}
