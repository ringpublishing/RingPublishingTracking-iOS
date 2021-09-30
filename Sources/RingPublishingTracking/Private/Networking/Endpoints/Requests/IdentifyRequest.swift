//
//  IdentifyRequest.swift
//  IdentifyRequest
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Request body for identify endpoint
struct IdentifyRequest: Encodable, Bodable {

    /// Stored tracking identifiers
    let ids: [String: String]

    /// Optional additional data used to track user
    let user: User?

    func toBodyData() throws -> Data {
        try JSONEncoder().encode(self)
    }
}
