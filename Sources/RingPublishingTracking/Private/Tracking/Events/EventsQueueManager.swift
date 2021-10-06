//
//  EventsQueueManager.swift
//  RingPublishingTrackingTests
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
    private(set) var events = AtomicArray<DecoratedEvent>()

    /// Last time the events has been sent to the server
    private var lastSentDate = Date(timeIntervalSince1970: TimeInterval(0))

    /// Timer
    private var timer: Timer?

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
}

extension EventsQueueManager {

    /// Adds list of events to the queue when the size of each event is appropriate
    /// - Parameter events: Array of `Event` that should be added to the queue
    func addEvents(_ events: [DecoratedEvent]) {
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

        return Date() > lastSentDate.addingTimeInterval(TimeInterval(interval / 1000))
    }

    /// Sets the last sent date for events to the current date and time
    func updateLastSendDate() {
        lastSentDate = Date()
    }
}

extension EventsQueueManager {

    /// Adds single event to the queue when the size is appropriate
    /// - Parameter event: `Event` that should be added to the queue
    private func addEvent(_ event: DecoratedEvent) {
        let eventSize = event.sizeInBytes

        guard eventSize <= Constants.eventSizeLimit else {
            Logger.log("Event's size exceeded size limit", level: .error)
            return
        }

        events.append(event)
    }

    /// Sends events to backend if possible
    private func sendEventsIfPossible() {
        guard canSendEvents() else {
            scheduleTimer()
            return
        }

        delegate?.eventsQueueBecameReadyToSendEvents(self)
    }

    /// Scheduled new timer if there is noone running currently
    private func scheduleTimer() {
        guard let postInterval = storage.postInterval else {
            Logger.log("Cannot schedule timer as there is no postInterval available yet")
            return
        }

        Logger.log("SDK is not ready to send events yet. Scheduling a timer with interval \(postInterval).")

        guard timer == nil else {
            Logger.log("Timer is already scheduled.")
            return
        }

        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(postInterval / 1000), repeats: false) { [weak self] _ in
            self?.invalidateTimer()
            self?.sendEventsIfPossible()
        }
    }

    /// Invalidates scheduled timer
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}
