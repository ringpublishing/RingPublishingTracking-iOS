//
//  SubscriptionPaymentData.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//

import Foundation

/// Subscription payment data
public struct SubscriptionPaymentData {

    /// Subscription base price
    let subscriptionBasePrice: String

    /// Subscription promotion price (optional - of someone purchases from promotion)
    let subscriptionPromoPrice: String?

    /// Promotion duration (optional - of someone purchases from promotion) 1w / 1m / 1y etc.
    let subscriptionPromoPriceDuration: String?

    /// Purchase price currency identifier
    let subscriptionPriceCurrency: String

    /// Payment method
    let paymentMethod: PaymentMethod
}

/// Payment method
public enum PaymentMethod: String {
    case appStore = "app_store"
    case other
}
