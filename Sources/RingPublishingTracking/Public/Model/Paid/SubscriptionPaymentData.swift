//
//  SubscriptionPaymentData.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
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

    public init(subscriptionBasePrice: String,
                subscriptionPromoPrice: String?,
                subscriptionPromoPriceDuration: String?,
                subscriptionPriceCurrency: String,
                paymentMethod: PaymentMethod) {
        self.subscriptionBasePrice = subscriptionBasePrice
        self.subscriptionPromoPrice = subscriptionPromoPrice
        self.subscriptionPromoPriceDuration = subscriptionPromoPriceDuration
        self.subscriptionPriceCurrency = subscriptionPriceCurrency
        self.paymentMethod = paymentMethod
    }
}

/// Payment method
public enum PaymentMethod: String {
    case appStore = "app_store"
    case other
}
