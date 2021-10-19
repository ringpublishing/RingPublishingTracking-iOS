//
//  KeepAliveMeasureType.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 15/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

enum KeepAliveMeasureType: String {

    case activityTimer = "T"
    case sendTimer = "S"
    case documentActive = "A"
    case documentInactive = "I"
    case error = "E"
}
