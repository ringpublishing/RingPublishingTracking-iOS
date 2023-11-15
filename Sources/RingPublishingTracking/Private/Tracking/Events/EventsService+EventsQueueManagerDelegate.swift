//
//  EventsService+EventsQueueManagerDelegate.swift
//  
//
//  Created by Adam Mordavsky on 15.11.23.
//

import Foundation

// MARK: - EventsQueueManagerDelegate
extension EventsService: EventsQueueManagerDelegate {

    // Calls the root endpoint from the API
    func sendEvents(for eventsQueueManager: EventsQueueManager) {
        let body = buildEventRequest()
        let endpoint = SendEventEnpoint(body: body)

        apiService?.call(endpoint, completion: { [weak self] result in
            switch result {
            case .success(let response):
                self?.eventsQueueManager.events.removeItems(body.events)
                self?.storePostInterval(response.postInterval)
            case .failure(let error):
                switch error {
                case .responseError:
                    Logger.log("The request to send events was incorrect. Skipping those events.", level: .info)
                    self?.eventsQueueManager.events.removeItems(body.events)
                default:
                    break
                }
            }
        })
    }

    func eventsQueueBecameReadyToSendEvents(_ eventsQueueManager: EventsQueueManager) {
        Logger.log("Events queue is ready to send events. Events in queue: \(eventsQueueManager.events.allElements.count)")
        sendEvents(for: eventsQueueManager)
    }

    func eventsQueueFailedToScheduleTimer(_ eventsQueueManager: EventsQueueManager) {
        guard shouldRetryIdentifyRequest else { return }

        retryIdentifyRequest { [weak self] result in
            switch result {
            case .success:
                self?.eventsQueueManager.sendEventsIfPossible()
            case .failure:
                Logger.log("Error occured during the retrying of identity check.")
            }
        }
    }

    func eventsQueueFailedToAddEvent(_ eventsQueueManager: EventsQueueManager, event: Event) {
        let errorEvent = eventsFactory.createErrorEvent(
            for: event,
            applicationRootPath: structureInfoDecorator.applicationRootPath
        )
        eventsQueueManager.addEvents([errorEvent])
    }
}
