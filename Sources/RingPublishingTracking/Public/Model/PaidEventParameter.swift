//
//  PaidEventParameter.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//

import Foundation

enum PaidEventParameter: String {
    case supplierAppId
    case paywallSupplier
    case paywallTemplateId
    case paywallVariantId
    case displayMode
    case source
    case sourcePublicationUuid
    case sourceDx
    case closurePercentage
    case tpcc
    case termId
    case paymentMethod
    case termConversionId
    case subscriptionBasePrice
    case subscriptionPromoPrice
    case subscriptionPromoPriceDuration
    case subscriptionPriceCurrency
    case metricLimitName
    case freePvCnt
    case freePvLimit
    case eventDetails
    case eventCategory
    case eventAction
    case rdlcn = "RDLCN"
}

extension Dictionary where Key == PaidEventParameter, Value == AnyHashable {
    var keysAsStrings: [String: AnyHashable] {
        .init( compactMap { ($0.key.rawValue, $0.value) }, uniquingKeysWith: { first, _ in first })
    }
}
