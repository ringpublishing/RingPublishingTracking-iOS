//
//  ArtemisID.swift
//  RingPublishingTracking
//
//  Created by Adam Mordavsky on 15.11.23.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Artemis ID wrapper
struct ArtemisID: Codable {

    let artemis: String

    let external: ArtemisExternal
}
