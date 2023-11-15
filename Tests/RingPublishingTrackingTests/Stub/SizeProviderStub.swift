//
//  SizeProviderStub.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 07/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import CoreGraphics

struct SizeProviderStub: SizeProviding {

    let screenSize: CGSize = .init(width: 375, height: 812)
    let applicationSize: CGSize = .init(width: 390, height: 844)
}
