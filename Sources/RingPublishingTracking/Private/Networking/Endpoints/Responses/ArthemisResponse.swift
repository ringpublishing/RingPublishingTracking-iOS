//
//  ArtemisResponse.swift
//  RingPublishingTracking
//
//  Created by Adam Mordavsky on 09.11.23.
//

import Foundation

struct ArtemisResponse: Decodable {

    struct CFG: Decodable {
        /// Expiration time
        let ttl: Int
    }

    struct User: Decodable {

        let id: ID
    }

    struct ID: Decodable {
        let real: String

        let model: String

        let models: Models
    }

    struct Models: Decodable {

        let atsRi: String

        private enum CodingKeys: String, CodingKey {
            case atsRi = "ats_ri"
        }
    }

    let cfg: ArtemisResponse.CFG

    let user: ArtemisResponse.User

    func transform() -> ArtemisObject {
        let external: ArtemisObject.ID.External = .init(model: user.id.model, models: user.id.models.atsRi)
        let id: ArtemisObject.ID = .init(artemis: user.id.real, external: external)
        return ArtemisObject(id: id, lifetime: cfg.ttl, creationDate: Date())
    }
}
