//
//  MediaSession.swift
//  RingPublishingTracking
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Session of a video, audio or TTS player. Reports `MediaEvent` through the SDK.
///
/// The session owns `media_session_id`, `event_ordinal`, state carried between events and the state machine of its contents.
/// All methods can be called from any thread. Call `end()` when the player is finished.
///
/// Events are created under the session lock, which fixes their order, and queued. After the lock is released the calling thread
/// delivers the queue to the SDK, unless another thread is already delivering. No SDK code runs while the lock is held, and a call
/// made while another thread delivers returns without waiting for that delivery.
public final class MediaSession {

    // MARK: Internal state (guarded by `lock`)

    let lock = NSRecursiveLock()
    var state: MediaSessionState
    var started = false
    var ended = false
    var activeContent: MediaContent?
    var lastPlayback: MediaContent?
    var contents = [MediaContent]()
    private var outbox = [Event]()
    private var delivering = false

    // MARK: Private properties

    private let id = UUID().uuidString.lowercased()
    private let eventsFactory: EventsFactory
    private let eventSink: (Event) -> Void

    // MARK: Public properties

    /// Unique id of the session (lowercase UUID v4, 36 characters), sent as `media_session_id`
    public var sessionId: String {
        return id
    }

    /// False after `end()` was called
    public var isActive: Bool {
        return locked { !ended }
    }

    /// Ordinal of the last sent event, 0 before the first one
    public var eventOrdinal: Int {
        return locked { state.eventOrdinal }
    }

    /// Whether the player is muted
    public var muted: Bool {
        return locked { state.muted }
    }

    /// Visibility of the player
    public var visibilityState: MediaVisibilityState {
        return locked { state.visibilityState }
    }

    /// Audio output used by the player
    public var audioOutput: MediaAudioOutput {
        return locked { state.audioOutput }
    }

    /// Playback rate (1.0 is normal speed)
    public var playbackRate: Double {
        return locked { state.playbackRate }
    }

    // MARK: Init

    /// Creates session which hands every event to `eventSink`. The public factory passes the SDK reporting path.
    init(mediaType: MediaType,
         playerVariant: String?,
         eventsFactory: EventsFactory = EventsFactory(),
         eventSink: @escaping (Event) -> Void) {
        MediaValidation.text(playerVariant, field: "player_variant", method: "createMediaSession", max: 64)

        self.state = MediaSessionState(mediaType: mediaType, playerVariant: playerVariant)
        self.eventsFactory = eventsFactory
        self.eventSink = eventSink
    }

    // MARK: Public methods

    /// Creates media content (for example one episode, video or advertisement) in this session.
    ///
    /// The first content of the session sends `MEDIA_SESSION_START`.
    /// Content created in an ended session does nothing.
    ///
    /// - Parameter configuration: Content configuration
    /// - Returns: Media content
    public func createMediaContent(_ configuration: MediaContentConfiguration = MediaContentConfiguration()) -> MediaContent {
        return transact {
            let playbackRate = MediaValidation.finite(configuration.playbackRate, field: "playback_rate", method: "createMediaContent")

            state.audioOutput = configuration.audioOutput ?? state.audioOutput
            state.muted = configuration.muted ?? state.muted
            state.playbackRate = playbackRate ?? state.playbackRate
            state.visibilityState = configuration.visibilityState ?? state.visibilityState
            MediaValidation.playbackRate(playbackRate, method: "createMediaContent")

            let content = MediaContent(session: self, configuration: configuration)

            if !started && !ended {
                started = true
                send(.sessionStart, playback: content)
            }

            return content
        }
    }

    /// Sets the playback rate sent with the following events. Sends no event.
    /// Does nothing when the session has ended.
    ///
    /// - Parameter playbackRate: Playback rate (1.0 is normal speed)
    public func updatePlaybackRate(_ playbackRate: Double) {
        transact {
            guard !ended else {
                MediaValidation.ignored("updatePlaybackRate", reason: "session has ended")
                return
            }

            guard let rate = MediaValidation.finite(playbackRate, field: "playback_rate", method: "updatePlaybackRate") else { return }

            MediaValidation.playbackRate(rate, method: "updatePlaybackRate")
            state.playbackRate = rate
        }
    }

    /// Ends the session. Open seeks are closed, then `MEDIA_SESSION_END` is sent if the session had started.
    /// Calling it again does nothing.
    public func end() {
        transact {
            guard !ended else {
                MediaValidation.ignored("end", reason: "session has ended")
                return
            }

            contents.forEach { $0.dropPending() }

            ended = true
            activeContent = nil
            contents.forEach { $0.mode = .ended }
            contents.removeAll()

            if started {
                send(.sessionEnd, playback: lastPlayback)
            }

            // Content keeps a reference to the session, so the cycle is cut here
            lastPlayback = nil
        }
    }

    // MARK: Internal methods

    func locked<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }

        return body()
    }

    /// Runs `body` under the lock, then delivers the queued events to the sink outside of it.
    /// Only one thread delivers at a time, so the sink receives events in ordinal order. A sink calling back into
    /// the session only queues, the running delivery loop sends it.
    func transact<T>(_ body: () -> T) -> T {
        let result = locked(body)
        deliver()

        return result
    }

    private func deliver() {
        let claimed: Bool = locked {
            guard !delivering, !outbox.isEmpty else { return false }

            delivering = true
            return true
        }

        guard claimed else { return }

        while true {
            let batch: [Event] = locked {
                guard !outbox.isEmpty else {
                    delivering = false
                    return []
                }

                defer { outbox.removeAll() }
                return outbox
            }

            guard !batch.isEmpty else { return }

            batch.forEach(eventSink)
        }
    }

    /// Increments the ordinal and queues the event for delivery. Has to be called with the lock held,
    /// which keeps events in ordinal order.
    func send(_ type: MediaEventType,
              playback: MediaContent?,
              positionSec: Double? = nil,
              startMode: MediaStartMode? = nil,
              pauseReason: MediaPauseReason? = nil,
              playbackEndReason: MediaPlaybackEndReason? = nil,
              errorCode: String? = nil,
              errorMessage: String? = nil) {
        lastPlayback = playback ?? lastPlayback
        state.eventOrdinal += 1

        let fields = MediaEventFields(type: type,
                                      sessionId: id,
                                      session: state,
                                      playback: playback?.playback,
                                      positionSec: positionSec,
                                      startMode: startMode,
                                      pauseReason: pauseReason,
                                      playbackEndReason: playbackEndReason,
                                      errorCode: errorCode,
                                      errorMessage: errorMessage)
        MediaValidation.nonNegative(positionSec, field: "position_sec", method: type.rawValue)

        outbox.append(eventsFactory.createMediaEvent(fields: fields))
    }
}
