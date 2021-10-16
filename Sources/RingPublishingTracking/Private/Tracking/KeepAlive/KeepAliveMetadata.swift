//
//  KeepAliveMetadata.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 15/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct KeepAliveMetadata {

    let keepAliveContentStatus: [KeepAliveContentStatus]
    let timings: [Int]
    let hasFocus: [Int]
    let keepAliveMesureType: [KeepAliveMesureType]
}
