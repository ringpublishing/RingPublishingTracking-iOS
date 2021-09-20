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
        // When application changes currently displayed view, we should update it's current advertisement area
        // and structure path so each event send from this moment will be correctly assigned to this screen

        AppTracking.shared.updateApplicationStructurePath(currentStructurePath: screenTrackingData.structurePath)
        AppTracking.shared.updateApplicationAdvertisementArea(currentAdvertisementArea: screenTrackingData.advertisementArea)
    }
}
