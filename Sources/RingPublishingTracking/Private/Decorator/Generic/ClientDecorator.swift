//
//  ClientDecorator.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 11/04/2022.
//

import Foundation

final class ClientDecorator: Decorator {

    private var viewType: ContentViewType?

    var parameters: [String: AnyHashable] {
        var userDataParams: [String: AnyHashable] = [:]

        let client = Client(client: ClientType(type: .nativeApp, viewType: viewType))
        userDataParams["RDLC"] = client.jsonStringBase64

        return userDataParams
    }
}

extension ClientDecorator {

    func updateViewType(_ viewType: ContentViewType?) {
        self.viewType = viewType
    }
}
