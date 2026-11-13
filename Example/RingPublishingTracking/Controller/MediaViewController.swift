//
//  MediaViewController.swift
//  RingPublishingTracking-Example
//
//  Copyright © 2026 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit
import RingPublishingTracking

/// Shows how to report MediaEvent through a media session. Each button plays one scripted scenario.
class MediaViewController: UIViewController, PagerViewController, TraceableScreen {

    // MARK: PagerViewController

    var pageIndex: Int {
        return 3
    }

    // MARK: TraceableScreen

    var screenTrackingData: ScreenTrackingData {
        return ScreenTrackingData(structurePath: ["Home", "Media"],
                                  advertisementArea: "MediaAdsArea",
                                  advertisementSite: "demo_media_ios")
    }

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        let audioButton = makeButton(title: "Run audio scenario",
                                     identifier: "media_run_audio_scenario",
                                     action: #selector(onRunAudioScenario))
        let videoButton = makeButton(title: "Run video scenario",
                                     identifier: "media_run_video_scenario",
                                     action: #selector(onRunVideoScenario))

        let stack = UIStackView(arrangedSubviews: [audioButton, videoButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateTrackingProperties()

        RingPublishingTracking.shared.reportPageView(currentStructurePath: screenTrackingData.structurePath, partiallyReloaded: false)
    }

    // MARK: Actions

    @objc
    func onRunAudioScenario() {
        // One session per player. The session owns media_session_id and event_ordinal.

        let session = RingPublishingTracking.shared.createMediaSession(mediaType: .audio, playerVariant: "main")

        // The first content created in the session sends MEDIA_SESSION_START

        let first = session.createMediaContent(MediaContentConfiguration(monetizationType: .subscription,
                                                                         muted: false,
                                                                         visibilityState: .background,
                                                                         playbackRate: 1.5,
                                                                         audioOutput: .bluetooth))
        first.playingStart(MediaPlayingStartParameters(mediaId: "a1", durationSec: 1800, mediaContentType: .main,
                                                       playbackIntent: .userInitiated, positionSec: 0, mediaVariant: "mp3",
                                                       userEngaged: true))
        first.playingProgress(positionSec: 15)
        first.pause(positionSec: 42, reason: .userAction)
        first.playingProgress(positionSec: 43) // Ignored, the content is paused
        first.seekStart(positionSec: 42, targetSec: 100)
        first.resume(positionSec: 42) // Held until the seek ends
        first.seekEnd(positionSec: 100) // Sends MEDIA_SEEK_END, then the held MEDIA_RESUME
        first.outputChange(positionSec: 110, audioOutput: .car)
        first.playingEnd(positionSec: 1800, reason: .naturalCompletion)
        first.pause(positionSec: 1800, reason: .userAction) // Ignored, the content has ended

        let second = session.createMediaContent(MediaContentConfiguration(monetizationType: .free))
        second.playingStart(MediaPlayingStartParameters(mediaId: "a2", durationSec: 600, mediaContentType: .main,
                                                        playbackIntent: .continuation, positionSec: 0))
        second.visibilityChange(positionSec: 5, visibilityState: .visible)
        second.error(positionSec: 6, code: "E42", message: "decoder failure")

        session.end()
    }

    @objc
    func onRunVideoScenario() {
        let session = RingPublishingTracking.shared.createMediaSession(mediaType: .video, playerVariant: "inline")

        let main = session.createMediaContent(MediaContentConfiguration(monetizationType: .free))
        main.playingStart(MediaPlayingStartParameters(mediaId: "v1", durationSec: 120, mediaContentType: .main,
                                                      playbackIntent: .autoplay, positionSec: 0, startMode: .mutedStart))
        main.unmute(positionSec: 3)

        // An advertisement pauses the related main content and resumes it when the advertisement ends

        let advert = session.createMediaContent()
        advert.playingStart(MediaPlayingStartParameters(mediaId: "ad1", durationSec: 10, mediaContentType: .ad,
                                                        playbackIntent: .autoplay, positionSec: 0, mediaContentSubtype: .midroll,
                                                        adCampaignId: "camp1"))
        advert.playingEnd(positionSec: 10, reason: .naturalCompletion)

        main.seekEnd(positionSec: 30)
        main.mute(positionSec: 31)
        main.playingEnd(positionSec: 120, reason: .userStopped)
        main.playingStart(MediaPlayingStartParameters(mediaId: "v1", durationSec: 120, mediaContentType: .main,
                                                      playbackIntent: .userInitiated, positionSec: 0))
        main.seekStart(positionSec: 50, targetSec: 80)
        main.seekStart(positionSec: 55) // Ignored, a seek is already open

        // Ending the session closes the open seek and sends MEDIA_SESSION_END

        session.end()
    }
}

// MARK: Private
private extension MediaViewController {

    func makeButton(title: String, identifier: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.accessibilityIdentifier = identifier
        button.addTarget(self, action: action, for: .touchUpInside)

        return button
    }
}
