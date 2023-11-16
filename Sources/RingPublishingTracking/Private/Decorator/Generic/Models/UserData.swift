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

    var sso: SSO?
    var id: ArtemisID?
}
