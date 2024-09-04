//
//  OfferData.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//

import Foundation

/// Data regarding the supplier of sales offers and offers themselves
public struct OfferData {
    let supplierData: SupplierData
    let paywallTemplateId: String
    let paywallVariantId: String?
    let displayMode: OfferDisplayMode
}

/// Sales supplier data
public struct SupplierData {
    let supplierAppId: String
    let paywallSupplier: String
}

/// Offer display mode
public enum OfferDisplayMode: String {
    case inline
    case modal
}
