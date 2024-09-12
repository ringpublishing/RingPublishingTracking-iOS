//
//  ClientDecorator.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 11/04/2022.
//

import Foundation

final class ClientDecorator: Decorator {

    private let client = Client(client: ClientType(type: .nativeApp))

    var parameters: [String: AnyHashable] {
        var userDataParams: [String: AnyHashable] = [:]

        userDataParams["RDLC"] = client.jsonStringBase64

        return userDataParams
    }
}
