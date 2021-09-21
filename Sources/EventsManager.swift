//
//  EventsManager.swift
//  AppTrackingTests
//
//  Created by Artur Rymarz on 15/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

final class EventsManager {

    private let storage: TrackingStorage
    private let userManager: UserManager

    private var events: [Event] = []
    private var lastSentDate = Date(timeIntervalSince1970: TimeInterval(0))

    init(storage: TrackingStorage = UserDefaultsStorage(), userManager: UserManager = UserManager()) {
        self.storage = storage
        self.userManager = userManager
    }

    func addEvents(_ events: [Event]) {
        for event in events {
            addEvent(event)
        }
    }

    private func addEvent(_ event: Event) {
        let reportedEvent = ReportedEvent(clientId: event.analyticsSystemName, eventType: event.eventName, data: event.eventParameters)
        let eventSize = reportedEvent.sizeInBytes

        guard eventSize <= Constants.eventSizeLimit else {
            return
        }

        events.append(event)
    }
}

extension EventsManager {

    var isEaUuidValid: Bool {
        guard let eaUuid = storage.eaUuid else {
            return false
        }

        let expirationDate = eaUuid.creationDate.addingTimeInterval(TimeInterval(eaUuid.lifetime))
        let now = Date()

        return expirationDate > now
    }

    func storedIds() -> [String: String] {
        var ids = [String: String]()

        if isEaUuidValid, let identifier = storage.eaUuid {
            ids["eaUuid"] = identifier.value
        }

        if let trackingIds = storage.trackingIds {
            for identifier in trackingIds {
                if let identifierValue = identifier.value.value {
                    ids[identifier.key] = identifierValue
                }
            }
        }

        return ids
    }

    func buildEventRequest() -> EventRequest {
        let ids = storedIds()
        let idsSize: UInt = ids.jsonSizeInBytes

        let user = userManager.buildUser()
        let userSize = user.sizeInBytes

        var availableEventsSize = Constants.requestBodySizeLimit - idsSize - userSize - 64 // Extra bytes for json structure

        var reportedEvents = [ReportedEvent]()
        for event in events {
            let reportedEvent = ReportedEvent(clientId: event.analyticsSystemName, eventType: event.eventName, data: event.eventParameters)

            let eventSize = reportedEvent.sizeInBytes + 4 // Extra bytes for json structure

            if availableEventsSize > eventSize {
                reportedEvents.append(reportedEvent)

                availableEventsSize -= eventSize
            } else {
                break
            }
        }

        events.removeFirst(reportedEvents.count)

        return EventRequest(ids: ids,
                            user: user,
                            events: reportedEvents)
    }
}
