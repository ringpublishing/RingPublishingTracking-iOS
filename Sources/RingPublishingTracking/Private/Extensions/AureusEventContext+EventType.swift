//
//  AureusEventContext+EventType.swift
//  RingPublishingTrackingTests
//
//  Created by Adam Szeremeta on 08/08/2025.
//  Copyright © 2025 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension AureusEventContext {

    var shouldUseLegacyReporting: Bool {
        let legacyEventTypes = ["AUREUS_IMPRESSION_EVENT_AND_USER_ACTION", "USER_ACTION"]

        return legacyEventTypes.contains(impressionEventType.uppercased())
    }
}
