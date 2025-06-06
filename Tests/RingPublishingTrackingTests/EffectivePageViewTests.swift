//
//  EffectivePageViewTests.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 06/06/2025.
//  Copyright © 2025 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class EffectivePageViewTests: XCTestCase {

    let keepAliveManager = KeepAliveManager()

    // swiftlint:disable force_unwrapping
    let contentMetadata = ContentMetadata(publicationId: "12345",
                                          publicationUrl: URL(string: "https://example.com/article?id=1234")!,
                                          sourceSystemName: "name",
                                          contentPartIndex: 1,
                                          paidContent: true,
                                          contentId: "6789")
    // swiftlint:enable force_unwrapping

    // MARK: Tests

    func testEPageView_contentProvidedScrolledToTopWith5SecFocusTime_noEPageViewEventCreated() {
        let dataSourceStub = EPVKeepAliveDataSourceStub()
        let managerDelegateMock = EPVKeepAliveManagerDelegateMock()

        managerDelegateMock.delegate = dataSourceStub
        keepAliveManager.delegate = managerDelegateMock

        keepAliveManager.start(for: contentMetadata, contentKeepAliveDataSource: dataSourceStub, partiallyReloaded: false)
        dataSourceStub.scrollContentOneScreenDown()
        wait(for: 5)
        keepAliveManager.stop()

        let eventsCount = managerDelegateMock.events.count

        XCTAssertEqual(eventsCount, 0, "Effective page view event should't be created")
    }

    func testEPageView_contentProvidedScrolledToTopWith5SecFocusTime_onlyOnePageViewEventCreated() {
        let dataSourceStub = EPVKeepAliveDataSourceStub()
        let managerDelegateMock = EPVKeepAliveManagerDelegateMock()

        managerDelegateMock.delegate = dataSourceStub
        keepAliveManager.delegate = managerDelegateMock

        keepAliveManager.start(for: contentMetadata, contentKeepAliveDataSource: dataSourceStub, partiallyReloaded: false)
        dataSourceStub.scrollContentTwoScreensDown()
        wait(for: 5)
        keepAliveManager.stop()

        let eventsCount = managerDelegateMock.events.count

        XCTAssertEqual(eventsCount, 1, "Only one effective page view event should be created")
    }

    func testEPageView_contentProvidedScrolledTwoScreensDownWith5SecFocusTime_EPageViewEventCreated() {
        let dataSourceStub = EPVKeepAliveDataSourceStub()
        let managerDelegateMock = EPVKeepAliveManagerDelegateMock()

        managerDelegateMock.delegate = dataSourceStub
        keepAliveManager.delegate = managerDelegateMock

        keepAliveManager.start(for: contentMetadata, contentKeepAliveDataSource: dataSourceStub, partiallyReloaded: false)
        dataSourceStub.scrollContentTwoScreensDown()
        wait(for: 5)
        keepAliveManager.stop()

        guard let event = managerDelegateMock.events.first else {
            XCTAssert(false, "Only one effective page view event should be created")
            return
        }

        let params = event.eventParameters

        XCTAssertEqual(params["ES"], "scroll", "ES parameter should be equal to 'scroll'")
        XCTAssertEqual(params["RS"], "scrl", "RS parameter should be equal to 'scrl'")
    }

    func testEPageView_contentProvidedScrolledOneScreenDownThanPlayPressedDuring5SecondFocus_playEventCreatedWithCorrectMeasurements() {
        let dataSourceStub = EPVKeepAliveDataSourceStub()
        let managerDelegateMock = EPVKeepAliveManagerDelegateMock()

        managerDelegateMock.delegate = dataSourceStub
        keepAliveManager.delegate = managerDelegateMock

        keepAliveManager.start(for: contentMetadata, contentKeepAliveDataSource: dataSourceStub, partiallyReloaded: false)

        dataSourceStub.scrollContentOneScreenDown()

        wait(for: 3)

        // Get last content measurement from keep alive manager and simulate play button pressed
        let metaData = EffectivePageViewMetadata(componentSource: .audio,
                                                 triggerSource: .play,
                                                 measurement: keepAliveManager.lastMeasurement ?? .zero)

        guard let event = managerDelegateMock.eventsFactory.createEffectivePageViewEvent(contentIdentifier: contentMetadata.contentId,
                                                                                   contentMetadata: contentMetadata,
                                                                                         metaData: metaData) else {
            XCTAssert(false, "Effective page view event couldn't be send on play button pressed. Other event was sent earlier.")
            return
        }

        wait(for: 2)

        keepAliveManager.stop()

        let params = event.eventParameters

        XCTAssertEqual(params["ST"], 800, "Content offset should be set to 800 (one screen down)")
        XCTAssertEqual(params["ES"], "audio", "ES parameter should be equal to 'audio'")
        XCTAssertEqual(params["RS"], "play", "RS parameter should be equal to 'play'")
    }

    func testEPageView_contentProvidedScrolledTwoScreensDownThanPlayPressedDuring5SecondFocus_scrollEventCreatedWithCorrectMeasurements() {
        let dataSourceStub = EPVKeepAliveDataSourceStub()
        let managerDelegateMock = EPVKeepAliveManagerDelegateMock()

        managerDelegateMock.delegate = dataSourceStub
        keepAliveManager.delegate = managerDelegateMock

        keepAliveManager.start(for: contentMetadata, contentKeepAliveDataSource: dataSourceStub, partiallyReloaded: false)

        dataSourceStub.scrollContentTwoScreensDown()

        wait(for: 3)

        // Get last content measurement from keep alive manager and simulate play button pressed
        let metaData = EffectivePageViewMetadata(componentSource: .audio,
                                                 triggerSource: .play,
                                                 measurement: keepAliveManager.lastMeasurement ?? .zero)

        if managerDelegateMock.eventsFactory.createEffectivePageViewEvent(contentIdentifier: contentMetadata.contentId,
                                                                          contentMetadata: contentMetadata,
                                                                          metaData: metaData) != nil {
            XCTAssert(false, "Effective page view event for audio play should not be created. Scroll event should be created before it.")
            return
        }

        wait(for: 2)

        keepAliveManager.stop()

        guard let event = managerDelegateMock.events.first else {
            XCTAssert(false, "Effective page view event for scroll was not created.")
            return
        }

        let params = event.eventParameters

        XCTAssertEqual(params["ST"], 1600, "Content offset should be set to 800 (one screen down)")
        XCTAssertEqual(params["ES"], "scroll", "ES parameter should be equal to 'scroll'")
        XCTAssertEqual(params["RS"], "scrl", "RS parameter should be equal to 'scrl'")
    }

    func testEPageView_contentProvidedWithOnetChatSource_eventParametersSetCorrectly() {
        let eventsFactory = EventsFactory()

        let measurement = KeepAliveContentStatus(scrollOffset: 0,
                                                 contentSize: .init(width: 375, height: 2000),
                                                 screenSize: .init(width: 375, height: 800))

        let metaData = EffectivePageViewMetadata(componentSource: .onetchat, triggerSource: .summary, measurement: measurement)

        guard let event = eventsFactory.createEffectivePageViewEvent(contentIdentifier: "1",
                                                               contentMetadata: contentMetadata,
                                                                     metaData: metaData) else {
            XCTAssert(false, "Effective page view event couldn't be send on OnetChat usage. Other event was sent earlier.")
            return
        }

        let params = event.eventParameters

        XCTAssertEqual(params["ES"], "onetchat", "ES parameter should be equal to 'onetchat'")
        XCTAssertEqual(params["RS"], "summary", "RS parameter should be equal to 'summary'")
    }
}
