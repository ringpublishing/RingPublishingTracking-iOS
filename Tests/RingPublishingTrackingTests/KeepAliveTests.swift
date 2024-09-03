//
//  KeepAliveTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 19/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import XCTest

class KeepAliveTests: XCTestCase {

    let keepAliveManager = KeepAliveManager()

    // MARK: Tests

    func testCollectingMeasurements_sampleContentDataProvidedWith20SecFocusTime_properMeasurementsTaken() {
        // Given
        let dataSourceStub = KeepAliveDataSourceStub()
        let managerDelegateMock = KeepAliveManagerDelegateMock()

        keepAliveManager.delegate = managerDelegateMock

        let url = URL(string: "https://example.com/article?id=1234")! // swiftlint:disable:this force_unwrapping
        let contentData = ContentMetadata(publicationId: "12345",
                                          publicationUrl: url,
                                          sourceSystemName: "name",
                                          contentPartIndex: 1,
                                          paidContent: true,
                                          contentId: "6789")

        // When
        keepAliveManager.start(for: contentData, contentKeepAliveDataSource: dataSourceStub, partiallyReloaded: false)
        wait(for: 19) // 11 activity + 2 send
        keepAliveManager.stop()

        // Then
        let activityTimerMeasurements = managerDelegateMock.measurementTypes.filter { $0 == .activityTimer }
        let sendTimerMeasurements = managerDelegateMock.measurementTypes.filter { $0 == .sendTimer }

        XCTAssertEqual(managerDelegateMock.measurementsCount, 13, "13 measures should be taken")
        XCTAssertEqual(activityTimerMeasurements.count, 11, "11 activity timer measures should be taken")
        XCTAssertEqual(sendTimerMeasurements.count, 2, "2 send timer measures should be taken")
    }

    func testCollectingMeasurements_sampleContentDataProvidedWith10SecBackgroundTime_properMeasurementsTaken() {
        // Given
        let dataSourceStub = KeepAliveDataSourceStub()
        let managerDelegateMock = KeepAliveManagerDelegateMock()

        keepAliveManager.delegate = managerDelegateMock

        let url = URL(string: "https://example.com/article?id=1234")! // swiftlint:disable:this force_unwrapping
        let contentData = ContentMetadata(publicationId: "12345",
                                          publicationUrl: url,
                                          sourceSystemName: "name",
                                          contentPartIndex: 1,
                                          paidContent: true,
                                          contentId: "6789")

        // When
        keepAliveManager.start(for: contentData, contentKeepAliveDataSource: dataSourceStub, partiallyReloaded: false)
        wait(for: 4) // 3 activity
        NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil) // 1 inactive
        wait(for: 10) // 0 activity + send
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil) // 1 active
        wait(for: 5) // 1 send + 3 activity
        keepAliveManager.stop()

        // Then
        let activityTimerMeasurements = managerDelegateMock.measurementTypes.filter { $0 == .activityTimer }
        let sendTimerMeasurements = managerDelegateMock.measurementTypes.filter { $0 == .sendTimer }
        let inativeMeasurements = managerDelegateMock.measurementTypes.filter { $0 == .documentInactive }
        let activeMeasurements = managerDelegateMock.measurementTypes.filter { $0 == .documentActive }

        XCTAssertEqual(managerDelegateMock.measurementsCount, 9, "9 measures should be taken")
        XCTAssertEqual(activityTimerMeasurements.count, 6, "6 activity timer measures should be taken")
        XCTAssertEqual(sendTimerMeasurements.count, 1, "1 send timer measures should be taken")
        XCTAssertEqual(inativeMeasurements.count, 1, "1 document inactive measures should be taken")
        XCTAssertEqual(activeMeasurements.count, 1, "1 document active measures should be taken")
    }

    func testCollectingMeasurements_sampleContentDataProvidedWith10SecondsPausedTime_properMeasurementsTaken() {
        // Given
        let dataSourceStub = KeepAliveDataSourceStub()
        let managerDelegateMock = KeepAliveManagerDelegateMock()

        keepAliveManager.delegate = managerDelegateMock

        let url = URL(string: "https://example.com/article?id=1234")! // swiftlint:disable:this force_unwrapping
        let contentData = ContentMetadata(publicationId: "12345",
                                          publicationUrl: url,
                                          sourceSystemName: "name",
                                          contentPartIndex: 1,
                                          paidContent: true,
                                          contentId: "6789")

        // When
        keepAliveManager.start(for: contentData, contentKeepAliveDataSource: dataSourceStub, partiallyReloaded: false)
        wait(for: 4) // 3 activity
        keepAliveManager.pause()
        wait(for: 10) // 0 activity + send
        keepAliveManager.resume()
        wait(for: 5) // 1 send + 3 activity
        keepAliveManager.stop()

        // Then
        let activityTimerMeasurements = managerDelegateMock.measurementTypes.filter { $0 == .activityTimer }
        let sendTimerMeasurements = managerDelegateMock.measurementTypes.filter { $0 == .sendTimer }
        let inativeMeasurements = managerDelegateMock.measurementTypes.filter { $0 == .documentInactive }
        let activeMeasurements = managerDelegateMock.measurementTypes.filter { $0 == .documentActive }

        XCTAssertEqual(managerDelegateMock.measurementsCount, 7, "7 measures should be taken")
        XCTAssertEqual(activityTimerMeasurements.count, 6, "6 activity timer measures should be taken")
        XCTAssertEqual(sendTimerMeasurements.count, 1, "1 send timer measures should be taken")
        XCTAssertEqual(inativeMeasurements.count, 0, "0 document inactive measures should be taken")
        XCTAssertEqual(activeMeasurements.count, 0, "0 document active measures should be taken")
    }

    func testCreateKeepAliveEvent_contentMetaDataWithUnpaidContentProvided_returnedEventHasRDLCN() {
        // Given
        let factory = EventsFactory()

        let contentMetadata = ContentMetadata(publicationId: "12345",
                                              publicationUrl: URL(fileURLWithPath: "path"),
                                              sourceSystemName: "system_name",
                                              paidContent: false,
                                              contentId: "6789")
        let keepAliveMetadata = KeepAliveMetadata(keepAliveContentStatus: [],
                                                  timings: [],
                                                  hasFocus: [],
                                                  keepAliveMeasureType: [])
        let rdlcnParam = "eyJwdWJsaWNhdGlvbiI6eyJwcmVtaXVtIjpmYWxzZX0sInNvdXJjZSI6eyJpZCI6IjY3ODkiLCJzeXN0ZW0iOiJzeXN0ZW1fbmFtZSJ9fQ=="

        // When
        let event = factory.createKeepAliveEvent(metaData: keepAliveMetadata, contentMetadata: contentMetadata)
        let params = event.eventParameters

        // Then
        XCTAssertEqual(params["RDLCN"], rdlcnParam, "RDLCN parameter should be in correct format")
    }

    func testCreateKeepAliveEvent_contentMetaDataWithPaidContentProvided_returnedEventHasRDLCN() {
        // Given
        let factory = EventsFactory()

        let contentMetadata = ContentMetadata(publicationId: "12345",
                                              publicationUrl: URL(fileURLWithPath: "path"),
                                              sourceSystemName: "system_name",
                                              paidContent: false,
                                              contentId: "6789")
        let keepAliveMetadata = KeepAliveMetadata(keepAliveContentStatus: [],
                                                  timings: [],
                                                  hasFocus: [],
                                                  keepAliveMeasureType: [])
        let rdlcnParam = "eyJwdWJsaWNhdGlvbiI6eyJwcmVtaXVtIjpmYWxzZX0sInNvdXJjZSI6eyJpZCI6IjY3ODkiLCJzeXN0ZW0iOiJzeXN0ZW1fbmFtZSJ9fQ=="

        // When
        let event = factory.createKeepAliveEvent(metaData: keepAliveMetadata, contentMetadata: contentMetadata)
        let params = event.eventParameters

        // Then
        XCTAssertEqual(params["RDLCN"], rdlcnParam, "RDLCN parameter should be in correct format")
    }
}
