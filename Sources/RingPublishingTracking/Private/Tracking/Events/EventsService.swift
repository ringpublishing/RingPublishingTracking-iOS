//
//  EventsService.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 28/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Class used for all event operations
final class EventsService {

    /// Events queue manager for adding and removing events to/from queue
    let eventsQueueManager: EventsQueueManager

    /// Storage
    private var storage: TrackingStorage

    /// Operation mode
    private let operationMode: Operationable

    /// User manager
    private let userManager = UserManager()

    /// Manager for retrieving adverisement identifier
    private let vendorManager = VendorManager()

    /// Events factory
    private let eventsFactory: EventsFactory

    /// Service responsible for sending requests to the backend
    private var apiService: APIService?

    private var isIdentifyMeRequestInProgress: Bool = false

    /// Registered decorators
    private var decorators: [Decorator]

    private let uniqueIdentifierDecorator = UniqueIdentifierDecorator()
    private let structureInfoDecorator = StructureInfoDecorator()
    private let adAreaDecorator = AdAreaDecorator()
    private let userDataDecorator = UserDataDecorator()
    private let tenantIdentifierDecorator = TenantIdentifierDecorator()
    private let clientDecorator = ClientDecorator()

    /// Delegate
    private weak var delegate: EventsServiceDelegate?

    init(storage: TrackingStorage = UserDefaultsStorage(), eventsFactory: EventsFactory, operationMode: Operationable) {
        self.storage = storage
        self.eventsQueueManager = EventsQueueManager(storage: storage, operationMode: operationMode)
        self.eventsFactory = eventsFactory
        self.decorators = []
        self.operationMode = operationMode
    }

    /// Setups API Service
    /// - Parameters:
    ///   - apiUrl: API url. If not provided the default URL will be used
    ///   - apiKey: API key
    ///   - session: Session object used to create requests. Defaults to `URLSession.shared`
    func setup(apiUrl: URL?, apiKey: String, delegate: EventsServiceDelegate?, session: NetworkSession = URLSession.shared) {
        apiService = APIService(apiUrl: apiUrl ?? Constants.apiUrl, apiKey: apiKey, session: session)
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
            self?.identifyMe(completion: { [weak self] error in
                self?.handleIdentifyMeRequestFailure(error: error)
            })
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
    ///
    /// - Parameter completion: Completion handler
    func identifyMe(completion: @escaping ((_ error: ServiceError?) -> Void)) {
        guard operationMode.canSendNetworkRequests else {
            Logger.log("Opt-out/Debug mode is enabled. Ignoring identify request.")

            // TODO: [ASZ] Maybe we should think how to handle callback here?
            completion(nil)
            return
        }

        guard let apiService = apiService else {
            Logger.log("RingPublishingTracking is not configured. Configure it using initialize method.", level: .error)
            completion(.genericError)
            return
        }

        let user = userManager.buildUser()
        let ids = storedIds()
        let body = IdentifyRequest(ids: ids, user: user)
        let endpoint = IdentifyEnpoint(body: body)

        isIdentifyMeRequestInProgress = true

        apiService.call(endpoint) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                self.storePostInterval(response.postInterval)
                let eaUUIDStored = self.storeEaUUID(response.eaUUID)

                let error: ServiceError? = eaUUIDStored ? nil : .missingDecodedTrackingIdentifier
                completion(error)

            case .failure(let error):
                Logger.log("Failed to identify with error: \(error.localizedDescription)")
                completion(error)
            }

            self.isIdentifyMeRequestInProgress = false
        }
    }

    // MARK: - Decorators helpers

    func updateApplicationAdvertisementArea(_ currentAdvertisementArea: String) {
        adAreaDecorator.updateApplicationAdvertisementArea(applicationAdvertisementArea: currentAdvertisementArea)
    }

    func updateUserData(ssoSystemName: String, userId: String?, email: String?) {
        let preparedEmail = email?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let data = UserData(sso: .init(logged: .init(id: userId, md5: preparedEmail?.md5()), name: ssoSystemName))

        userDataDecorator.updateUserData(data: data)
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

        let expirationDate = eaUUID.expirationDate
        let now = Date()

        return expirationDate > now
    }

    var hasPostIntervalStored: Bool {
        storage.postInterval != nil
    }

    var shouldRetryIdentifyRequest: Bool {
        (!isEaUuidValid || !hasPostIntervalStored) && !isIdentifyMeRequestInProgress
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

    /// Stores User Identifier
    ///
    /// - Parameter eaUUID: IdsWithLifetime?
    /// - Returns: True if identifier was stored, false otherwise
    private func storeEaUUID(_ eaUUID: IdsWithLifetime?) -> Bool {
        guard let eaUUID = eaUUID, let value = eaUUID.value, let lifetime = eaUUID.lifetime else {
            storage.eaUUID = nil
            storage.postInterval = nil
            Logger.log("Tracking identifier could not be stored. Missing in decoded response.", level: .error)
            return false
        }

        let creationDate = Date()
        let eaUUIDObject = EaUUID(value: value, lifetime: lifetime, creationDate: creationDate)
        let expirationDate = eaUUIDObject.expirationDate

        storage.eaUUID = eaUUIDObject
        delegate?.eventsService(self, retrievedTrackingIdentifier: value, expirationDate: expirationDate)

        return true
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

    private func retryIdentifyRequest(completion: @escaping (_ success: Bool) -> Void) {
        Logger.log("Retrying identify request as required data is missing.")

        identifyMe { [weak self] error in
            self?.handleIdentifyMeRequestFailure(error: error)

            completion(error == nil)
        }
    }

    private func handleIdentifyMeRequestFailure(error: ServiceError?) {
        // Check if there was error at all - if not proper delegate with identifier was already called
        guard let error = error else { return }

        // In case we have stored valid tracking identifier, do not inform about error but pass stored identifier
        guard let value = storage.eaUUID?.value, let expirationDate = storage.eaUUID?.expirationDate, isEaUuidValid else {
            Logger.log("Failed to fetch tracking identifier with error: \(error)", level: .error)
            delegate?.eventsService(self, didFailWhileRetrievingTrackingIdentifier: error)
            return
        }

        Logger.log("Failed to fetch tracking identifier with error: \(error) but SDK has valid stored identifier.")
        delegate?.eventsService(self, retrievedTrackingIdentifier: value, expirationDate: expirationDate)
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
        registerDecorator(clientDecorator)
    }
}

// MARK: - EventsQueueManagerDelegate
extension EventsService: EventsQueueManagerDelegate {

    func eventsQueueBecameReadyToSendEvents(_ eventsQueueManager: EventsQueueManager) {
        Logger.log("Events queue is ready to send events. Events in queue: \(eventsQueueManager.events.allElements.count)")
        sendEvents(for: eventsQueueManager)
    }

    func eventsQueueFailedToScheduleTimer(_ eventsQueueManager: EventsQueueManager) {
        guard shouldRetryIdentifyRequest else {
            return
        }

        retryIdentifyRequest { [weak self] success in
            guard success else { return }

            self?.eventsQueueManager.sendEventsIfPossible()
        }
    }

    func eventsQueueFailedToAddEvent(_ eventsQueueManager: EventsQueueManager, event: Event) {
        let errorEvent = eventsFactory.createErrorEvent(for: event,
                                                        applicationRootPath: structureInfoDecorator.applicationRootPath)

        eventsQueueManager.addEvents([errorEvent])
    }
}
