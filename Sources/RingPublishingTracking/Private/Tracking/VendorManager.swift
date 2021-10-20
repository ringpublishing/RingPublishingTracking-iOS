//
//  VendorManager.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 27/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit

enum VendorManagerError: Error {

    case missingIdentifier
}

final class VendorManager {

    private let source: VendorIdentifiable

    private let retryLimit = 5
    private var retryCounter = 0

    init(source: VendorIdentifiable = UIDevice.current) {
        self.source = source
    }

    func retrieveVendorIdentifier(completion: @escaping (Result<UUID, Error>) -> Void) {
        guard let identifier = source.identifierForVendor else {
            guard retryCounter < retryLimit else {
                Logger.log("Could not retrieve identifier for vendor.", level: .error)
                completion(.failure(VendorManagerError.missingIdentifier))
                return
            }

            retryCounter += 1

            let dispatchTime: DispatchTime = .now() + .seconds(retryCounter * 5)
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: dispatchTime) {
                self.retrieveVendorIdentifier(completion: completion)
            }

            return
        }

        completion(.success(identifier))
    }
}
