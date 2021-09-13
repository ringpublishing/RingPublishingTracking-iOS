//
//  ServiceError.swift
//  ServiceError
//
//  Created by Artur Rymarz on 13/09/2021.
//

import Foundation

enum ServiceError: Error {
    case noData
    case incorrectRequestBody
    case unauthorized
    case failedToDecode
    case requestError(error: Error)
}
