//
//  UserData.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 07/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct SSO: Encodable {

    let logged: Logged
    let name: String
}

struct Logged: Encodable {

    let id: String?
    let md5: String?
}

struct UserData: Encodable {

    enum CodingKeys: String, CodingKey {
        case sso
        case id
        case isActiveSubscriber = "type"
    }

    var sso: SSO? {
        guard let ssoSystemName = ssoSystemName else { return nil }

        let emailMD5 = email?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().md5()

        return SSO(logged: Logged(id: userId, md5: emailMD5), name: ssoSystemName)
    }

    var id: ArtemisID?
    var email: String?
    var userId: String?
    var ssoSystemName: String?
    var isActiveSubscriber: Bool?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(sso, forKey: .sso)
        try container.encode(id, forKey: .id)

        if isActiveSubscriber == true {
            try container.encode("subscriber", forKey: .isActiveSubscriber)
        }
    }
}
