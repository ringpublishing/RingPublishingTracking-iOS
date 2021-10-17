//
//  DispatchSource+BackgroundTimer.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 17/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension DispatchSource {

    /// Schedule timer on background thread
    /// Action is called on main thread
    ///
    /// - Parameters:
    ///   - timeInterval: TimeInterval from now when timer should fire
    ///   - action: (() -> Void)? Action to execute when timer is fired
    static func scheduledBackgroundTimer(timeInterval: TimeInterval, action: (() -> Void)?) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer.schedule(deadline: .now() + timeInterval, repeating: .never)
        timer.setEventHandler { [weak timer] in
            guard !(timer?.isCancelled ?? false) else { return }

            DispatchQueue.main.async {
                action?()
            }
        }

        timer.resume()

        return timer
    }
}
