//
//  UserData.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 07/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct UserInfo: Encodable {

    let sso: SSO
}

struct SSO: Encodable {

    let logged: Logged
    let name: String
}

struct Logged: Encodable {

    let id: String? // swiftlint:disable:this identifier_name
    let md5: String?
}

struct UserData: Encodable {

    let user: UserInfo
}
