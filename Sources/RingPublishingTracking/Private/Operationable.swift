//
//  Operationable.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 29/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

protocol Operationable {

    var debugEnabled: Bool { get }
    var optOutEnabled: Bool { get }
}

extension Operationable {
    var canSendNetworkRequests: Bool {
        !debugEnabled && !optOutEnabled
    }
}
