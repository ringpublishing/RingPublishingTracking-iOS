//
//  Bodable.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 17/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

protocol Bodable {

    func toBodyData() throws -> Data
}
