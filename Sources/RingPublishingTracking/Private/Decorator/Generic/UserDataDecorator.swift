//
//  UserDataDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 04/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class UserDataDecorator: Decorator {

    private var data: UserData?

    var sso: SSO? {
        return data?.sso
    }

    var parameters: [String: AnyHashable] {
        var userDataParams: [String: AnyHashable] = [:]

        guard let data = data else { return userDataParams }

        // RDLU
        if data.sso.logged.id != nil || data.sso.logged.md5 != nil,
           let jsonData = try? JSONEncoder().encode(data), let jsonString = String(data: jsonData, encoding: .utf8) {
            userDataParams["RDLU"] = Data(jsonString.utf8).base64EncodedString()
        }

        // IZ
        if let userId = data.sso.logged.id {
            userDataParams["IZ"] = userId
        }

        return userDataParams
    }
}

extension UserDataDecorator {

    func updateUserData(data: UserData?) {
        self.data = data
    }
}
