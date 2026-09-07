//
//  ClientContext.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 11/04/2022.
//

import Foundation

struct Client: Encodable {

    let client: ClientContext
    let variant: ClientVariant?

    init(viewType: ContentViewType? = nil, variant: ClientVariant? = nil) {
        self.client = ClientContext(type: .nativeApp, viewType: viewType)
        self.variant = variant
    }
}

struct ClientContext: Encodable {

    let type: ClientPlatform

    /// Must stay optional: nil is omitted when encoding, which keeps `RDLC` byte-identical for events
    /// reported without a view type.
    let viewType: ContentViewType?
}

enum ClientPlatform: String, Encodable {

    case nativeApp = "native_app"
}

struct ClientVariant: Encodable {

    let external: [String: String]
}
