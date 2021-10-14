//
//  KeepAliveManager.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 13/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

// TODO: MOVE
protocol KeepAliveManagerDelegate: AnyObject {

    func keepAliveEventShouldBeSent(_ keepAliveManager: KeepAliveManager)
}

final class KeepAliveManager {
    weak var delegate: KeepAliveManagerDelegate?

    private let intervalsProvider = KeepAliveIntervalsProvider()

    func pause() {

    }

    func resume() {

    }

    func stop() {
        
    }
}
