//
//  BodableError.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 20/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Error used for issues with encoding `Bodable` to data
enum BodableError: Error {

    case incorrectBody
}
