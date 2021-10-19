//
//  KeepAliveTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 19/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class KeepAliveDataSourceMock: RingPublishingTrackingKeepAliveDataSource {
    func ringPublishingTracking(_ ringPublishingTracking: RingPublishingTracking,
                                didAskForKeepAliveContentStatus content: ContentMetadata) -> KeepAliveContentStatus {
        (scrollOffset: 0, contentSize: .init(width: 375, height: 1200))
    }
}

class KeepAliveManagerDelegateStub: KeepAliveManagerDelegate {
    func keepAliveManager(_ keepAliveManager: KeepAliveManager,
                          contentKeepAliveDataSource: RingPublishingTrackingKeepAliveDataSource,
                          didAskForKeepAliveContentStatus content: ContentMetadata) -> KeepAliveContentStatus {
        (scrollOffset: 0, contentSize: .init(width: 375, height: 1200))
    }

    private let eventsFactory = EventsFactory()

    private(set) var keepAliveMetaData: [KeepAliveMetadata] = []

    var measurementTypes: [KeepAliveMeasureType] {
        keepAliveMetaData.flatMap { $0.keepAliveMeasureType }
    }

    var measurementsCount: Int {
        keepAliveMetaData.reduce(0) { partialResult, metaData in
            metaData.keepAliveMeasureType.count + partialResult
        }
    }

    func keepAliveEventShouldBeSent(_ keepAliveManager: KeepAliveManager, metaData: KeepAliveMetadata, contentMetadata: ContentMetadata) {
        keepAliveMetaData.append(metaData)
    }
}

class KeepAliveTests: XCTestCase {

    let keepAliveManager = KeepAliveManager()

    // MARK: Setup

    override func setUp() {
        super.setUp()
    }

    // MARK: Tests

    func testCollectingMeasurements_sampleContentDataProvidedWith20SecFocusTime_properMeasurementsTaken() {
        // Given
        let dataSourceMock = KeepAliveDataSourceMock()
        let managerDelegateStub = KeepAliveManagerDelegateStub()

        keepAliveManager.delegate = managerDelegateStub

        let url = URL(string: "https://example.com/article?id=1234")! // swiftlint:disable:this force_unwrapping
        let contentData = ContentMetadata(publicationId: "12345",
                                          publicationUrl: url,
                                          sourceSystemName: "name",
                                          contentPartIndex: 1,
                                          contentWasPaidFor: true)

        // When
        keepAliveManager.start(for: contentData, contentKeepAliveDataSource: dataSourceMock)
        wait(for: 20) // 11 activity + 2 send
        keepAliveManager.stop()

        // Then
        let activityTimerMeasurements = managerDelegateStub.measurementTypes.filter { $0 == .activityTimer }
        let sendTimerMeasurements = managerDelegateStub.measurementTypes.filter { $0 == .sendTimer }

        XCTAssertEqual(managerDelegateStub.measurementsCount, 13, "13 measures should be taken")
        XCTAssertEqual(activityTimerMeasurements.count, 11, "11 activity timer measures should be taken")
        XCTAssertEqual(sendTimerMeasurements.count, 2, "2 send timer measures should be taken")

    }

    func testCollectingMeasurements_sampleContentDataProvidedWith10SecBackgroundTime_properMeasurementsTaken() {
        // Given
        let dataSourceMock = KeepAliveDataSourceMock()
        let managerDelegateStub = KeepAliveManagerDelegateStub()

        keepAliveManager.delegate = managerDelegateStub

        let url = URL(string: "https://example.com/article?id=1234")! // swiftlint:disable:this force_unwrapping
        let contentData = ContentMetadata(publicationId: "12345",
                                          publicationUrl: url,
                                          sourceSystemName: "name",
                                          contentPartIndex: 1,
                                          contentWasPaidFor: true)

        // When
        keepAliveManager.start(for: contentData, contentKeepAliveDataSource: dataSourceMock)
        wait(for: 4) // 3 activity
        NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil) // 1 inactive
        wait(for: 10) // 0 activity + send
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil) // 1 active
        wait(for: 6) // 1 send + 3 activity
        keepAliveManager.stop()

        // Then
        let activityTimerMeasurements = managerDelegateStub.measurementTypes.filter { $0 == .activityTimer }
        let sendTimerMeasurements = managerDelegateStub.measurementTypes.filter { $0 == .sendTimer }
        let inativeMeasurements = managerDelegateStub.measurementTypes.filter { $0 == .documentInactive }
        let activeMeasurements = managerDelegateStub.measurementTypes.filter { $0 == .documentActive }

        XCTAssertEqual(managerDelegateStub.measurementsCount, 9, "9 measures should be taken")
        XCTAssertEqual(activityTimerMeasurements.count, 6, "6 activity timer measures should be taken")
        XCTAssertEqual(sendTimerMeasurements.count, 1, "1 send timer measures should be taken")
        XCTAssertEqual(inativeMeasurements.count, 1, "1 document inactive measures should be taken")
        XCTAssertEqual(activeMeasurements.count, 1, "1 document active measures should be taken")
    }
}
