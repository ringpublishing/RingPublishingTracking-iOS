//
//  ClientType.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 11/04/2022.
//

import Foundation

struct Client: Encodable {

    let client: ClientType
}

struct ClientType: Encodable {

    let type: ClientPlatform

    /// Must stay optional: nil is omitted when encoding, which keeps `RDLC` byte-identical for hosts that do
    /// not report a view type.
    let viewType: ContentViewType?
}

enum ClientPlatform: String, Encodable {

    case nativeApp = "native_app"
}
