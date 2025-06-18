//
//  ActionsViewController.swift
//  RingPublishingTracking-Example
//
//  Created by Adam Szeremeta on 17/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit
import RingPublishingTracking

class ActionsViewController: UIViewController, PagerViewController, TraceableScreen {

    private let detailSegueIdentifier = "DetailViewControllerSegue"

    private let sampleArticle = SampleArticle.testData[0]
    private var pageViewSource = ContentPageViewSource.default

    // MARK: PagerViewController

    var pageIndex: Int {
        return 1
    }

    // MARK: TraceableScreen

    var screenTrackingData: ScreenTrackingData {
        return ScreenTrackingData(structurePath: ["Home", "Actions"], advertisementArea: "ActionsAdsArea")
    }

    // MARK: Life cycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Update our tracking properties for this screen

        updateTrackingProperties()

        // Report page view event

        RingPublishingTracking.shared.reportPageView(currentStructurePath: screenTrackingData.structurePath, partiallyReloaded: false)
    }

    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        guard let detailController = segue.destination as? DetailViewController else { return }

        detailController.article = sampleArticle
        detailController.contentViewSource = pageViewSource
    }

    // MARK: Actions (Login + logout)

    @IBAction func onLoginActionTouch(_ sender: Any) {
        // When user log in we should update tracking module with his account information

        RingPublishingTracking.shared.updateUserData(userId: "12345",
                                                     userEmail: "demo@example.com")

        // Each non content button click we can report using 'reportClick' method

        reportButtonClickEvent(sender)
    }

    @IBAction func onLogoutActionTouch(_ sender: Any) {
        // When user log out from the application we should update tracking module

        RingPublishingTracking.shared.updateUserData(userId: nil,
                                                     userEmail: nil)

        // Each non content button click we can report using 'reportClick' method

        reportButtonClickEvent(sender)
    }

    // MARK: Actions (User action)

    @IBAction func onReportUserActionAsStringTouch(_ sender: Any) {
        // Each user action which you want to track can be reported with String parameters
        // This could be either plain string or encoded JSON prepared by your app

        let userActionPayload = "in_app_purchase_product=product1;value=20"
        RingPublishingTracking.shared.reportUserAction(actionName: "UserPurchase",
                                                       actionSubtypeName: "In-app purchase",
                                                       parameters: userActionPayload)

        // Each non content button click we can report using 'reportClick' method

        reportButtonClickEvent(sender)
    }

    @IBAction func onReportUserActionAsDictionaryTouch(_ sender: Any) {
        // Each user action which you want to track can be reported with Dictionary parameters
        // This will be encoded to JSON by RingPublishingTracking module

        let userActionPayload: [String: AnyHashable] = [
            "in_app_purchase_product": "product1",
            "value": 20
        ]
        RingPublishingTracking.shared.reportUserAction(actionName: "UserPurchase",
                                                       actionSubtypeName: "In-app purchase",
                                                       parameters: userActionPayload)

        // Each non content button click we can report using 'reportClick' method

        reportButtonClickEvent(sender)
    }

    // MARK: Actions (Detail)

    @IBAction func onDetailFromPushActionTouch(_ sender: Any) {
        // If you know in your application if your content was opened from push notification
        // (and not in usuall way directly from the app), you can pass that information to tracking module

        pageViewSource = ContentPageViewSource.pushNotifcation

        performSegue(withIdentifier: detailSegueIdentifier, sender: self)
    }

    @IBAction func onDetailFromSocialActionTouch(_ sender: Any) {
        // If you know in your application if your content was opened from social media, for example
        // using universal links (and not in usuall way directly from the app), you can pass that information to tracking module

        pageViewSource = ContentPageViewSource.socialMedia

        performSegue(withIdentifier: detailSegueIdentifier, sender: self)
    }

    // MARK: Actions (Generic event)

    @IBAction func onReportGenericEventActionTouch(_ sender: Any) {
        // If you have the need to report custom event (which is not defined in module interface) you can
        // always do that using generic 'reportEvent' method, but you must construct Event yourself and know
        // it's parameters

        let customEvent = Event(analyticsSystemName: "GENERIC",
                                eventName: "DemoCustomEvent",
                                eventParameters: ["myParam": "myValue"])
        RingPublishingTracking.shared.reportEvent(customEvent)
    }

    // MARK: Actions (Debug mode)

    @IBAction func onEnableDebugModeActionTouch(_ sender: Any) {
        // If you don't want to send events to API during development (or for some other reason) but you still want
        // to see events being processed by the SDK, you can enable debug mode

        RingPublishingTracking.shared.setDebugMode(enabled: true)
    }

    @IBAction func onDisableDebugModeActionTouch(_ sender: Any) {
        // You can always disable debug mode

        RingPublishingTracking.shared.setDebugMode(enabled: false)
    }

    // MARK: Actions (Opt-out mode)

    @IBAction func onEnableOptOutModeActionTouch(_ sender: Any) {
        // If you don't want to send events to API and also don't want to see events being processed by the SDK,
        // you can enable opt-out mode. In this mode, SDK functionality is disabled (events processing, logger, API calls)

        RingPublishingTracking.shared.setOptOutMode(enabled: true)
    }

    @IBAction func onDisableOptOutModeActionTouch(_ sender: Any) {
        // You can always disable opt-out mode

        RingPublishingTracking.shared.setOptOutMode(enabled: false)
    }

    // MARK: Actions (Aureus offers impression)

    @IBAction func onReportAureusOffersImpressionActionTouch(_ sender: Any) {
        // If you have recomendations delivered by personalization engine (Aureus) you should report
        // when those items are displayed to the user

        let offerIds = ["123", "456", "789"]
        RingPublishingTracking.shared.reportAureusOffersImpressions(offerIds: offerIds)
    }

    // MARK: Actions (Video event)

    @IBAction func onReportVideoPlaybackStartActionTouch(_ sender: Any) {
        // Here is the example how can you report video events
        // We are reporting here few events in order of which those should be reported in case, where video
        // material was started by the user manually

        let videoMetadata = VideoMetadata(publicationId: "2334518.275928614",
                                          contentId: "0394d662-b991-4451-bf28-24dc195ec2f0",
                                          isMainContentPiece: false,
                                          videoStreamFormat: .hls,
                                          videoDuration: 1267,
                                          videoContentCategory: .free,
                                          videoAdsConfiguration: .disabledByConfiguration,
                                          videoPlayerVersion: "3.5.0")
        let videoState = VideoState(currentTime: 0, currentBitrate: "4000.00", isMuted: true, visibility: .outOfViewport, startMode: .muted)

        RingPublishingTracking.shared.reportVideoEvent(.start, videoMetadata: videoMetadata, videoState: videoState)
        RingPublishingTracking.shared.reportVideoEvent(.playingStart, videoMetadata: videoMetadata, videoState: videoState)
        RingPublishingTracking.shared.reportVideoEvent(.keepPlaying, videoMetadata: videoMetadata, videoState: videoState)
    }

    @IBAction func onReportAudioStartActionTouch(_ sender: Any) {
        RingPublishingTracking.shared.reportAudioEvent(audioEvent: .start, audioMetadata: sampleAudioMetadata, audioState: sampleAudioState)
    }

    @IBAction func onReportAudioPlayingStartActionTouch(_ sender: Any) {
        RingPublishingTracking.shared.reportAudioEvent(audioEvent: .playingStart,
                                                       audioMetadata: sampleAudioMetadata,
                                                       audioState: sampleAudioState)
    }

    @IBAction func onReportAudioPlayingActionTouch(_ sender: Any) {
        RingPublishingTracking.shared.reportAudioEvent(audioEvent: .playing,
                                                       audioMetadata: sampleAudioMetadata,
                                                       audioState: sampleAudioState)
    }

    @IBAction func onReportAudioPausedActionTouch(_ sender: Any) {
        RingPublishingTracking.shared.reportAudioEvent(audioEvent: .paused,
                                                       audioMetadata: sampleAudioMetadata,
                                                       audioState: sampleAudioState)
    }

    @IBAction func onReportAudioKeepPlayingActionTouch(_ sender: Any) {
        RingPublishingTracking.shared.reportAudioEvent(audioEvent: .keepPlaying,
                                                       audioMetadata: sampleAudioMetadata,
                                                       audioState: sampleAudioState)
    }

    @IBAction func onReportAudioPlayingAutostartActionTouch(_ sender: Any) {
        RingPublishingTracking.shared.reportAudioEvent(audioEvent: .autoPlayingStart,
                                                       audioMetadata: sampleAudioMetadata,
                                                       audioState: sampleAudioState)
    }

    @IBAction func onReportAudioPlayingEndActionTouch(_ sender: Any) {
        RingPublishingTracking.shared.reportAudioEvent(audioEvent: .playingEnd,
                                                       audioMetadata: sampleAudioMetadata,
                                                       audioState: sampleAudioState)
    }

    @IBAction func onReportEffectivePageViewWithOnetChat(_ sender: Any) {
        RingPublishingTracking.shared.reportEffectivePageView(contentMetadata: sampleContentMetadata,
                                                              componentSource: "onetchat",
                                                              triggerSource: "summary")
    }
}

// MARK: Private
private extension ActionsViewController {

    var sampleAudioMetadata: AudioMetadata {
        AudioMetadata(contentId: "12167",
                      contentTitle: "Bartosz Kwolek: siatkówka nie jest całym moim życiem",
                      contentSeriesId: "67",
                      contentSeriesTitle: "W cieniu sportu",
                      mediaType: .podcast,
                      audioDuration: 3722,
                      audioStreamFormat: .mp3,
                      isContentFragment: false,
                      audioContentCategory: .free,
                      audioPlayerVersion: "1.0.0")
    }

    var sampleAudioState: AudioState {
        AudioState(currentTime: 10,
                   currentBitrate: 360,
                   visibilityState: .background,
                   audioOutput: .bluetooth)
    }

    // swiftlint:disable force_unwrapping

    var sampleContentMetadata: ContentMetadata {
        ContentMetadata(publicationId: "1234",
                        publicationUrl: URL(string: "http://onet.pl/article1")!,
                        sourceSystemName: "sourceSystemName",
                        paidContent: true,
                        contentId: "2345")
    }

    // swiftlint:enable force_unwrapping

    func reportButtonClickEvent(_ sender: Any) {
        // If our click action does not have a name, we can omit it
        let actionName = (sender as? UIButton)?.titleLabel?.text

        RingPublishingTracking.shared.reportClick(selectedElementName: actionName)
    }
}
