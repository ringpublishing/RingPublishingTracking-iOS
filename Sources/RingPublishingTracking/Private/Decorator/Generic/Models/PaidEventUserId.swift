//
//  PaidEventUserId.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct EventDetails: Encodable {

    enum CodingKeys: String, CodingKey {
        case fakeUserId = "fake_user_id"
        case realUserId = "real_user_id"
        case subscriptionBasePrice = "subscription_base_price"
        case subscriptionPriceCurrency = "subscription_price_currency"
        case subscriptionPromoPrice = "subscription_promo_price"
        case subscriptionPromoDuration = "subscription_promo_duration"
        case paymentMethod = "payment_method"
    }

    let fakeUserId: String?
    let realUserId: String?
    let subscriptionBasePrice: String?
    let subscriptionPriceCurrency: String?
    let subscriptionPromoPrice: String?
    let subscriptionPromoDuration: String?
    let paymentMethod: String?

    init(fakeUserId: String?, realUserId: String? = nil, subscriptionPaymentData: SubscriptionPaymentData? = nil) {
        self.fakeUserId = fakeUserId
        self.realUserId = realUserId
        self.subscriptionBasePrice = subscriptionPaymentData?.subscriptionBasePrice
        self.subscriptionPriceCurrency = subscriptionPaymentData?.subscriptionPriceCurrency
        self.subscriptionPromoPrice = subscriptionPaymentData?.subscriptionPromoPrice
        self.subscriptionPromoDuration = subscriptionPaymentData?.subscriptionPromoDuration
        self.paymentMethod = subscriptionPaymentData?.paymentMethod.rawValue
    }
}
