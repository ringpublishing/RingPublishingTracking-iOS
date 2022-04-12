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
}

enum ClientPlatform: String, Encodable {

    case nativeApp = "native_app"
}
