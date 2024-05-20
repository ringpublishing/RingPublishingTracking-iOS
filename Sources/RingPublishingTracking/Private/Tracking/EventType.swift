//
//  EventType.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 08/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

enum EventType: String {

    case click = "ClkEvent"
    case userAction = "UserAction"
    case pageView = "PageView"
    case keepAlive = "KeepAlive"
    case videoEvent = "VidEvent"
    case error = "ErrEvent"
}
