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
        case fakeUserTermConversionId = "fake_user_term_conversion_id"
        case realUserTermConversionId = "real_user_term_conversion_id"
        case subscriptionBasePrice = "subscription_base_price"
        case subscriptionPriceCurrency = "subscription_price_currency"
        case subscriptionPromoPrice = "subscription_promo_price"
        case subscriptionPromoDuration = "subscription_promo_duration"
        case subscriptionOfferId = "mobile_offer_id"
    }

    let fakeUserId: String?
    let realUserId: String?
    let fakeUserTermConversionId: String?
    let realUserTermConversionId: String?
    let subscriptionBasePrice: Float?
    let subscriptionPriceCurrency: String?
    let subscriptionPromoPrice: Float?
    let subscriptionPromoDuration: String?
    let subscriptionOfferId: String?

    init(fakeUserId: String?,
         realUserId: String? = nil,
         fakeUserTermConversionId: String? = nil,
         realUserTermConversionId: String? = nil,
         subscriptionPaymentData: SubscriptionPaymentData? = nil) {
        self.fakeUserId = fakeUserId
        self.realUserId = realUserId
        self.fakeUserTermConversionId = fakeUserTermConversionId
        self.realUserTermConversionId = realUserTermConversionId
        self.subscriptionBasePrice = subscriptionPaymentData?.subscriptionBasePrice
        self.subscriptionPriceCurrency = subscriptionPaymentData?.subscriptionPriceCurrency
        self.subscriptionPromoPrice = subscriptionPaymentData?.subscriptionPromoPrice
        self.subscriptionPromoDuration = subscriptionPaymentData?.subscriptionPromoDuration
        self.subscriptionOfferId = subscriptionPaymentData?.subscriptionOfferId
    }
}
