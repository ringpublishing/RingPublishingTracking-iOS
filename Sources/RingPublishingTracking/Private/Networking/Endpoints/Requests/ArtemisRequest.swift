//
//  ArtemisRequest.swift
//  RingPublishingTracking
//
//  Created by Adam Mordavsky on 08.11.23.
//

import Foundation

struct ArtemisRequest {

    let eaUUID: String

    let sso: SSO?

    let tenantID: String
}

extension ArtemisRequest: Bodable {

    var dictionary: [String: Any] {
        var dictionary: [String: Any] = [:]
        var userDictionary: [String: Any] = [
            "id": [
                "local": eaUUID,
                "global": eaUUID
            ]
        ]
        if let sso {
            userDictionary["sso"] = [
                "name": sso.name,
                "id": sso.logged.id
            ]
        }
        dictionary["user"] = userDictionary
        dictionary["tid"] = tenantID
        return dictionary
    }

    func toBodyData() throws -> Data {
        try dictionary.dataUsingJSONSerialization()
    }
}
