//
//  UserManagerTests.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 11/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

@testable import RingPublishingTracking
import Foundation
import XCTest

class UserManagerTests: XCTestCase {

    // MARK: - UserManager Tests

    func testBuildUser_idfaAndDeviceIdAreProvided_builtUserContainsAllData() {
        // Given
        let userManager = UserManager()
        let idfa = UUID()
        let deviceId = "1234567890"
        let tcfv2 = "abcdefghijklmn"

        // When
        userManager.updateIDFA(idfa: idfa)
        userManager.updateDeviceId(deviceId: deviceId)
        userManager.updateTCFV2(tcfv2: tcfv2)

        let user = userManager.buildUser()

        // Then
        XCTAssertEqual(user.advertisementId, idfa.uuidString, "Advertisement Identifier should be equal to IDFA")
        XCTAssertEqual(user.deviceId, deviceId, "Device Identifier should be equal to user device identifier")
        XCTAssertEqual(user.tcfv2, tcfv2, "TCF string should be correctly set")
    }

    func testBuildUser_deviceIdIsProvided_builtUserContainsAllData() {
        // Given
        let userManager = UserManager()
        let deviceId = "1234567890"

        // When
        userManager.updateDeviceId(deviceId: deviceId)

        let user = userManager.buildUser()

        // Then
        XCTAssertNil(user.advertisementId, "Advertisement Identifier should be nil")
        XCTAssertEqual(user.deviceId, deviceId, "Device Identifier should be correct")
    }

    func testBuildUser_noIdentifiersAreProvided_builtUserContainsNoData() {
        // Given
        let userManager = UserManager()

        // When
        let user = userManager.buildUser()

        // Then
        XCTAssertNil(user.advertisementId, "Advertisement Identifier should be nil")
        XCTAssertNil(user.deviceId, "Device Identifier should be nil")
    }
}
