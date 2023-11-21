//
//  ArtemisExternal.swift
//  RingPublishingTracking
//
//  Created by Adam Mordavsky on 15.11.23.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Artemis External model wrapper
struct ArtemisExternal: Codable {

    /// Artemis ID model value
    let model: String

    /// Artemid ID underlaying models
    let models: [String: AnyCodable]
}
