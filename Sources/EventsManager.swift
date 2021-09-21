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

    private var events: [Event] = []
    private var lastSentDate = Date(timeIntervalSince1970: TimeInterval(0))

    init(storage: TrackingStorage = UserDefaultsStorage()) {
        self.storage = storage
    }

    func addEvent(_ event: Event) {
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
}

extension EventsManager {

    private func buildEventRequest() -> EventRequest {
        let singleEventSizeLimit = Constants.eventSizeLimit

        let ids = [String: String]()
        let idsSize: UInt = ids.jsonSizeInBytes

        let user = User(adpConsent: nil, pubConsent: nil)
        let userSize = user.sizeInBytes

        var availableEventsSize = Constants.requestBodySizeLimit - idsSize - userSize

        var reportedEvents = [ReportedEvent]()
        for event in events {
            let reportedEvent = ReportedEvent(clientId: event.analyticsSystemName, eventType: event.eventName, data: event.eventParameters)

            let eventSize = reportedEvent.sizeInBytes

            if eventSize > singleEventSizeLimit {
                continue
            }

            if availableEventsSize > singleEventSizeLimit {
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
