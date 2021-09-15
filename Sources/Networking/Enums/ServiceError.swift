//
//  ServiceError.swift
//  ServiceError
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

enum ServiceError: Error {
    case noData
    case invalidUrl
    case incorrectRequestBody
    case unauthorized
    case failedToDecode
    case requestError(error: Error)
}
