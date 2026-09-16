//
//  ManualNetworkSessionMock.swift
//  RingPublishingTrackingTests
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Network session mock that captures requests without completing them automatically.
/// Lets tests decide exactly when (and with what result) a given in-flight request finishes,
/// so overlapping requests can be simulated deterministically.
class ManualNetworkSessionMock: NetworkSession {

    private(set) var callCount = 0
    private var pendingCompletionHandlers: [(Data?, URLResponse?, Error?) -> Void] = []

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        callCount += 1
        pendingCompletionHandlers.append(completionHandler)
    }

    /// Completes the oldest still-pending request with the given result
    func completeOldestPendingRequest(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        guard !pendingCompletionHandlers.isEmpty else { return }

        let completionHandler = pendingCompletionHandlers.removeFirst()
        completionHandler(data, response, error)
    }
}
