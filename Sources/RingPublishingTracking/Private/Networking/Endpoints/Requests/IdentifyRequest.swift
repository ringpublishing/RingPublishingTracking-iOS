//
//  IdentifyRequest.swift
//  IdentifyRequest
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Request body for identify endpoint
struct IdentifyRequest: Encodable {

    /// Stored tracking identifiers
    var ids: [String: String]

    /// Optional additional data used to track user
    var user: User?
}

extension IdentifyRequest: Bodable {

    func toBodyData() throws -> Data {
        try JSONEncoder().encode(self)
    }
}

//extension IdentifyRequest: Decorable {
//    mutating func decorate(using decorators: [Decorator]) {
//        for decorator in decorators {
//            decorator.ids.forEach {
//                ids[$0.key] = $0.value
//            }
//
//            user = decorator.user
//        }
//    }
//}
