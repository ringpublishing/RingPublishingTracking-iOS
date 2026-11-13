//
//  MediaContent.swift
//  RingPublishingTracking
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// One piece of content (video, episode, advertisement) played in a `MediaSession`. Created by `MediaSession.createMediaContent(_:)`.
///
/// A call which is not allowed in the current state sends nothing and changes nothing.
///
/// A NaN or infinite `positionSec` is logged and replaced by the content position: the seek target while a seek with a target
/// is open, otherwise the last position this content sent, 0 if it sent none. A NaN or infinite `durationSec` is logged and sent as 0.
/// All methods can be called from any thread.
public final class MediaContent {

    enum Mode {
        case initialized, playing, paused, ended
    }

    private struct HeldResume {
        let userEngaged: Bool?
    }

    // MARK: Internal state (guarded by the session lock)

    var playback: MediaPlaybackState
    var mode = Mode.initialized

    private let session: MediaSession
    private var seeking = false
    private var seekTarget: Double?
    private var interruptedContent: MediaContent?
    private var heldResume: HeldResume?
    private var lastPosition = 0.0

    // MARK: Public properties

    /// True when the content is playing or paused and its session is active
    public var hasActiveContent: Bool {
        return session.locked { isIn(.playing, .paused) }
    }

    /// True between `seekStart` and `seekEnd`
    public var isSeeking: Bool {
        return session.locked { seeking }
    }

    // MARK: Init

    init(session: MediaSession, configuration: MediaContentConfiguration) {
        self.session = session
        self.playback = MediaPlaybackState(monetizationType: configuration.monetizationType,
                                           subscriptionTier: configuration.subscriptionTier)
    }

    // MARK: Public methods

    /// Starts the playback. Allowed when the content is not playing yet or has ended playing.
    /// Sends `MEDIA_PLAYING_START`.
    ///
    /// For an advertisement the playing content with the related media id is paused
    /// (`MEDIA_PAUSE` with reason `ad`) and resumed when the advertisement ends.
    ///
    /// - Parameter parameters: Start parameters
    public func playingStart(_ parameters: MediaPlayingStartParameters) {
        session.transact {
            guard isIn(.initialized) else { return ignored("playingStart") }

            let isAd = parameters.mediaContentType == .ad
            let relatedMediaId = isAd ? (parameters.relatedMediaId ?? session.activeContent?.playback.mediaId) : nil

            let durationSec = MediaValidation.finite(parameters.durationSec, field: "duration_sec", method: "playingStart") { 0 }
            let positionSec = position(parameters.positionSec, "playingStart")

            validate(parameters, durationSec: durationSec, relatedMediaId: relatedMediaId)

            mode = .playing

            if !isAd {
                playback.adId = nil
                playback.adCampaignId = nil
                playback.adCreativeId = nil
                playback.adSlot = nil
                playback.relatedMediaId = nil
            }

            playback.durationSec = durationSec
            playback.mediaContentType = parameters.mediaContentType
            playback.mediaId = parameters.mediaId
            playback.playbackIntent = parameters.playbackIntent
            playback.adId = parameters.adId
            playback.adCampaignId = parameters.adCampaignId
            playback.adCreativeId = parameters.adCreativeId
            playback.adSlot = parameters.adSlot
            playback.mediaContentSubtype = parameters.mediaContentSubtype
            playback.mediaPremium = parameters.mediaPremium
            playback.mediaTier = parameters.mediaTier
            playback.mediaVariant = parameters.mediaVariant
            playback.relatedMediaId = relatedMediaId
            session.state.muted = parameters.muted ?? session.state.muted
            playback.userEngaged = parameters.userEngaged ?? playback.userEngaged

            let related = session.contents.first {
                $0 !== self && $0.isIn(.playing, .paused) && relatedMediaId != nil && $0.playback.mediaId == relatedMediaId
            }

            if isAd, let related = related, related.pauseForAd() {
                interruptedContent = related
            }

            session.contents.append(self)
            session.activeContent = self

            send(.playingStart, positionSec: positionSec, startMode: parameters.startMode)
        }
    }

    /// Reports playback progress. Allowed while playing. Sends `MEDIA_PLAYING_PROGRESS`.
    ///
    /// - Parameters:
    ///   - positionSec: Playback position in seconds
    ///   - userEngaged: Whether the user is engaged. When nil the previous value is kept.
    public func playingProgress(positionSec: Double, userEngaged: Bool? = nil) {
        session.transact {
            guard isIn(.playing) else { return ignored("playingProgress") }

            playback.userEngaged = userEngaged ?? playback.userEngaged
            send(.playingProgress, positionSec: position(positionSec, "playingProgress"))
        }
    }

    /// Ends the playback. Allowed while playing or paused. Sends `MEDIA_PLAYING_END`.
    /// An open seek is closed first. The content can be started again with `playingStart(_:)`.
    ///
    /// - Parameters:
    ///   - positionSec: Playback position in seconds
    ///   - reason: Reason of ending the playback
    ///   - userEngaged: Whether the user is engaged. When nil the previous value is kept.
    public func playingEnd(positionSec: Double, reason: MediaPlaybackEndReason, userEngaged: Bool? = nil) {
        session.transact {
            guard isIn(.playing, .paused) else { return ignored("playingEnd") }

            dropPending()

            mode = .initialized
            playback.userEngaged = userEngaged ?? playback.userEngaged
            send(.playingEnd, positionSec: position(positionSec, "playingEnd"), playbackEndReason: reason)

            session.contents.removeAll { $0 === self }

            if session.activeContent === self {
                session.activeContent = interruptedContent.flatMap { $0.isIn(.playing, .paused) ? $0 : nil }
                session.activeContent?.resumeAtContentPosition()
            }

            interruptedContent = nil
        }
    }

    /// Pauses the playback. Allowed while playing. Sends `MEDIA_PAUSE`, also during a seek.
    /// A resume held by an open seek is dropped.
    ///
    /// - Parameters:
    ///   - positionSec: Playback position in seconds
    ///   - reason: Reason of pausing the playback
    ///   - userEngaged: Whether the user is engaged. When nil the previous value is kept.
    public func pause(positionSec: Double, reason: MediaPauseReason, userEngaged: Bool? = nil) {
        session.transact {
            heldResume = nil

            guard isIn(.playing) else { return ignored("pause") }

            emitPause(positionSec: position(positionSec, "pause"), reason: reason, userEngaged: userEngaged)
        }
    }

    /// Resumes the playback. Allowed while paused. Sends `MEDIA_RESUME`.
    /// During a seek the resume is held and sent right after `seekEnd`.
    ///
    /// - Parameters:
    ///   - positionSec: Playback position in seconds
    ///   - userEngaged: Whether the user is engaged. When nil the previous value is kept.
    public func resume(positionSec: Double, userEngaged: Bool? = nil) {
        session.transact {
            guard isIn(.paused) else { return ignored("resume") }

            if seeking {
                heldResume = HeldResume(userEngaged: userEngaged)
                return
            }

            emitResume(positionSec: position(positionSec, "resume"), userEngaged: userEngaged)
        }
    }

    /// Reports start of a seek. Allowed while playing or paused when no seek is open. Sends `MEDIA_SEEK_START`.
    ///
    /// - Parameters:
    ///   - positionSec: Position the seek starts from
    ///   - targetSec: Position the seek is heading to. Reported if the seek is closed before its end is reported.
    ///   - userEngaged: Whether the user is engaged. When nil the previous value is kept.
    public func seekStart(positionSec: Double, targetSec: Double? = nil, userEngaged: Bool? = nil) {
        session.transact {
            guard isIn(.playing, .paused), !seeking else { return ignored("seekStart") }

            let startPosition = position(positionSec, "seekStart")
            let target = MediaValidation.finite(targetSec, field: "target_sec", method: "seekStart")
            MediaValidation.nonNegative(target, field: "target_sec", method: "seekStart")

            seekTarget = target
            seeking = true
            playback.userEngaged = userEngaged ?? playback.userEngaged
            send(.seekStart, positionSec: startPosition)
        }
    }

    /// Reports end of a seek. Allowed while playing or paused, also without a seek start. Sends `MEDIA_SEEK_END`.
    /// A resume held during the seek is sent right after it.
    ///
    /// - Parameters:
    ///   - positionSec: Position the seek ended at
    ///   - userEngaged: Whether the user is engaged. When nil the previous value is kept.
    public func seekEnd(positionSec: Double, userEngaged: Bool? = nil) {
        session.transact {
            guard isIn(.playing, .paused) else { return ignored("seekEnd") }

            endSeek(positionSec: position(positionSec, "seekEnd"), userEngaged: userEngaged)
        }
    }

    /// Reports muting the player. Allowed while playing or paused. Sends `MEDIA_MUTE`, even if the player was already muted.
    ///
    /// - Parameters:
    ///   - positionSec: Playback position in seconds
    ///   - userEngaged: Whether the user is engaged. When nil it becomes false.
    public func mute(positionSec: Double, userEngaged: Bool? = nil) {
        setMuted(true, positionSec: positionSec, userEngaged: userEngaged, method: "mute")
    }

    /// Reports unmuting the player. Allowed while playing or paused. Sends `MEDIA_UNMUTE`, even if the player was not muted.
    ///
    /// - Parameters:
    ///   - positionSec: Playback position in seconds
    ///   - userEngaged: Whether the user is engaged. When nil it becomes true.
    public func unmute(positionSec: Double, userEngaged: Bool? = nil) {
        setMuted(false, positionSec: positionSec, userEngaged: userEngaged, method: "unmute")
    }

    /// Reports change of the audio output. Allowed while playing or paused. Sends `MEDIA_OUTPUT_CHANGE`.
    ///
    /// - Parameters:
    ///   - positionSec: Playback position in seconds
    ///   - audioOutput: New audio output
    ///   - userEngaged: Whether the user is engaged. When nil the previous value is kept.
    public func outputChange(positionSec: Double, audioOutput: MediaAudioOutput, userEngaged: Bool? = nil) {
        session.transact {
            guard isIn(.playing, .paused) else { return ignored("outputChange") }

            session.state.audioOutput = audioOutput
            playback.userEngaged = userEngaged ?? playback.userEngaged
            send(.outputChange, positionSec: position(positionSec, "outputChange"))
        }
    }

    /// Reports change of the player visibility. Allowed while playing or paused. Sends `MEDIA_VISIBILITY_CHANGE`.
    ///
    /// - Parameters:
    ///   - positionSec: Playback position in seconds
    ///   - visibilityState: New visibility of the player
    ///   - userEngaged: Whether the user is engaged. When nil the previous value is kept.
    public func visibilityChange(positionSec: Double, visibilityState: MediaVisibilityState, userEngaged: Bool? = nil) {
        session.transact {
            guard isIn(.playing, .paused) else { return ignored("visibilityChange") }

            session.state.visibilityState = visibilityState
            playback.userEngaged = userEngaged ?? playback.userEngaged
            send(.visibilityChange, positionSec: position(positionSec, "visibilityChange"))
        }
    }

    /// Reports a playback error. Allowed before playing, while playing or paused. Sends `MEDIA_ERROR`. The content state does not change.
    ///
    /// - Parameters:
    ///   - positionSec: Playback position in seconds
    ///   - code: Error code (1 to 8 characters)
    ///   - message: Error message (1 to 1024 characters)
    ///   - userEngaged: Whether the user is engaged. When nil the previous value is kept.
    public func error(positionSec: Double, code: String, message: String, userEngaged: Bool? = nil) {
        session.transact {
            guard isIn(.initialized, .playing, .paused) else { return ignored("error") }

            MediaValidation.text(code, field: "error_code", method: "error", min: 1, max: 8)
            MediaValidation.text(message, field: "error_message", method: "error", min: 1, max: 1024)

            playback.userEngaged = userEngaged ?? playback.userEngaged
            send(.error, positionSec: position(positionSec, "error"), errorCode: code, errorMessage: message)
        }
    }
}

// MARK: Internal (called with the session lock held)

extension MediaContent {

    /// Closes an open seek and drops a held resume. Used when the content or session ends.
    func dropPending() {
        heldResume = nil

        if seeking {
            endSeek(positionSec: nil, fallsBackToContentPosition: true, userEngaged: nil)
        }
    }
}

// MARK: Private

private extension MediaContent {

    /// Seek target while a seek with a target is open, the last sent position otherwise (0 before the first)
    var contentPosition: Double {
        return seekTarget ?? lastPosition
    }

    /// A non-finite position is replaced by the content position, so the event keeps the `position_sec` the schema requires.
    func position(_ value: Double, _ method: String) -> Double {
        return MediaValidation.finite(value, field: "position_sec", method: method) { contentPosition }
    }

    func isIn(_ modes: Mode...) -> Bool {
        return !session.ended && modes.contains(mode)
    }

    func ignored(_ method: String) {
        MediaValidation.ignored(method, reason: "not allowed in the current state (\(session.ended ? "session ended" : "\(mode)"))")
    }

    func send(_ type: MediaEventType,
              positionSec: Double? = nil,
              startMode: MediaStartMode? = nil,
              pauseReason: MediaPauseReason? = nil,
              playbackEndReason: MediaPlaybackEndReason? = nil,
              errorCode: String? = nil,
              errorMessage: String? = nil) {
        if let positionSec = positionSec {
            lastPosition = positionSec
        }

        session.send(type,
                     playback: self,
                     positionSec: positionSec,
                     startMode: startMode,
                     pauseReason: pauseReason,
                     playbackEndReason: playbackEndReason,
                     errorCode: errorCode,
                     errorMessage: errorMessage)
    }

    func emitPause(positionSec: Double?, reason: MediaPauseReason, userEngaged: Bool?) {
        mode = .paused
        playback.userEngaged = userEngaged ?? playback.userEngaged
        send(.pause, positionSec: positionSec, pauseReason: reason)
    }

    func emitResume(positionSec: Double?, userEngaged: Bool?) {
        guard isIn(.paused) else { return }

        mode = .playing
        session.activeContent = self
        playback.userEngaged = userEngaged ?? playback.userEngaged
        send(.resume, positionSec: positionSec)
    }

    func resumeAtContentPosition() {
        emitResume(positionSec: contentPosition, userEngaged: nil)
    }

    /// Pauses the content because an advertisement related to it starts. Returns true when a pause was sent.
    func pauseForAd() -> Bool {
        guard isIn(.playing) else { return false }

        emitPause(positionSec: contentPosition, reason: .ad, userEngaged: false)
        return true
    }

    /// Closes the seek. Without a position the seek target (or last position) is reported.
    func endSeek(positionSec: Double?, fallsBackToContentPosition: Bool = false, userEngaged: Bool?) {
        let position = fallsBackToContentPosition ? (positionSec ?? contentPosition) : positionSec

        seeking = false
        seekTarget = nil

        if isIn(.playing, .paused) {
            playback.userEngaged = userEngaged ?? playback.userEngaged
            send(.seekEnd, positionSec: position)
        }

        guard let held = heldResume else { return }

        heldResume = nil
        emitResume(positionSec: position, userEngaged: held.userEngaged)
    }

    func setMuted(_ muted: Bool, positionSec: Double, userEngaged: Bool?, method: String) {
        session.transact {
            guard isIn(.playing, .paused) else { return ignored(method) }

            session.state.muted = muted
            playback.userEngaged = userEngaged ?? !muted
            send(muted ? .mute : .unmute, positionSec: position(positionSec, method))
        }
    }

    func validate(_ parameters: MediaPlayingStartParameters, durationSec: Double?, relatedMediaId: String?) {
        let method = "playingStart"

        MediaValidation.text(parameters.mediaId, field: "media_id", method: method, min: 1, max: 36)
        MediaValidation.text(parameters.mediaVariant, field: "media_variant", method: method, max: 64)
        MediaValidation.text(parameters.adId, field: "ad_id", method: method, max: 36)
        MediaValidation.text(parameters.adCampaignId, field: "ad_campaign_id", method: method, max: 36)
        MediaValidation.text(parameters.adCreativeId, field: "ad_creative_id", method: method, max: 36)
        MediaValidation.text(relatedMediaId, field: "related_media_id", method: method, max: 36)
        MediaValidation.text(parameters.adSlot, field: "ad_slot", method: method, max: 128)
        MediaValidation.nonNegative(durationSec, field: "duration_sec", method: method)

        if parameters.mediaContentType == .ad {
            if parameters.mediaContentSubtype == nil {
                MediaValidation.warn(method, "'media_content_subtype' is missing for an advertisement")
            }

            if relatedMediaId == nil {
                MediaValidation.warn(method, "'related_media_id' is missing for an advertisement")
            }
        }
    }
}
