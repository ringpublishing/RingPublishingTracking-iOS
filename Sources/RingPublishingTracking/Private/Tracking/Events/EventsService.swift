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

    /// Storage
    var storage: TrackingStorage

    /// Operation mode
    let operationMode: Operationable

    /// User manager
    let userManager = UserManager()

    /// Manager for retrieving adverisement identifier
    let vendorManager = VendorManager()

    /// Events factory
    let eventsFactory: EventsFactory

    /// User consents provider
    private let userConsentsProvider = ConsentProvider()

    /// Service responsible for sending requests to the backend
    var apiService: APIService?

    var isIdentifyMeRequestInProgress: Bool = false

    /// Registered decorators
    var decorators: [Decorator]

    let uniqueIdentifierDecorator = UniqueIdentifierDecorator()
    let structureInfoDecorator = StructureInfoDecorator()
    let adAreaDecorator = AdAreaDecorator()
    let userDataDecorator = UserDataDecorator()
    let tenantIdentifierDecorator = TenantIdentifierDecorator()
    let clientDecorator = ClientDecorator()

    let configuration: RingPublishingTrackingConfiguration

    /// Delegate
    weak var delegate: EventsServiceDelegate?

    /// Events queue manager for adding and removing events to/from queue
    let eventsQueueManager: EventsQueueManager

    /// Checks if stored eaUUID is not expired
    var isEaUuidValid: Bool {
        guard let eaUUID = storage.eaUUID else {
            return false
        }

        let expirationDate = eaUUID.expirationDate
        let now = Date()

        return expirationDate > now
    }

    /// Checks if stored ArtemisID is not expired
    var isArtemisIDValid: Bool {
        guard let artemisID = storage.artemisID else {
            return false
        }
        let expirationDate = artemisID.expirationDate
        let now = Date()
        return expirationDate > now
    }

    var hasPostIntervalStored: Bool {
        storage.postInterval != nil
    }

    var shouldRetryIdentifyRequest: Bool {
        (!isEaUuidValid || !hasPostIntervalStored || !isArtemisIDValid) && !isIdentifyMeRequestInProgress
    }

    var isEffectivePageViewEventSent = false

    // MARK: Init

    init(storage: TrackingStorage = UserDefaultsStorage(),
         configuration: RingPublishingTrackingConfiguration,
         eventsFactory: EventsFactory,
         operationMode: Operationable) {
        self.configuration = configuration
        self.storage = storage
        self.eventsQueueManager = EventsQueueManager(storage: storage, operationMode: operationMode)
        self.eventsFactory = eventsFactory
        self.decorators = []
        self.operationMode = operationMode
    }

    // MARK: Methods

    /// Setups API Service
    /// - Parameters:
    ///   - delegate: Instance of the object which conforms to `EventsServiceDelegate`, otherwise `nil`.
    ///   - session: Session object used to create requests. Defaults to `URLSession.shared`
    func setup(delegate: EventsServiceDelegate?, session: NetworkSession = URLSession.shared) {
        apiService = APIService(apiUrl: configuration.apiUrl ?? Constants.apiUrl, apiKey: configuration.apiKey, session: session)
        eventsQueueManager.delegate = self

        self.delegate = delegate

        // Prepare decorators
        prepareDecorators()

        // Prepare random unique device identifier
        if storage.randomUniqueDeviceId == nil {
            storage.randomUniqueDeviceId = UUID().uuidString
        }

        // Set initial TCF2.0 string value
        userManager.updateTCFV2(tcfv2: userConsentsProvider.tcfv2)

        // Observe for TCF2.0 consents string change
        userConsentsProvider.observeConsentsChange(observerCallback: { [weak self] consents in
            self?.userManager.updateTCFV2(tcfv2: consents)
        })

        retrieveVendorIdentifier { [weak self] in
            guard let self else { return }
            // Call identify once the API is configured to retrieve trackingIdentifier as soon as possible
            self.performSequentialIdentity(tenantID: self.configuration.tenantId, completion: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let identifiers):
                    self.publishTrackingIdentifier(eaUUID: identifiers.0, artemis: identifiers.1)
                    self.isIdentifyMeRequestInProgress = false
                case .failure(let error):
                    self.retryIdentityRequest(error: error)
                }
            })
        }
    }

    /// Adds list of events to the queue when the size of each event is appropriate
    ///
    /// - Parameter events: Array of `Event` that should be added to the queue
    func addEvents(_ events: [Event]) {
        decorateEvents(events, using: decorators) { [weak self] decoratedEvents in
            let filteredEvents = decoratedEvents.filter { event in
                if !event.isValidJSONObject {
                    let logMessage = """
                    Event contains invalid parameters that are not JSONSerialization compatible.
                    All objects should be String, Number, Array, Dictionary, or NSNull
                    """
                    Logger.log(logMessage)
                    return false
                }

                return true
            }

            self?.eventsQueueManager.addEvents(filteredEvents)
        }
    }

    // MARK: Internal

    /// Creates an requests to send events. Builds the list of events to send up to the maximum size limit for a whole request
    /// 
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
}

// MARK: Private
private extension EventsService {

    func decorateEvents(_ events: [Event], using decorators: [Decorator], completion: @escaping (_ events: [Event]) -> Void) {
        switch Thread.isMainThread {
        case true:
            let decoratedEvents = events.map { $0.decorated(using: decorators) }
            completion(decoratedEvents)

        case false:
            DispatchQueue.main.sync {
                let decoratedEvents = events.map { $0.decorated(using: decorators) }
                completion(decoratedEvents)
            }
        }
    }
}
