//
//  MetricsData.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Metric counter data
public struct MetricsData {

    /// Name of displayed metric counter
    let metricLimitName: String

    /// Number of views remaining within the metric counter
    let freePageViewCount: Int

    /// Number of free views within the metric counter
    let freePageViewLimit: Int

    public init(metricLimitName: String, freePageViewCount: Int, freePageViewLimit: Int) {
        self.metricLimitName = metricLimitName
        self.freePageViewCount = freePageViewCount
        self.freePageViewLimit = freePageViewLimit
    }
}
