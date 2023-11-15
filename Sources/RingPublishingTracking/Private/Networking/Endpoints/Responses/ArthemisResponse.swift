//
//  ArtemisResponse.swift
//  RingPublishingTracking
//
//  Created by Adam Mordavsky on 09.11.23.
//

import Foundation

struct ArtemisResponseCFG: Decodable {

    /// Expiration time
    let ttl: Int
}

struct ArtemisResponseUser: Decodable {

    let id: ArtemisResponseID
}

struct ArtemisResponseID: Decodable {

    let real: String

    let model: String

    let models: [String: AnyCodable]
}

struct ArtemisResponseModels: Decodable {

    let atsRi: String

    private enum CodingKeys: String, CodingKey {
        case atsRi = "ats_ri"
    }
}

struct ArtemisResponse: Decodable {

    let cfg: ArtemisResponseCFG

    let user: ArtemisResponseUser

    func transform() -> Artemis {
        let external = ArtemisExternal(model: user.id.model, models: user.id.models)
        let id = ArtemisID(artemis: user.id.real, external: external)
        return Artemis(id: id, lifetime: cfg.ttl, creationDate: Date())
    }
}
