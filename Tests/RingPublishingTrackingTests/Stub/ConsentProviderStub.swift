//
//  ConsentProviderStub.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 07/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

@testable import RingPublishingTracking
import Foundation

struct ConsentProviderStub: ConsentProviding {

    let tcfv2: String? = "test"
}
