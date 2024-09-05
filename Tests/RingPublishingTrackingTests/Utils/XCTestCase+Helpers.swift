//
//  XCTestCase+Helpers.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 28/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

extension XCTestCase {

    func wait(for seconds: TimeInterval) {
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for \(seconds) seconds")], timeout: seconds)
    }
}
