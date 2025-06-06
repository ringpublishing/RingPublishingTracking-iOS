//
//  KeepAliveIntervalsProvider.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 13/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class KeepAliveIntervalsProvider {

    func nextIntervalForContentMetaActivityTracking(for elapsedTime: TimeInterval) -> TimeInterval {
        // How many seconds after tracking was started
        let elapsedTime = elapsedTime.rounded(.toNearestOrAwayFromZero)

        switch elapsedTime {
        case 0..<6:
            return 1

        case 6..<15:
            return 2

        case 15..<50:
            return 3

        default:
            return 8
        }
    }

    func nextIntervalForContentMetaActivitySending(for elapsedTime: TimeInterval) -> TimeInterval {
        // How many seconds after tracking was started
        switch elapsedTime {
        case 0..<200:
            let pseudoFibonacci: [TimeInterval] = [5, 10, 20, 30, 60, 100, 140, 184]

            // Return first interval bigger then current time elapsed
            guard let interval = pseudoFibonacci.first(where: { $0 > elapsedTime }) else {
                fallthrough
            }

            return interval - elapsedTime

        case 200..<900:
            // Next interval after 60s
            return 60

        default:
            // Next interval after 300s
            return 300
        }
    }

}
