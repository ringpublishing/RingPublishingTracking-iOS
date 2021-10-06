//
//  UserDataDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 04/10/2021.
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

    let id: String // swiftlint:disable:this identifier_name
}

struct UserData: Encodable {

    let user: UserInfo
}

final class UserDataDecorator: Decorator {

    private var data: UserData?

    func parameters() -> [String: String] {
        guard
            let data = data,
            let jsonData = try? JSONEncoder().encode(data),
            let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            return [:]
        }

        return [
            "RDLU": Data(jsonString.utf8).base64EncodedString()
        ]
    }
}

extension UserDataDecorator {

    func updateUserData(data: UserData?) {
        self.data = data
    }
}
