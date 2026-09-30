//
//  EventsService+Identity.swift
//  
//
//  Created by Adam Mordavsky on 15.11.23.
//

import Foundation

extension EventsService {

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
    func fetchArtemisID(tenantID: String, eaUUID: EaUUID, completion: @escaping (Result<Artemis, ServiceError>) -> Void) {
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
                self?.userDataDecorator.updateArtemisData(artemis: object.id)
                completion(.success((object)))

            case .failure(let error):
                self?.storeArtemis(nil)
                self?.userDataDecorator.updateArtemisData(artemis: nil)
                completion(.failure(error))
            }
        }
    }

    /// Perform sequential identity checks from API.
    /// - Parameters:
    ///   - tenantID: Instance of tenantID.
    ///   - completion: Completion handler.
    func performSequentialIdentity(tenantID: String, completion: @escaping (Result<(EaUUID, Artemis), ServiceError>) -> Void) {
        identityRequestStarted()

        let finish: (Result<(EaUUID, Artemis), ServiceError>) -> Void = { [weak self] result in
            self?.identityRequestFinished()
            completion(result)
        }

        fetchIdentity { [weak self] identityResult in
            switch identityResult {
            case .success(let eaUUID):
                self?.fetchArtemisID(tenantID: tenantID, eaUUID: eaUUID) { artemisResult in
                    switch artemisResult {
                    case .success(let artemis):
                        finish(.success(((eaUUID, artemis))))
                    case .failure(let error):
                        finish(.failure(error))
                    }
                }
            case .failure(let error):
                finish(.failure(error))
            }
        }
    }

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

    /// Retry whole identity process from start.
    /// - Parameter error: `ServiceError` instance from previous operation.
    func retryIdentityRequest(error: ServiceError) {
        switch shouldRetryWholeIdentityProcess() {
        case true:
            self.handleIdentifyMeRequestFailure(error: error)
        case false:
            guard let eaUUID = storage.eaUUID else { return }
            retryArtemisRequest(eaUUID: eaUUID) { [weak self] artemisResult in
                switch artemisResult {
                case .success(let artemis):
                    self?.publishTrackingIdentifier(eaUUID: eaUUID, artemis: artemis)
                case .failure(let error):
                    self?.handleIdentifyMeRequestFailure(error: error)
                }
            }
        }
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

    func retryIdentifyRequest(completion: @escaping (Result<Void, Error>) -> Void) {
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

    func retryArtemisRequest(eaUUID: EaUUID, completion: @escaping (Result<Artemis, ServiceError>) -> Void) {
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
        let eaUUID = Identifier(value: eaUUID.value, expirationDate: eaUUID.expirationDate)
        let artemisId = Identifier(value: artemis.id.artemis, expirationDate: artemis.expirationDate)
        let trackingIdentifier = TrackingIdentifier(eaUUID: eaUUID,
                                                    artemisID: artemisId,
                                                    sessionIdentifier: sessionIdentifierDecorator.currentIdentifier)

        delegate?.eventsService(self, retrievedTrackingIdentifier: trackingIdentifier)
    }
}

// MARK: - Events queued before the identity is known
extension EventsService {

    /// Marks an identity request (/me followed by /user) as started
    func identityRequestStarted() {
        identityLock.lock()
        identityRequestsInProgress += 1
        lastIdentityRequestDate = Date()
        identityLock.unlock()
    }

    /// Marks an identity request as finished and, once none is left in flight, sends the events which waited for it
    func identityRequestFinished() {
        identityLock.lock()
        identityRequestsInProgress = max(identityRequestsInProgress - 1, 0)
        let shouldSendWaitingEvents = identityRequestsInProgress == 0 && isSendingWaitingForIdentity
        if shouldSendWaitingEvents {
            isSendingWaitingForIdentity = false
        }
        identityLock.unlock()

        guard shouldSendWaitingEvents else { return }

        // Identity completions run on a background queue, while the queue manager schedules its timer on the main run loop
        DispatchQueue.main.async { [weak self] in
            self?.eventsQueueManager.sendEventsIfPossible()
        }
    }

    /// Checks if sending has to wait for the identity request in flight.
    /// Sent before it finishes, events would reach the backend without eaUUID,
    /// which is what happened to the first events reported after a fresh install.
    ///
    /// - Returns: `True` if identifiers are missing and an identity request is in flight, otherwise `False`
    func shouldWaitForIdentityInProgress() -> Bool {
        guard !isEaUuidValid || !hasPostIntervalStored || !isArtemisIDValid else { return false }

        identityLock.lock()
        defer { identityLock.unlock() }

        guard identityRequestsInProgress > 0 else { return false }

        isSendingWaitingForIdentity = true
        return true
    }

    /// Checks if enough time has passed since the last identity request to retry it,
    /// so an offline device does not call /me for every reported event.
    ///
    /// - Returns: `True` if an identity request may be retried now, otherwise `False`
    func isIdentityRetryAllowed() -> Bool {
        identityLock.lock()
        defer { identityLock.unlock() }

        guard let lastIdentityRequestDate else { return true }

        return Date() >= lastIdentityRequestDate.addingTimeInterval(identityRetryInterval)
    }
}
