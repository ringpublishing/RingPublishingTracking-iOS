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

        if let jsonData = try? JSONEncoder().encode(client),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            userDataParams["RDLC"] = Data(jsonString.utf8).base64EncodedString()
        }

        return userDataParams
    }
}
