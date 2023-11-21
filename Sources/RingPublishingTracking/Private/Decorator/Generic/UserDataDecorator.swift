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

    private var data: UserData? = UserData(sso: nil, id: nil)

    var sso: SSO? {
        return data?.sso
    }

    var parameters: [String: AnyHashable] {
        var userDataParams: [String: AnyHashable] = [:]

        // RDLU
        if let rdlu = prepareRDLU(data: data) {
            userDataParams["RDLU"] = rdlu.base64EncodedString()
        }

        // IZ
        if let userId = data?.sso?.logged.id {
            userDataParams["IZ"] = userId
        }

        return userDataParams
    }
}

extension UserDataDecorator {

    func updateSSOData(sso: SSO?) {
        data?.sso = sso
    }

    func updateArtemisData(artemis: ArtemisID?) {
        data?.id = artemis
    }
}

private extension UserDataDecorator {

    func prepareRDLU(data: UserData?) -> Data? {
        guard let data = data, data.sso != nil || data.id != nil else { return nil }

        return try? encoder.encode(data)
    }
}
