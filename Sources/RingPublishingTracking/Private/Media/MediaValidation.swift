//
//  MediaValidation.swift
//  RingPublishingTracking
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Validation of MediaEvent values. A violation is only logged, the event is still sent.
enum MediaValidation {

    static func text(_ value: String?, field: String, method: String, min: Int = 0, max: Int) {
        guard let value = value else { return }

        let length = value.unicodeScalars.count
        guard length < min || length > max else { return }

        warn(method, "'\(field)' has \(length) characters, allowed: \(min)...\(max)")
    }

    static func nonNegative(_ value: Double?, field: String, method: String) {
        guard let value = value, value.isFinite, !(value >= 0) else { return }

        warn(method, "'\(field)' is \(value), must be at least 0")
    }

    static func playbackRate(_ value: Double?, method: String) {
        guard let value = value, value.isFinite, !(value >= 0 && value <= 16) else { return }

        warn(method, "'playback_rate' is \(value), allowed: 0...16")
    }

    /// JSON cannot carry NaN or infinity. Returns nil (and logs) for such a value, the value itself otherwise.
    static func finite(_ value: Double?, field: String, method: String) -> Double? {
        guard let value = value, !value.isFinite else { return value }

        Logger.log("[MediaEvent] \(method): '\(field)' must be a finite number, got \(value)", level: .default)
        return nil
    }

    /// Like `finite`, but a non-finite value is replaced by `substitute()` instead of nil.
    static func finite(_ value: Double, field: String, method: String, substitute: () -> Double) -> Double {
        return finite(value, field: field, method: method) ?? substitute()
    }

    static func warn(_ method: String, _ message: String) {
        Logger.log("[MediaEvent] \(method): \(message). The value is used as is.", level: .default)
    }

    static func ignored(_ method: String, reason: String) {
        Logger.log("[MediaEvent] \(method) ignored: \(reason)", level: .debug)
    }
}
