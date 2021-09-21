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

    /// Properly encoded string that holds partners' consents
    let adpConsent: String?

    /// Properly encoded string that holds publisher's consents
    let pubConsent: String?

    /// IDFA
    let advertisementId: String? = nil

    /// Device ID used when `advertisementId` is not available
    let deviceId: String? = nil

    /// MD5 of the email for logged-in users
    let userEmailMD5: String? = nil

    enum CodingKeys: String, CodingKey {

        case adpConsent, pubConsent, deviceId
        case advertisementId = "advId"
        case userEmailMD5 = "aId"
    }
}

extension User {
    var dictionary: [String: Any] {
        var dic = [String: Any]()

        dic["adpConsent"] = adpConsent
        dic["pubConsent"] = pubConsent
        dic["advId"] = advertisementId
        dic["deviceId"] = deviceId
        dic["aId"] = userEmailMD5

        return dic
    }

    var sizeInBytes: UInt {
        dictionary.jsonSizeInBytes
    }
}
