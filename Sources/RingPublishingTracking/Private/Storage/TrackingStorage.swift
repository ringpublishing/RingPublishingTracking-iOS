//
//  TrackingStorage.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 16/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Protocol for persistent storage for data that is used for network requests
protocol TrackingStorage {

    var eaUUID: EaUUID? { get set }
    var artemisID: ArtemisIdentifier? { get set }
    var trackingIds: [String: IdsWithLifetime]? { get set }
    var postInterval: Int? { get set }
    var randomUniqueDeviceId: String? { get set }
}
