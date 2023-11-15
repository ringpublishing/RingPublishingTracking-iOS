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
    private var storage: TrackingStorage

    /// Operation mode
    private let operationMode: Operationable

    /// User manager
    private let userManager = UserManager()

    /// Manager for retrieving adverisement identifier
    private let vendorManager = VendorManager()

    /// Events factory
    private let eventsFactory: EventsFactory

    /// User consents provider
    private let userConsentsProvider = ConsentProvider()

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

    private let configuration: RingPublishingTrackingConfiguration

    /// Delegate
    private weak var delegate: EventsServiceDelegate?

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
                    switch self.shouldRetryIdentifyRequest {
                    case true:
                        self.handleIdentifyMeRequestFailure(error: error)
                        self.isIdentifyMeRequestInProgress = false
                    case false:
                        guard let eaUUID = storage.eaUUID else { return }
                        self.retryArtemisRequest(eaUUID: eaUUID) { artemisResult in
                            switch artemisResult {
                            case .success(let artemis):
                                self.publishTrackingIdentifier(eaUUID: eaUUID, artemis: artemis)
                                self.isIdentifyMeRequestInProgress = false
                            case .failure(let error):
                                self.handleIdentifyMeRequestFailure(error: error)
                                self.isIdentifyMeRequestInProgress = false
                            }
                        }
                    }
                }
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

    /// Calls the /me endpoint from the API
    ///
    /// - Parameter completion: Completion handler
    func fetchIdentity(completion: @escaping (Result<EaUUID, ServiceError>) -> Void) {
        guard operationMode.canSendNetworkRequests else {
            Logger.log("Opt-out/Debug mode is enabled. Ignoring identify request.")
            // TODO: [ASZ] Maybe we should think how to handle callback here?
            completion(.failure(.genericError))
            return
        }

        guard let apiService else {
            Logger.log("RingPublishingTracking is not configured. Configure it using initialize method.", level: .error)
            completion(.failure(.genericError))
            return
        }

        let user = userManager.buildUser()
        let ids = storedIds()
        let body = IdentifyRequest(ids: ids, user: user)
        let endpoint = IdentifyEnpoint(body: body)

        apiService.call(endpoint) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                self.storePostInterval(response.postInterval)
                let eaUUIDStored = self.storeEaUUID(response.eaUUID)
                guard let eaUUIDStored else {
                    completion(.failure(.missingDecodedTrackingIdentifier))
                    return
                }
                completion(.success(eaUUIDStored))
            case .failure(let error):
                Logger.log("Failed to identify with error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    /// Calls the /user endpoint from the API.
    /// - Parameters:
    ///   - tenantID: Instance of tenantID.
    ///   - eaUUID: Identifier coming from the /me endpoint.
    ///   - completion: Completion handler.
    func fetchArtemisID(tenantID: String, eaUUID: EaUUID, completion: @escaping(Result<Artemis, ServiceError>) -> Void) {
        guard operationMode.canSendNetworkRequests else {
            Logger.log("Opt-out/Debug mode is enabled. Ignoring identify request.")
            // TODO: [ASZ] Maybe we should think how to handle callback here?
            completion(.failure(.genericError))
            return
        }

        guard let apiService else {
            Logger.log("RingPublishingTracking is not configured. Configure it using initialize method.", level: .error)
            completion(.failure(.genericError))
            return
        }

        let request: ArtemisRequest = ArtemisRequest(eaUUID: eaUUID.value, sso: userDataDecorator.sso, tenantID: tenantID)
        let endpoint: ArtemisEndpoint = ArtemisEndpoint(body: request)
        apiService.call(endpoint) { [weak self] result in
            switch result {
            case .success(let response):
                let object = response.transform()
                self?.storeArtemis(object)
                completion(.success((object)))
            case .failure(let error):
                self?.storeArtemis(nil)
                completion(.failure(error))
            }
        }
    }

    /// Perform sequential identity checks from API.
    /// - Parameters:
    ///   - tenantID: Instance of tenantID.
    ///   - completion: Completion handler.
    func performSequentialIdentity(tenantID: String, completion: @escaping(Result<(EaUUID, Artemis), ServiceError>) -> Void) {
        self.isIdentifyMeRequestInProgress = true
        fetchIdentity { [weak self] identityResult in
            switch identityResult {
            case .success(let eaUUID):
                self?.fetchArtemisID(tenantID: tenantID, eaUUID: eaUUID) { artemisResult in
                    switch artemisResult {
                    case .success(let artemis):
                        completion(.success(((eaUUID, artemis))))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
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

    /// Determinate if the whole identity process should be performed from the beginning.
    /// - Returns: Returns `True` is eaUUID is missing or not valid, otherwise returns `False`.
    func shouldRetryWholeIdentityProcess() -> Bool {
        guard storage.eaUUID != nil, isEaUuidValid else {
            return true
        }
        guard storage.artemisID != nil, isArtemisIDValid else {
            return false
        }
        return false
    }

    /// Retrieves Vendor Identifier (IDFA)
    func retrieveVendorIdentifier(completion: @escaping () -> Void) {
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
    func storeEaUUID(_ eaUUID: IdsWithLifetime?) -> EaUUID? {
        guard let eaUUID = eaUUID, let value = eaUUID.value, let lifetime = eaUUID.lifetime else {
            storage.eaUUID = nil
            storage.postInterval = nil
            Logger.log("Tracking identifier could not be stored. Missing in decoded response.", level: .error)
            return nil
        }
        let creationDate = Date()
        let eaUUIDObject = EaUUID(value: value, lifetime: lifetime, creationDate: creationDate)
        storage.eaUUID = eaUUIDObject
        return eaUUIDObject
    }

    /// Stores Post Interval
    func storePostInterval(_ postInterval: Int) {
        storage.postInterval = postInterval
    }

    /// Store artemis' object value.
    /// - Parameter object: Instance of the `Artemis` or `nil`.
    func storeArtemis(_ object: Artemis?) {
        storage.artemisID = object
    }

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

    func retryIdentifyRequest(completion: @escaping(Result<Void, Error>) -> Void) {
        Logger.log("Retrying identify request as required data is missing.")
        performSequentialIdentity(tenantID: configuration.tenantId) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func retryArtemisRequest(eaUUID: EaUUID, completion: @escaping(Result<Artemis, ServiceError>) -> Void) {
        Logger.log("Retrying artemis request as required data is missing.")
        fetchArtemisID(tenantID: configuration.tenantId, eaUUID: eaUUID) { result in
            switch result {
            case .success(let artemis):
                completion(.success(artemis))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func handleIdentifyMeRequestFailure(error: ServiceError?) {
        // Check if there was error at all - if not proper delegate with identifier was already called
        guard let error else { return }

        guard isEaUuidValid, isArtemisIDValid else {
            Logger.log("Failed to fetch tracking identifier with error: \(error)", level: .error)
            delegate?.eventsService(self, didFailWhileRetrievingTrackingIdentifier: error)
            return
        }

        guard let eaUUID = storage.eaUUID, let artemis = storage.artemisID else {
            delegate?.eventsService(self, didFailWhileRetrievingTrackingIdentifier: error)
            return
        }
        // In case we have stored valid tracking identifier, do not inform about error but pass stored identifier
        Logger.log("Failed to fetch tracking identifier with error: \(error) but SDK has valid stored identifier.")
        publishTrackingIdentifier(eaUUID: eaUUID, artemis: artemis)
    }

    func publishTrackingIdentifier(eaUUID: EaUUID, artemis: Artemis) {
        let eaID = TrackingIdentfierEaUUID(identifier: eaUUID.value, expirationDate: eaUUID.expirationDate)
        let artemisID = artemis.id
        let external = artemisID.external
        let art = TrackingIdentifierArtemis(id: artemisID, external: external, expirationDate: artemis.expirationDate)
        let identifier: TrackingIdentifier = TrackingIdentifier(eaUUID: eaID, artemisID: art)
        delegate?.eventsService(self, retrievedTrackingIdentifier: identifier)
    }

    /// Prepares event decorators
    func prepareDecorators() {
        // Generic
        registerDecorator(SizeDecorator())
        registerDecorator(uniqueIdentifierDecorator)
        registerDecorator(structureInfoDecorator)
        registerDecorator(adAreaDecorator)
        registerDecorator(userDataDecorator)
        registerDecorator(tenantIdentifierDecorator)
        registerDecorator(clientDecorator)
    }

    func decorateEvents(_ events: [Event], using decorators: [Decorator], completion: @escaping (_ events: [Event]) -> Void) {
        DispatchQueue.main.async {
            let decoratedEvents = events.map { $0.decorated(using: decorators) }
            completion(decoratedEvents)
        }
    }
}

// MARK: - EventsQueueManagerDelegate
extension EventsService: EventsQueueManagerDelegate {

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
        let errorEvent = eventsFactory.createErrorEvent(for: event,
                                                        applicationRootPath: structureInfoDecorator.applicationRootPath)

        eventsQueueManager.addEvents([errorEvent])
    }
}
