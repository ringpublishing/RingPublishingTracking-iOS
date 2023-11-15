//
//  VendorIdentifierProviderMock.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 07/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

@testable import RingPublishingTracking
import Foundation

class VendorIdentifierProviderMock: VendorIdentifiable {
    var identifierForVendor: UUID?

    func fillIdentifier() {
        identifierForVendor = UUID()
    }
}
