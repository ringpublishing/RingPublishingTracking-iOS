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

    var parameters: [String: AnyHashable] {
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
