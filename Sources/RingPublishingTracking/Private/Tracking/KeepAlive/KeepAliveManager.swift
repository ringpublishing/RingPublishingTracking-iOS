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
    private var keepAliveMeasureType: [KeepAliveMeasureType] = []

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

        scheduleMeasurementTimer()
        scheduleSendingTimer()
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
        keepAliveMeasureType.removeAll()

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
        Logger.log("Keep alive manager: Application did become active")

        backgroundTimeEnd.append(Date())

        takeMeasurements(measureType: .documentActive)
    }

    @objc
    private func applicationWillResignActive() {
        Logger.log("Keep alive manager: Application will resign active")

        backgroundTimeStart.append(Date())

        takeMeasurements(measureType: .documentInactive)
    }
}

extension KeepAliveManager {

    private func scheduleMeasurementTimer() {
        guard let timeFromStart = timeFromStart else {
            stop()
            return
        }

        let interval = intervalsProvider.nextIntervalForContentMetaActivityTracking(for: timeFromStart)

        Logger.log("Keep alive manager: scheduling measurement timer \(interval)s")

        measurementTimer = DispatchSource.scheduledBackgroundTimer(timeInterval: interval, action: { [weak self] in
            self?.takeMeasurements(measureType: .activityTimer)
        })
    }

    private func scheduleSendingTimer() {
        guard let timeFromStart = timeFromStart else {
            stop()
            return
        }

        let interval = intervalsProvider.nextIntervalForContentMetaActivitySending(for: timeFromStart)

        Logger.log("Keep alive manager: scheduling sending timer \(interval)s")

        sendingTimer = DispatchSource.scheduledBackgroundTimer(timeInterval: interval, action: { [weak self] in
            self?.takeMeasurements(measureType: .sendTimer)
            self?.sendMeasurements()
        })
    }

    private func takeMeasurements(measureType: KeepAliveMeasureType) {
        Logger.log("Keep alive manager: taking measurements")

        guard let timeFromStart = timeFromStart else {
            stop()
            return
        }

        guard let delegate = delegate else {
            Logger.log("Keep alive manager: delegate needs to be set", level: .fault)
            stop()
            return
        }

        guard let contentMetadata = contentMetadata else {
            Logger.log("ContentMetadata should be set when starting the keep alive event", level: .fault)
            return
        }

        guard let contentKeepAliveDataSource = contentKeepAliveDataSource else {
            Logger.log("ContentKeepAliveDataSource should be set when starting the keep alive event", level: .fault)
            return
        }

        // Take measurements
        let status = delegate.keepAliveManager(self,
                                               contentKeepAliveDataSource: contentKeepAliveDataSource,
                                               didAskForKeepAliveContentStatus: contentMetadata)

        timings.append(Int(timeFromStart))
        hasFocus.append(1)
        keepAliveContentStatus.append(status)
        keepAliveMeasureType.append(measureType)

        // Schedule next timer
        scheduleMeasurementTimer()
    }

    private func sendMeasurements() {
        Logger.log("Keep alive manager: sending measurements")

        guard let contentMetadata = contentMetadata else {
            Logger.log("ContentMetadata should be set when starting the keep alive event", level: .fault)
            return
        }

        // Prepare metadata for keep alive event
        let keepAliveMetadata = KeepAliveMetadata(keepAliveContentStatus: keepAliveContentStatus,
                                                  timings: timings,
                                                  hasFocus: hasFocus,
                                                  keepAliveMeasureType: keepAliveMeasureType)

        delegate?.keepAliveEventShouldBeSent(self, metaData: keepAliveMetadata, contentMetadata: contentMetadata)

        // Schedule next timer
        scheduleSendingTimer()
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
