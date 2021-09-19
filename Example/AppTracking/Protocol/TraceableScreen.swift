//
//  TraceableScreen.swift
//  AppTracking-Example
//
//  Created by Adam Szeremeta on 19/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import AppTracking

protocol TraceableScreen {

    var screenTrackingData: ScreenTrackingData { get }

    func updateTrackingProperties()
}

extension TraceableScreen {

    func updateTrackingProperties() {
        AppTracking.shared.updateApplicationStructurePath(currentStructurePath: screenTrackingData.structurePath)
        AppTracking.shared.updateApplicationAdvertisementArea(currentAdvertisementArea: screenTrackingData.advertisementArea)
    }
}
