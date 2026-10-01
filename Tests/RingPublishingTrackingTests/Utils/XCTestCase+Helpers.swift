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

    /// Decodes a base64 encoded JSON parameter value, e.g. `RDLCN`
    func decodedJSONParameter(_ value: AnyHashable?) throws -> [String: Any] {
        let base64 = try XCTUnwrap(value as? String)
        let data = try XCTUnwrap(Data(base64Encoded: base64))

        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }
}
