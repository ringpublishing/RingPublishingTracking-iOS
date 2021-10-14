//
//  EventsService.swift
//  RingPublishingTrackingTests
//
//  Created by Artur Rymarz on 28/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Class used for all event operations
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

    /// Registered decorators
    private var decorators: [Decorator]

    private let uniqueIdentifierDecorator = UniqueIdentifierDecorator()
    private let structureInfoDecorator = StructureInfoDecorator()
    private let adAreaDecorator = AdAreaDecorator()
    private let userDataDecorator = UserDataDecorator()
    private let tenantIdentifierDecorator = TenantIdentifierDecorator()

    /// Delegate
    private weak var delegate: EventsServiceDelegate?

    init(storage: TrackingStorage = UserDefaultsStorage()) {
        self.storage = storage
        self.eventsQueueManager = EventsQueueManager(storage: storage, operationMode: operationMode)
        self.decorators = []
    }

    /// Setups API Service
    /// - Parameters:
    ///   - apiUrl: API url. If not provided the default URL will be used
    ///   - apiKey: API key
    func setup(apiUrl: URL?, apiKey: String, delegate: EventsServiceDelegate?) {
        apiService = APIService(apiUrl: apiUrl ?? Constants.apiUrl, apiKey: apiKey)
        eventsQueueManager.delegate = self

        self.delegate = delegate

        // Prepare decorators
        prepareDecorators()

        // Prepare random unique device identifier
        if storage.randomUniqueDeviceId == nil {
            storage.randomUniqueDeviceId = UUID().uuidString
        }

        retrieveVendorIdentifier { [weak self] in
            // Call identify once the API is configured to retrieve trackingIdentifier as soon as possible
            self?.identifyMeIfNeeded()
        }
    }

    /// Registers decorator for decorating data parameters
    /// - Parameters:
    ///   - decorator: `Decorator`
    func registerDecorator(_ decorator: Decorator) {
        decorators.append(decorator)
    }

    /// Adds list of events to the queue when the size of each event is appropriate
    /// - Parameter events: Array of `Event` that should be added to the queue
    func addEvents(_ events: [Event]) {
        let decoratedEvents: [Event] = events.map { event in
            event.decorated(using: decorators)
        }

        let filteredEvents = decoratedEvents.filter { event in
            if !event.isValidJSONObject {
                Logger.log("Event contains invalid parameters that are not JSONSerialization compatible. All objects should be String, Number, Array, Dictionary, or NSNull") // swiftlint:disable:this line_length
                return false
            }

            return true
        }

        eventsQueueManager.addEvents(filteredEvents)
    }

    /// Calls the /me endpoint from the API
    func identifyMe() {
        guard operationMode.canSendNetworkRequests else {
            Logger.log("Opt-out/Debug mode is enabled. Ignoring identify request.")
            return
        }

        guard let apiService = apiService else {
            Logger.log("RingPublishingTracking is not configured. Configure it using initialize method.", level: .error)
            return
        }

        let user = userManager.buildUser()
        let ids = storedIds()
        let body = IdentifyRequest(ids: ids, user: user)
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

    // MARK: - Decorators helpers

    func updateApplicationAdvertisementArea(_ currentAdvertisementArea: String) {
        adAreaDecorator.updateApplicationAdvertisementArea(applicationAdvertisementArea: currentAdvertisementArea)
    }

    func updateUserData(ssoSystemName: String, userId: String?) {
        userDataDecorator.updateUserData(data: .init(user: .init(sso: .init(logged: .init(id: userId), name: ssoSystemName))))
    }

    func updateUniqueIdentifier(partiallyReloaded: Bool) {
        if partiallyReloaded {
            uniqueIdentifierDecorator.updateSecondaryIdentifier()
        } else {
            uniqueIdentifierDecorator.updateIdentifiers()
        }
    }

    func updateTenantId(tenantId: String) {
        tenantIdentifierDecorator.updateTenantId(tenantId: tenantId)
    }

    func updateStructureType(structureType: StructureType, contentPageViewSource: ContentPageViewSource?) {
        structureInfoDecorator.updateStructureType(structureType: structureType, contentPageViewSource: contentPageViewSource)
    }

    func updateApplicationRootPath(applicationRootPath: String) {
        structureInfoDecorator.updateApplicationRootPath(applicationRootPath: applicationRootPath)
    }
}

extension EventsService {

    /// Checks if stored eaUUID is not expired
    var isEaUuidValid: Bool {
        guard let eaUUID = storage.eaUUID else {
            return false
        }

        let expirationDate = eaUUID.creationDate.addingTimeInterval(TimeInterval(eaUUID.lifetime))
        let now = Date()

        return expirationDate > now
    }

    /// Builds dictionary of stored tracking identifiers
    /// - Returns: Dictionary
    func storedIds() -> [String: String] {
        var ids = [String: String]()

        if isEaUuidValid, let identifier = storage.eaUUID {
            ids[Constants.trackingIdentifierKey] = identifier.value
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
            guard let eaUUID = storage.eaUUID else { return }

            delegate?.eventsService(self, retrievedTrackingIdentifier: eaUUID.value)
            return
        }

        identifyMe()
    }

    /// Retrieves Vendor Identifier (IDFA)
    private func retrieveVendorIdentifier(completion: @escaping () -> Void) {
        vendorManager.retrieveVendorIdentifier { [weak self] result in
            switch result {
            case .success(let identifier):
                self?.userManager.updateIDFA(idfa: identifier)
            case .failure:
                self?.userManager.updateIDFA(idfa: nil)
                self?.userManager.updateDeviceId(deviceId: self?.storage.randomUniqueDeviceId)
            }

            completion()
        }
    }

    // Stores User Identifier
    private func storeEaUUID(_ eaUUID: IdsWithLifetime?) {
        guard
            let eaUUID = eaUUID,
            let value = eaUUID.value,
            let lifetime = eaUUID.lifetime
        else {
            storage.eaUUID = nil
            return
        }

        let creationDate = Date()
        storage.eaUUID = EaUUID(value: value, lifetime: lifetime, creationDate: creationDate)

        delegate?.eventsService(self, retrievedTrackingIdentifier: value)
    }

    /// Stores Post Interval
    private func storePostInterval(_ postInterval: Int) {
        storage.postInterval = postInterval
    }

    // Calls the root endpoint from the API
    private func sendEvents(for eventsQueueManager: EventsQueueManager) {
        let body = buildEventRequest()
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

    /// Creates an requests to send events. Builds the list of events to send up to the maximum size limit for a whole request
    /// - Returns: `EventRequest`
    func buildEventRequest() -> EventRequest {
        let events = eventsQueueManager.events.allElements

        let user = userManager.buildUser()
        let ids = storedIds()
        let idsSize: UInt = ids.jsonSizeInBytes
        let userSize = user.sizeInBytes

        var availableEventsSize = Constants.requestBodySizeLimit - idsSize - userSize - 64 // Extra bytes for json structure

        var eventsToSend = [Event]()
        for event in events {
            let eventSize = event.sizeInBytes + 4 // Extra bytes for json structure

            if availableEventsSize > eventSize {
                eventsToSend.append(event)

                availableEventsSize -= eventSize
            } else {
                break
            }
        }

        eventsQueueManager.events.removeFirst(eventsToSend.count)

        return EventRequest(ids: ids,
                            user: user,
                            events: eventsToSend)
    }

    /// Prepares event decorators
    private func prepareDecorators() {
        // Generic
        registerDecorator(SizeDecorator())
        registerDecorator(ConsentStringDecorator())
        registerDecorator(uniqueIdentifierDecorator)
        registerDecorator(structureInfoDecorator)
        registerDecorator(adAreaDecorator)
        registerDecorator(userDataDecorator)
        registerDecorator(tenantIdentifierDecorator)
    }
}

// MARK: - EventsQueueManagerDelegate

extension EventsService: EventsQueueManagerDelegate {

    func eventsQueueBecameReadyToSendEvents(_ eventsQueueManager: EventsQueueManager) {
        Logger.log("Events queue is ready to send events.")
        sendEvents(for: eventsQueueManager)
    }
}
