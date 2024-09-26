//
//  RingPublishingTracking+Paid.swift
//  RingPublishingTrackingTests
//
//  Created by Bernard Bijoch on 04/09/2024.
//  Copyright © 2024 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

public extension RingPublishingTracking {

    /// Reports showing offer event
    /// There is possibility to start purchasing process flow from this place
    ///
    /// - Parameters:
    /// - contentMetadata: Content metadata
    /// - offerData: Data regarding the supplier of sales offers and offers themselves
    /// - offerContextData: Data regarding the offer context / content
    /// - targetPromotionCampaignCode: Offer id of given promotion / campaign
    func reportShowOfferEvent(contentMetadata: ContentMetadata?,
                              offerData: OfferData,
                              offerContextData: OfferContextData,
                              targetPromotionCampaignCode: String?) {

        let event = eventsFactory.createShowOfferEvent(contentMetadata: contentMetadata,
                                                       offerData: offerData,
                                                       offerContextData: offerContextData,
                                                       targetPromotionCampaignCode: targetPromotionCampaignCode)
        reportEvent(event)
    }

    /// Reports showing offer teaser event
    /// There is no possibility to start purchasing process flow from this place
    ///
    /// - Parameters:
    ///   - contentMetadata: Content metadata
    ///   - offerData: Data regarding the supplier of sales offers and offers themselves
    ///   - offerContextData: Data regarding the offer context / content
    ///   - targetPromotionCampaignCode: Offer id of given promotion / campaign
    func reportShowOfferTeaserEvent(contentMetadata: ContentMetadata?,
                                    offerData: OfferData,
                                    offerContextData: OfferContextData,
                                    targetPromotionCampaignCode: String?) {
        let event = eventsFactory.createShowOfferTeaserEvent(contentMetadata: contentMetadata,
                                                             offerData: offerData,
                                                             offerContextData: offerContextData,
                                                             targetPromotionCampaignCode: targetPromotionCampaignCode)
        reportEvent(event)
    }

    /// Reports event of clicking button used to start purchasing process flow
    ///
    /// - Parameters:
    ///   - contentMetadata: Content metadata
    ///   - offerData: Data regarding the supplier of sales offers and offers themselves
    ///   - offerContextData: Data regarding the offer context / content
    ///   - termId: Id of specific purchase term / offer selected by user
    ///   - targetPromotionCampaignCode: Offer id of given promotion / campaign
    func reportPurchaseClickButtonEvent(contentMetadata: ContentMetadata?,
                                        offerData: OfferData,
                                        offerContextData: OfferContextData,
                                        termId: String,
                                        targetPromotionCampaignCode: String?) {
        let event = eventsFactory.createPurchaseClickButtonEvent(contentMetadata: contentMetadata,
                                                                 offerData: offerData,
                                                                 offerContextData: offerContextData,
                                                                 termId: termId,
                                                                 targetPromotionCampaignCode: targetPromotionCampaignCode)
        reportEvent(event)
    }

    // swiftlint:disable function_parameter_count

    /// Reports subscription purchase event
    ///
    /// - Parameters:
    ///   - contentMetadata: Content metadata
    ///   - offerData: Data regarding the supplier of sales offers and offers themselves
    ///   - offerContextData: Data regarding the offer context / content
    ///   - subscriptionPaymentData: Data regarding subscription payment
    ///   - termId: Id of specific purchase term / offer selected by user
    ///   - termConversionId: Purchase conversion id
    ///   - targetPromotionCampaignCode: Offer id of given promotion / campaign
    ///   - temporaryUserId: Temporary user id
    func reportPurchaseEvent(contentMetadata: ContentMetadata?,
                             offerData: OfferData,
                             offerContextData: OfferContextData,
                             subscriptionPaymentData: SubscriptionPaymentData,
                             termId: String,
                             termConversionId: String,
                             targetPromotionCampaignCode: String?,
                             temporaryUserId: String?) {
        let event = eventsFactory.createPurchaseEvent(contentMetadata: contentMetadata,
                                                      offerData: offerData,
                                                      offerContextData: offerContextData,
                                                      subscriptionPaymentData: subscriptionPaymentData,
                                                      termId: termId,
                                                      termConversionId: termConversionId,
                                                      targetPromotionCampaignCode: targetPromotionCampaignCode,
                                                      temporaryUserId: temporaryUserId)
        reportEvent(event)
    }

    // swiftlint:enable function_parameter_count

    /// Reports event of displaying paid content to the user within a metered counter.
    ///
    /// - Parameters:
    ///   - contentMetadata: Content metadata
    ///   - supplierData: Data regarding the supplier of sales
    ///   - metricsData: Metric counter data
    func reportShowMetricLimitEvent(contentMetadata: ContentMetadata,
                                    supplierData: SupplierData,
                                    metricsData: MetricsData) {
        let event = eventsFactory.createShowMetricLimitEvent(contentMetadata: contentMetadata,
                                                             supplierData: supplierData,
                                                             metricsData: metricsData)
        reportEvent(event)
    }

    /// Reports event of prediction of user likelihood to subscribe / cancel subscription
    ///
    /// - Parameters:
    ///   - contentMetadata: Content metadata
    ///   - supplierData: Data regarding the supplier of sales
    ///   - likelihoodData: Data regarding likelihood to subscribe / cancel subscription
    func reportLikelihoodScoringEvent(contentMetadata: ContentMetadata?,
                                      supplierData: SupplierData,
                                      likelihoodData: LikelihoodData) {
        let event = eventsFactory.createLikelihoodScoringEvent(contentMetadata: contentMetadata,
                                                               supplierData: supplierData,
                                                               likelihoodData: likelihoodData)
        reportEvent(event)
    }

    /// Reports event about changing user data from temporary to real
    ///
    /// - Parameters:
    ///   - temporaryUserId: Temporary user id
    ///   - realUserId: New user id
    func reportMobileAppTemporaryUserIdReplacedEvent(temporaryUserId: String,
                                                     realUserId: String) {
        let event = eventsFactory.createMobileAppFakeUserIdReplacedEvent(temporaryUserId: temporaryUserId,
                                                                         realUserId: realUserId)
        reportEvent(event)
    }

}
