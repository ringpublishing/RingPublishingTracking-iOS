//
//  KeepAliveManager.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 13/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit.UIApplication

final class KeepAliveManager {

    /// Delegate
    weak var delegate: KeepAliveManagerDelegate?

    /// Data source for keep alive data
    private weak var contentKeepAliveDataSource: RingPublishingTrackingKeepAliveDataSource?

    /// Intervals Provider
    private let intervalsProvider = KeepAliveIntervalsProvider()

    /// Collected data
    private var keepAliveContentStatus: [KeepAliveContentStatus] = []
    private var timings: [Int] = []
    private var hasFocus: [Int] = []
    private var keepAliveMesureType: [KeepAliveMesureType] = []

    private var contentMetadata: ContentMetadata?

    /// Timers
    private var trackingStartDate: Date?

    private var backgroundTimeStart = [Date]()
    private var backgroundTimeEnd = [Date]()

    private var pauseTimeStart = [Date]()
    private var pauseTimeEnd = [Date]()

    private var measurementTimer: DispatchSourceTimer?
    private var sendingTimer: DispatchSourceTimer?

    private var timeFromStart: TimeInterval? {
        guard let date = trackingStartDate else { return nil }

        // Remove time spent in background
        var backgroundTime: TimeInterval = 0
        zip(backgroundTimeStart, backgroundTimeEnd).forEach { dates in
            backgroundTime += abs(dates.0.timeIntervalSince(dates.1))
        }

        // Remove time spent on pause
        var pauseTime: TimeInterval = 0
        zip(pauseTimeStart, pauseTimeEnd).forEach { dates in
            pauseTime += abs(dates.0.timeIntervalSince(dates.1))
        }

        let absoluteTime = abs(date.timeIntervalSinceNow)
        var elapsedTime = absoluteTime - backgroundTime - pauseTime

        // Round to Int
        elapsedTime.round(.towardZero)

        return elapsedTime
    }

    // MARK: -

    func start(for contentMetadata: ContentMetadata) {
        stopTimers()
        clearCollectedData()

        self.contentMetadata = contentMetadata

        trackingStartDate = Date()
    }

    func pause() {
        pauseTimeStart.append(Date())
    }

    func resume() {
        pauseTimeEnd.append(Date())
    }

    func stop() {
        stopTimers()
        clearCollectedData()

        trackingStartDate = nil
    }

    func setupContentKeepAliveDataSource(contentKeepAliveDataSource: RingPublishingTrackingKeepAliveDataSource) {
        self.contentKeepAliveDataSource = contentKeepAliveDataSource
    }

    private func clearCollectedData() {
        keepAliveContentStatus.removeAll()
        timings.removeAll()
        hasFocus.removeAll()
        keepAliveMesureType.removeAll()

        contentMetadata = nil
    }

    private func stopTimers() {
        measurementTimer?.cancel()
        measurementTimer = nil

        sendingTimer?.cancel()
        sendingTimer = nil

        backgroundTimeStart.removeAll()
        backgroundTimeEnd.removeAll()

        pauseTimeStart.removeAll()
        pauseTimeEnd.removeAll()
    }
}

extension KeepAliveManager {

    // MARK: Observers

    func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func applicationDidBecomeActive() {
//        Logger.appLogger?.log("FocusManager: Application did become active")
//
//        focusManager?.applicationDidBecomeActive()
//        keepAliveManager?.applicationDidBecomeActive()
        backgroundTimeEnd.append(Date())
    }

    @objc
    private func applicationWillResignActive() {
//        Logger.appLogger?.log("FocusManager: Application will resign active")
//
//        focusManager?.applicationWillResignActive()
//        keepAliveManager?.applicationWillResignActive()
        backgroundTimeStart.append(Date())
    }
}

extension KeepAliveManager {

    private func scheduleMeasurementTimer() {
        guard let timeFromStart = timeFromStart  else {
//            stopTrackingContentFocus()
            return
        }

        let interval = intervalsProvider.nextIntervalForContentMetaActivityTracking(for: timeFromStart)
        measurementTimer = DispatchSource.scheduledBackgroundTimer(timeInterval: interval, action: { [weak self] in
            self?.takeMeasurements()
        })
    }

    private func scheduleSendingTimer() {
        guard let timeFromStart = timeFromStart  else {
//            stopTrackingContentFocus()
            return
        }

        let interval = intervalsProvider.nextIntervalForContentMetaActivitySending(for: timeFromStart)

        sendingTimer = DispatchSource.scheduledBackgroundTimer(timeInterval: interval, action: { [weak self] in
            self?.sendMeasurements()
        })
    }

    private func takeMeasurements() {

    }

    private func sendMeasurements() {
        guard let contentMetadata = contentMetadata else {
            Logger.log("ContentMetadata should be set when starting the Keep Alive Event", level: .fault)
            return
        }

        let keepAliveMetadata = KeepAliveMetadata(keepAliveContentStatus: keepAliveContentStatus,
                                                  timings: timings,
                                                  hasFocus: hasFocus,
                                                  keepAliveMesureType: keepAliveMesureType)

        delegate?.keepAliveEventShouldBeSent(self, metaData: keepAliveMetadata, contentMetadata: contentMetadata)
    }
}

// TODO: ???
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
