//
//  StaticStorage.swift
//  AppTrackingTests
//
//  Created by Artur Rymarz on 21/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct StaticStorage: TrackingStorage {

    var eaUuid: EaUuid?
    var trackingIds: [String: IdsWithLifetime]?
    var postInterval: Int?
}
