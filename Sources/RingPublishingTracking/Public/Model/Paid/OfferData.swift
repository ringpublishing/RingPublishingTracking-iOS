//
//  OfferData.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// Data regarding the supplier of sales offers and offers themselves
public struct OfferData {
    let supplierData: SupplierData
    let paywallTemplateId: String
    let paywallVariantId: String?
    let displayMode: OfferDisplayMode

    /// OfferData initializer
    ///
    /// Paramters:
    /// - supplierData: Supplier data
    /// - paywallTemplateId: Paywall template ID
    /// - paywallVariantId: Paywall variant ID
    /// - displayMode: Offer display mode
    public init(supplierData: SupplierData,
                paywallTemplateId: String,
                paywallVariantId: String?,
                displayMode: OfferDisplayMode) {
        self.supplierData = supplierData
        self.paywallTemplateId = paywallTemplateId
        self.paywallVariantId = paywallVariantId
        self.displayMode = displayMode
    }
}

/// Sales supplier data
public struct SupplierData {

    /// Supplier app ID
    let supplierAppId: String

    /// Paywall supplier
    let paywallSupplier: String

    /// SupplierData initializer
    ///
    /// Parameters:
    /// - supplierAppId: Supplier app ID
    /// - paywallSupplier: Paywall supplier
    public init(supplierAppId: String, paywallSupplier: String) {
        self.supplierAppId = supplierAppId
        self.paywallSupplier = paywallSupplier
    }
}

/// Offer display mode
public enum OfferDisplayMode: String {
    case inline
    case modal
}
