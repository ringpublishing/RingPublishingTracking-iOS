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

    /// Requests may be made from the main thread while a test completes others on a background thread
    private let lock = NSLock()
    private var _callCount = 0
    private var _requests: [URLRequest] = []
    private var pendingCompletionHandlers: [(Data?, URLResponse?, Error?) -> Void] = []

    var callCount: Int {
        lock.lock()
        defer { lock.unlock() }

        return _callCount
    }

    var requests: [URLRequest] {
        lock.lock()
        defer { lock.unlock() }

        return _requests
    }

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        lock.lock()
        _callCount += 1
        _requests.append(request)
        pendingCompletionHandlers.append(completionHandler)
        lock.unlock()
    }

    /// Completes the oldest still-pending request with the given result
    func completeOldestPendingRequest(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        lock.lock()
        guard !pendingCompletionHandlers.isEmpty else {
            lock.unlock()
            return
        }

        let completionHandler = pendingCompletionHandlers.removeFirst()
        lock.unlock()

        completionHandler(data, response, error)
    }
}
