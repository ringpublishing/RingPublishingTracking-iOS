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

        // swiftlint:disable non_optional_string_data_conversion
        if let jsonData = try? JSONEncoder().encode(client),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            userDataParams["RDLC"] = Data(jsonString.utf8).base64EncodedString()
        }
        // swiftlint:enable non_optional_string_data_conversion

        return userDataParams
    }
}
