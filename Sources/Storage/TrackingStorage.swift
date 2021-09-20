//
//  TrackingStorage.swift
//  AppTrackingTests
//
//  Created by Artur Rymarz on 16/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

protocol TrackingStorage {

    var trackingIds: [String: IdsWithLifetime]? { get set }
    var postInterval: Int? { get set }
}
