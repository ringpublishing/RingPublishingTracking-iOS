//
//  EventsQueueManager.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 15/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Manager for managing events that should be added to the queue and then send
final class EventsQueueManager {

    /// Delegate
    weak var delegate: EventsQueueManagerDelegate?

    /// Concurrent events array
    private(set) var events = AtomicArray<Event>()

    /// Guards `lastSentDate` and `timer`. Both are used from the main thread and from the completion queue of a send request.
    private let stateLock = NSLock()

    /// Last time the events has been sent to the server
    private var lastSentDate = Date(timeIntervalSince1970: TimeInterval(0))

    /// Delayed send. It fires on the main queue whichever thread schedules it, unlike a run loop `Timer`,
    /// which never fires when scheduled from the completion queue of a request.
    private var timer: DispatchSourceTimer?

    /// Storage
    private let storage: TrackingStorage

    /// Operation mode
    private let operationMode: Operationable

    /// Initialization
    /// - Parameter storage: tracking peristant storage
    init(storage: TrackingStorage, operationMode: Operationable) {
        self.storage = storage
        self.operationMode = operationMode
    }

    deinit {
        timer?.cancel()
    }
}

extension EventsQueueManager {

    /// Adds list of events to the queue when the size of each event is appropriate
    /// - Parameter events: Array of `Event` that should be added to the queue
    func addEvents(_ events: [Event]) {
        guard !operationMode.optOutEnabled else {
            Logger.log("Opt-Out mode is enabled. Ignoring \(events.count) new events.")
            return
        }

        for event in events {
            addEvent(event)
        }

        sendEventsIfPossible()
    }

    /// Checks if enough time has passed since the last time events were sent
    /// - Returns: `Bool` true - if sending events is allowed
    func canSendEvents() -> Bool {
        guard let interval = storage.postInterval else {
            return false
        }

        let intervalInSeconds = TimeInterval(Double(interval) / Double(1000))

        stateLock.lock()
        defer { stateLock.unlock() }

        return Date() > lastSentDate.addingTimeInterval(intervalInSeconds)
    }

    /// Sets the last sent date for events to the current date and time
    func updateLastSendDate() {
        stateLock.lock()
        lastSentDate = Date()
        stateLock.unlock()
    }
}

extension EventsQueueManager {

    /// Adds single event to the queue when the size is appropriate
    /// - Parameter event: `Event` that should be added to the queue
    private func addEvent(_ event: Event) {
        let eventSize = event.sizeInBytes

        guard eventSize <= Constants.eventSizeLimit else {
            Logger.log("Event's size exceeded size limit. Adding error event instead.", level: .error)
            delegate?.eventsQueueFailedToAddEvent(self, event: event)
            return
        }

        events.append(event)
    }

    /// Sends events to backend if possible
    func sendEventsIfPossible() {
        guard operationMode.canSendNetworkRequests else {
            Logger.log("Opt-out/Debug mode is enabled. Ignoring network request.")
            return
        }

        guard !events.allElements.isEmpty else {
            return
        }

        guard canSendEvents() else {
            scheduleTimer()
            return
        }

        updateLastSendDate()
        delegate?.eventsQueueBecameReadyToSendEvents(self)
    }

    /// Scheduled new timer if there is noone running currently
    private func scheduleTimer() {
        guard let interval = storage.postInterval else {
            Logger.log("Cannot schedule timer as there is no postInterval available yet")
            delegate?.eventsQueueFailedToScheduleTimer(self)
            return
        }

        let intervalInSeconds = TimeInterval(Double(interval) / Double(1000))

        stateLock.lock()
        let isTimerScheduled = timer != nil
        if !isTimerScheduled {
            timer = makeTimer(firingAfter: intervalInSeconds)
        }
        stateLock.unlock()

        guard !isTimerScheduled else {
            Logger.log("Timer is already scheduled.")
            return
        }

        Logger.log("SDK is not ready to send events yet. Scheduling a timer with interval \(intervalInSeconds)s.")
    }

    /// Makes a one-shot timer which clears itself and sends the queued events on the main queue
    private func makeTimer(firingAfter interval: TimeInterval) -> DispatchSourceTimer {
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.setEventHandler { [weak self] in
            self?.invalidateTimer()
            self?.sendEventsIfPossible()
        }
        timer.schedule(deadline: .now() + interval, repeating: .never)
        timer.activate()

        return timer
    }

    /// Invalidates scheduled timer
    private func invalidateTimer() {
        stateLock.lock()
        timer?.cancel()
        timer = nil
        stateLock.unlock()
    }
}
