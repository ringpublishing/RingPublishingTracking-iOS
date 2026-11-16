//
//  MediaIdentifierPin.swift
//  RingPublishingTracking
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// `IP` and `IV` of the screen where a content started playing.
///
/// The `MEDIA_PLAYING_START` event of the content stores the identifiers it was decorated with. Later events of the content
/// get them instead of the current ones, so the pipeline sees a single playback while the user moves between screens.
/// Read and written only while events are decorated, never by the session, so it takes no part in the session lock.
final class MediaIdentifierPin: Equatable {

    private static let keys: Set<String> = ["IP", "IV"]

    private let lock = NSLock()
    private var pinned = [String: AnyHashable]()

    var identifiers: [String: AnyHashable] {
        lock.lock()
        defer { lock.unlock() }

        return pinned
    }

    func pin(_ parameters: [String: AnyHashable]) {
        lock.lock()
        defer { lock.unlock() }

        pinned = parameters.filter { Self.keys.contains($0.key) }
    }

    static func == (lhs: MediaIdentifierPin, rhs: MediaIdentifierPin) -> Bool {
        return lhs === rhs
    }
}
