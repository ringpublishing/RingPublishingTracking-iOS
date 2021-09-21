//
//  User.swift
//  User
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct User: Encodable {

    let adpConsent: String?
    let pubConsent: String?
    let advertisementId: String? = nil
    let deviceId: String? = nil
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
