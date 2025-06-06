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
    private var isPaused: Bool = false

    private var trackingStartDate: Date?
    private var measurementIntervalSum: TimeInterval = 0
    var lastMeasurement: KeepAliveContentStatus?

    private var backgroundTimeStart = [Date]()
    private var backgroundTimeEnd = [Date]()

    private var pauseTimeStart = [Date]()
    private var pauseTimeEnd = [Date]()

    private let timerQueue = DispatchQueue(label: "timerQueue", attributes: .concurrent)
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

    private var areMeasurementsTaken: Bool {
        !keepAliveContentStatus.isEmpty
    }

    private var hasStarted: Bool {
        contentMetadata != nil
    }

    // MARK: - Lifecycle

    init() {
        addObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: -

    func start(for contentMetadata: ContentMetadata,
               contentKeepAliveDataSource: RingPublishingTrackingKeepAliveDataSource,
               partiallyReloaded: Bool) {
        if partiallyReloaded, self.contentMetadata == contentMetadata {
            self.contentKeepAliveDataSource = contentKeepAliveDataSource
            resume()
            return
        }

        sendMeasurements()

        stopTimers()
        clearTimes()
        clearCollectedData()

        self.contentKeepAliveDataSource = contentKeepAliveDataSource
        self.contentMetadata = contentMetadata

        trackingStartDate = Date()
        isPaused = false

        scheduleMeasurementTimer()
        scheduleSendingTimer()
    }

    func pause() {
        guard hasStarted, !isPaused else { return }

        pauseTimeStart.append(Date())

        stopTimers()
        isPaused = true
    }

    func resume() {
        guard hasStarted, isPaused else { return }

        pauseTimeEnd.append(Date())

        isPaused = false
        scheduleMeasurementTimer()
        scheduleSendingTimer()
    }

    func stop() {
        if areMeasurementsTaken && contentMetadata != nil {
            sendMeasurements()
        }

        stopTimers()
        clearTimes()
        clearCollectedData()

        isPaused = false
        trackingStartDate = nil
        contentMetadata = nil
        contentKeepAliveDataSource = nil
    }

    private func clearCollectedData() {
        keepAliveContentStatus.removeAll()
        timings.removeAll()
        hasFocus.removeAll()
        keepAliveMeasureType.removeAll()
    }

    private func stopTimers() {
        measurementTimer?.cancel()
        measurementTimer = nil

        sendingTimer?.cancel()
        sendingTimer = nil
    }

    private func clearTimes() {
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

    @objc
    private func applicationDidBecomeActive() {
        guard hasStarted, !isPaused else { return }

        Logger.log("Keep alive manager: Application did become active")

        backgroundTimeEnd.append(Date())

        takeMeasurements(measureType: .documentActive)

        scheduleMeasurementTimer()
        scheduleSendingTimer()
    }

    @objc
    private func applicationWillResignActive() {
        guard hasStarted, !isPaused else { return }

        Logger.log("Keep alive manager: Application will resign active")

        stopTimers()
        backgroundTimeStart.append(Date())

        takeMeasurements(measureType: .documentInactive)
    }
}

extension KeepAliveManager {

    /// Schedule timer on dedicated concurrent queue
    /// Action is called on main thread
    ///
    /// - Parameters:
    ///   - timeInterval: TimeInterval from now when timer should fire
    ///   - action: (() -> Void)? Action to execute when timer is fired
    func scheduledTimer(timeInterval: TimeInterval, action: (() -> Void)?) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(queue: timerQueue)
        timer.setEventHandler {
            DispatchQueue.main.async {
                action?()
            }
        }
        timer.schedule(deadline: .now() + timeInterval, repeating: .never)
        timer.activate()

        return timer
    }

    private func scheduleMeasurementTimer() {
        guard let timeFromStart = timeFromStart else {
            stop()
            return
        }

        let interval = intervalsProvider.nextIntervalForContentMetaActivityTracking(for: timeFromStart)

        measurementTimer = scheduledTimer(timeInterval: 1, action: { [weak self] in
            guard let self = self else { return }

            self.takeMeasurements(measureType: .activityTimer, nextMeasurementIntervalSum: self.measurementIntervalSum + interval)
            self.scheduleMeasurementTimer()
        })
    }

    private func scheduleSendingTimer() {
        guard let timeFromStart = timeFromStart else {
            stop()
            return
        }

        let interval = intervalsProvider.nextIntervalForContentMetaActivitySending(for: timeFromStart)

        Logger.log("Keep alive manager: Scheduling sending timer \(interval)s")

        sendingTimer = scheduledTimer(timeInterval: interval, action: { [weak self] in
            self?.takeMeasurements(measureType: .sendTimer)
            self?.sendMeasurements()
            self?.scheduleSendingTimer()
        })
    }

    private func takeMeasurements(measureType: KeepAliveMeasureType, nextMeasurementIntervalSum: TimeInterval? = nil) {
        guard
            let timeFromStart = timeFromStart,
            let contentKeepAliveDataSource = contentKeepAliveDataSource,
            let contentMetadata = contentMetadata
        else {
            Logger.log("Keep alive manager is missing required data to work properly.", level: .fault)

            stop()
            return
        }

        guard let delegate = delegate else {
            Logger.log("Keep alive manager is missing a delegate. Make sure it's been set.", level: .fault)

            addMeasurement(timing: Int(timeFromStart), status: .zero, measureType: .error)
            stop()
            return
        }

        // Take measurements
        lastMeasurement = delegate.keepAliveManager(self,
                                                    contentKeepAliveDataSource: contentKeepAliveDataSource,
                                                    didAskForKeepAliveContentStatus: contentMetadata)

        let now = Date()

        guard let lastMeasurement = lastMeasurement else { return }

        // Update current measurement every second
        delegate.keepAliveManager(self, didTakeMeasurement: lastMeasurement, for: contentMetadata)

        // If nextMeasurementIntervalSum is set it means call is from keepAlive timer
        if let nextMeasurementIntervalSum = nextMeasurementIntervalSum {
            // Check with intervals if it is a time to store measurements for page view event
            guard timeFromStart >= nextMeasurementIntervalSum else { return }

            self.measurementIntervalSum = nextMeasurementIntervalSum
        }

        addMeasurement(timing: Int(timeFromStart), status: lastMeasurement, measureType: measureType)
    }

    private func addMeasurement(timing: Int, status: KeepAliveContentStatus, measureType: KeepAliveMeasureType) {
        Logger.log("Keep alive manager: Storing measurements for type \(measureType.rawValue), time: \(timing)s")
        timings.append(timing)
        hasFocus.append(1)
        keepAliveContentStatus.append(status)
        keepAliveMeasureType.append(measureType)
    }

    private func sendMeasurements() {
        guard areMeasurementsTaken else {
            Logger.log("Keep alive manager: Nothing to send. There is no any measurements taken yet.")

            // Schedule next timer
            scheduleSendingTimer()

            return
        }

        Logger.log("Keep alive manager: Sending measurements")

        guard let contentMetadata = contentMetadata else {
            Logger.log("ContentMetadata should be set when starting the keep alive event", level: .fault)
            stop()
            return
        }

        // Prepare metadata for keep alive event
        let keepAliveMetadata = KeepAliveMetadata(keepAliveContentStatus: keepAliveContentStatus,
                                                  timings: timings,
                                                  hasFocus: hasFocus,
                                                  keepAliveMeasureType: keepAliveMeasureType)

        delegate?.keepAliveEventShouldBeSent(self, metaData: keepAliveMetadata, contentMetadata: contentMetadata)
        clearCollectedData()
    }
}
