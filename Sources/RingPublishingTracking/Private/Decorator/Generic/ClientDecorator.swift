//
//  ClientDecorator.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 11/04/2022.
//

import Foundation

final class ClientDecorator: Decorator {

    private static let maxVariantExternalParametersCount = 10
    private static let maxVariantExternalParameterLength = 10

    private var variantExternalParameters: [String: String]?

    var parameters: [String: AnyHashable] {
        var userDataParams: [String: AnyHashable] = [:]

        userDataParams["RDLC"] = Client(variant: variant).jsonStringBase64

        return userDataParams
    }

    private var variant: ClientVariant? {
        guard let variantExternalParameters else { return nil }

        return ClientVariant(external: variantExternalParameters)
    }
}

extension ClientDecorator {

    /// Sets `variant.external` keys reported inside `RDLC`; rejected (unchanged) over 10 keys or 10 chars each.
    func updateVariantExternalParameters(_ parameters: [String: String]) {
        guard isValidVariantExternalParameters(parameters) else {
            Logger.log("""
            Rejected variant.external parameters: exceeds limits (max \(Self.maxVariantExternalParametersCount) keys, \
            max \(Self.maxVariantExternalParameterLength) characters per key/value)
            """, level: .error)
            return
        }

        variantExternalParameters = parameters
    }
}

private extension ClientDecorator {

    func isValidVariantExternalParameters(_ parameters: [String: String]) -> Bool {
        guard parameters.count <= Self.maxVariantExternalParametersCount else { return false }

        return parameters.allSatisfy { key, value in
            key.count <= Self.maxVariantExternalParameterLength && value.count <= Self.maxVariantExternalParameterLength
        }
    }
}
