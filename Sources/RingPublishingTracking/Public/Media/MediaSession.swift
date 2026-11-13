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
public final class MediaSession {

    // MARK: Internal state (guarded by `lock`)

    let lock = NSRecursiveLock()
    var state: MediaSessionState
    var started = false
    var ended = false
    var activeContent: MediaContent?
    var lastPlayback: MediaContent?
    var contents = [MediaContent]()

    // MARK: Private properties

    private let id = UUID().uuidString
    private let eventsFactory: EventsFactory
    private let eventSink: (Event) -> Void

    // MARK: Public properties

    /// Unique id of the session (UUID v4, 36 characters), sent as `media_session_id`
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
        return locked {
            state.audioOutput = configuration.audioOutput ?? state.audioOutput
            state.muted = configuration.muted ?? state.muted
            state.playbackRate = configuration.playbackRate ?? state.playbackRate
            state.visibilityState = configuration.visibilityState ?? state.visibilityState
            MediaValidation.playbackRate(configuration.playbackRate, method: "createMediaContent")

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
        locked {
            guard !ended else {
                MediaValidation.ignored("updatePlaybackRate", reason: "session has ended")
                return
            }

            MediaValidation.playbackRate(playbackRate, method: "updatePlaybackRate")
            state.playbackRate = playbackRate
        }
    }

    /// Ends the session. Open seeks are closed, then `MEDIA_SESSION_END` is sent if the session had started.
    /// Calling it again does nothing.
    public func end() {
        locked {
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

    /// Increments the ordinal and hands the event to the sink. Has to be called with the lock held,
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

        eventSink(eventsFactory.createMediaEvent(fields: fields))
    }
}
