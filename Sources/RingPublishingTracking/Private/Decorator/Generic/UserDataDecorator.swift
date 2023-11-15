//
//  UserDataDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 04/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class UserDataDecorator: Decorator {

    private lazy var encoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()

    private var data: UserData?

    var sso: SSO? {
        return data?.sso
    }

    var parameters: [String: AnyHashable] {
        var userDataParams: [String: AnyHashable] = [:]

        guard let data = data else { return userDataParams }

        // RDLU
        if let rdlu = prepareRDLU(data: data) {
            userDataParams["RDLU"] = rdlu.base64EncodedString()
        }

        // IZ
        if let userId = data.sso?.logged.id {
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

private extension UserDataDecorator {
    func prepareRDLU(data: UserData) -> Data? {
        guard let jsonData = try? encoder.encode(data) else { return nil }
        return jsonData
    }
}
