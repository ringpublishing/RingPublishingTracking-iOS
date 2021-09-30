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
    let advertisementId: String? = nil

    /// Device ID used when `advertisementId` is not available
    let deviceId: String? = nil

    enum CodingKeys: String, CodingKey {

        case deviceId
        case advertisementId = "advId"
    }
}

extension User {

    var dictionary: [String: Any] {
        var dic = [String: Any]()

        dic["advId"] = advertisementId
        dic["deviceId"] = deviceId

        return dic
    }

    var sizeInBytes: UInt {
        dictionary.jsonSizeInBytes
    }
}
