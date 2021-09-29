//
//  EventsService.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 28/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

protocol EventsServiceDelegate: AnyObject {

    func eventsService(_ eventsService: EventsService, retrievedtrackingIdentifier identifier: String)
}

// Class used for all event operations
final class EventsService {

    /// Storage
    private var storage: TrackingStorage

    /// Operation mode
    private var operationMode = OperationMode()

    /// User manager
    private let userManager = UserManager()

    /// Events queue manager for adding and removing events to/from queue
    private let eventsQueueManager: EventsQueueManager

    /// Manager for retrieving adverisement identifier
    private let vendorManager = VendorManager()

    /// Service responsible for sending requests to the backend
    private var apiService: APIService?

    /// Delegate
    private weak var delegate: EventsServiceDelegate?

    init(storage: TrackingStorage = UserDefaultsStorage()) {
        self.storage = storage
        self.eventsQueueManager = EventsQueueManager(storage: storage, operationMode: operationMode)
    }

    /// Setups API Service
    /// - Parameters:
    ///   - apiUrl: API url. If not provided the default URL will be used
    ///   - apiKey: API key
    func setup(apiUrl: URL?, apiKey: String, delegate: EventsServiceDelegate?) {
        apiService = APIService(apiUrl: apiUrl ?? Constants.apiUrl, apiKey: apiKey)
        eventsQueueManager.delegate = self

        self.delegate = delegate

        // Call identify once the API is configured to retrieve trackingIdentifier as soon as possible
        identifyMeIfNeeded()
    }

    /// Adds list of events to the queue when the size of each event is appropriate
    /// - Parameter events: Array of `Event` that should be added to the queue
    func addEvents(_ events: [Event]) {
        eventsQueueManager.addEvents(events)
    }

    /// Calls the /me endpoint from the API
    func identifyMe() {
        guard let apiService = apiService else {
            Logger.log("RingPublishingTracking is not configured. Configure it using initialize method.", level: .error)
            return
        }

        let body = IdentifyRequest(ids: [:], user: nil) // TODO: decoration missing
        let endpoint = IdentifyEnpoint(body: body)

        apiService.call(endpoint) { [weak self] result in
            switch result {
            case .success(let response):
                self?.storeEaUUID(response.eaUUID)
                self?.storePostInterval(response.postInterval)
            case .failure(let error):
                break // TODO: missing error handling
            }
        }
    }

    func setDebugMode(enabled: Bool) {
        operationMode.debugEnabled = enabled
    }

    func setOptOutMode(enabled: Bool) {
        operationMode.optOutEnabled = enabled
    }
}

extension EventsService {

    /// Checks if stored eaUUID is not expired
    var isEaUuidValid: Bool {
        guard let eaUuid = storage.eaUuid else {
            return false
        }

        let expirationDate = eaUuid.creationDate.addingTimeInterval(TimeInterval(eaUuid.lifetime))
        let now = Date()

        return expirationDate > now
    }

    /// Builds dictionary of stored tracking identifiers
    /// - Returns: Dictionary
    func storedIds() -> [String: String] {
        var ids = [String: String]()

        if isEaUuidValid, let identifier = storage.eaUuid {
            ids["eaUUID"] = identifier.value
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

    /// Sends Identify Request if user identifier is missing or expired
    private func identifyMeIfNeeded() {
        guard !isEaUuidValid else {
            return
        }

        identifyMe()
    }

    /// Retrieves Vendor Identifier (IDFA)
    private func retrieveVendorIdentifier() {
        vendorManager.retrieveVendorIdentifier { result in
            switch result {
            case .success(let identifier):
                break // TODO: pass to UserManager to build User structure when building a request
            case .failure(let error):
                break // TODO: missing error handling
            }
        }
    }

    // Stores User Identifier
    private func storeEaUUID(_ eaUUID: IdsWithLifetime?) {
        guard
            let eaUUID = eaUUID,
            let value = eaUUID.value,
            let lifetime = eaUUID.lifetime
        else {
            storage.eaUuid = nil
            return
        }

        let creationDate = Date()
        storage.eaUuid = EaUuid(value: value, lifetime: lifetime, creationDate: creationDate)

        delegate?.eventsService(self, retrievedtrackingIdentifier: value)
    }

    /// Stores Post Interval
    private func storePostInterval(_ postInterval: Int) {
        storage.postInterval = postInterval
    }

    // Calls the root endpoint from the API
    private func sendEvents(for eventsQueueManager: EventsQueueManager) {
        let body = eventsQueueManager.buildEventRequest(with: [:], user: nil) // TODO: decoration missing
        let endpoint = SendEventEnpoint(body: body)

        apiService?.call(endpoint, completion: { [weak self] result in
            switch result {
            case .success(let response):
                self?.storePostInterval(response.postInterval)
            case .failure(let error):
                break // TODO: missing error handling
            }
        })
    }
}

// MARK: - EventsQueueManagerDelegate

extension EventsService: EventsQueueManagerDelegate {

    func eventsQueueBecameReadyToSendEvents(_ eventsQueueManager: EventsQueueManager) {
        sendEvents(for: eventsQueueManager)
    }
}
