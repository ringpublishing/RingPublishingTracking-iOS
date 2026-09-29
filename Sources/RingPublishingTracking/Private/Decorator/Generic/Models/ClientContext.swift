//
//  ClientContext.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 11/04/2022.
//

import Foundation

struct Client: Encodable {

    let client: ClientContext

    /// Must stay optional: nil is omitted when encoding, which keeps `RDLC` byte-identical for events
    /// reported without a view type.
    let view: ContentViewType?
    let variant: ClientVariant?

    init(viewType: ContentViewType? = nil, variant: ClientVariant? = nil) {
        self.client = ClientContext(type: .nativeApp)
        self.view = viewType
        self.variant = variant
    }
}

struct ClientContext: Encodable {

    let type: ClientPlatform
}

enum ClientPlatform: String, Encodable {

    case nativeApp = "native_app"
}

struct ClientVariant: Encodable {

    let external: [String: String]
}
