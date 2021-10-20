//
//  DispatchQueue+BackgroundTimer.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 17/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension DispatchQueue {

    /// Schedule timer on background thread
    /// Action is called on main thread
    ///
    /// - Parameters:
    ///   - timeInterval: TimeInterval from now when timer should fire
    ///   - action: (() -> Void)? Action to execute when timer is fired
    static func scheduledTimer(timeInterval: TimeInterval, action: (() -> Void)?) -> Timer {
        let timer = Timer(timeInterval: timeInterval, repeats: false) { timer in
            guard timer.isValid else { return }

            DispatchQueue.main.async {
                action?()
            }
        }

        DispatchQueue.global(qos: .background).async {
            let runLoop = RunLoop.current
            runLoop.add(timer, forMode: .common)
            runLoop.run()
        }

        return timer
    }
}
