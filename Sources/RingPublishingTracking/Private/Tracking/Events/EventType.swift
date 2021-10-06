//
//  EventType.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 01/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Event Type
enum EventType: CaseIterable {
    case pageView
    case click
    case userAction
    case keepAlive
    case generic
}
