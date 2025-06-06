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
        switch elapsedTime {
        case 0..<15:
            let steps: [TimeInterval] = [1, 2, 3, 4, 5, 6, 8, 10, 12, 14]

            // Return first interval bigger then current time elapsed
            guard let interval = steps.first(where: { $0 > elapsedTime }) else {
                fallthrough
            }

            print("[BB] nextInterval: \(interval) - \(elapsedTime) = \(interval - elapsedTime)")
            return interval - elapsedTime

        case 15..<50:
            // Next interval after 3s
            return 3

        default:
            // Next interval after 8s
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
