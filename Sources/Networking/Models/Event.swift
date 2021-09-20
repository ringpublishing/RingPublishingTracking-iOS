//
//  Event.swift
//  AppTrackingTests
//
//  Created by Artur Rymarz on 15/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct Event {

    let analyticsSystemName: String
    let eventName: String
    let eventParameters: [String: AnyHashable]
}
