//
//  EventsFactory+Paid.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//  Copyright © 2023 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

extension EventsFactory {

    func createPaidEvent(parameters: [String: AnyHashable]) -> Event {
        return Event(analyticsSystemName: AnalyticsSystem.generic.rawValue,
                     eventName: EventType.paid.rawValue,
                     eventParameters: parameters)
    }

    func createShowOfferEvent(contentMetadata: ContentMetadata?,
                              offerData: OfferData,
                              offerContextData: OfferContextData,
                              targetPromotionCampaignCode: String?) -> Event {
        var parameters: [String: AnyHashable] = [:]

        parameters["event_category"] = "checkout"
        parameters["event_action"] = "showOffer"
        parameters["supplier_app_id"] = offerData.supplierData.supplierAppId
        parameters["paywall_supplier"] = offerData.supplierData.paywallSupplier
        parameters["paywall_template_id"] = offerData.paywallTemplateId
        parameters["display_mode"] = offerData.displayMode.rawValue
        parameters["source"] = offerContextData.source
        parameters["source_dx"] = contentMetadata?.dxParameter
        parameters["source_publication_uuid"] = contentMetadata?.publicationId
        parameters["paywall_variant_id"] = offerData.paywallVariantId
        parameters["closure_percentage"] = offerContextData.closurePercentage
        parameters["tpcc"] = targetPromotionCampaignCode
        parameters["RDLCN"] = contentMetadata?.rdlcnParameter

        return createPaidEvent(parameters: parameters)
    }

    func createShowOfferTeaserEvent(contentMetadata: ContentMetadata?,
                                    offerData: OfferData,
                                    offerContextData: OfferContextData,
                                    targetPromotionCampaignCode: String?) -> Event {
        var parameters: [String: AnyHashable] = [:]

        parameters["event_category"] = "checkout"
        parameters["event_action"] = "showOfferTeaser"
        parameters["supplier_app_id"] = offerData.supplierData.supplierAppId
        parameters["paywall_supplier"] = offerData.supplierData.paywallSupplier
        parameters["paywall_template_id"] = offerData.paywallTemplateId
        parameters["display_mode"] = offerData.displayMode.rawValue
        parameters["source"] = offerContextData.source
        parameters["source_dx"] = contentMetadata?.dxParameter
        parameters["source_publication_uuid"] = contentMetadata?.publicationId
        parameters["paywall_variant_id"] = offerData.paywallVariantId
        parameters["closure_percentage"] = offerContextData.closurePercentage
        parameters["tpcc"] = targetPromotionCampaignCode
        parameters["RDLCN"] = contentMetadata?.rdlcnParameter

        return createPaidEvent(parameters: parameters)
    }

    func createPurchaseClickButtonEvent(contentMetadata: ContentMetadata?,
                                        offerData: OfferData,
                                        offerContextData: OfferContextData,
                                        termId: String,
                                        targetPromotionCampaignCode: String?) -> Event {
        var parameters: [String: AnyHashable] = [:]

        parameters["event_category"] = "checkout"
        parameters["event_action"] = "clickButton"
        parameters["supplier_app_id"] = offerData.supplierData.supplierAppId
        parameters["paywall_supplier"] = offerData.supplierData.paywallSupplier
        parameters["paywall_template_id"] = offerData.paywallTemplateId
        parameters["display_mode"] = offerData.displayMode.rawValue
        parameters["source"] = offerContextData.source
        parameters["term_id"] = termId
        parameters["source_dx"] = contentMetadata?.dxParameter
        parameters["source_publication_uuid"] = contentMetadata?.publicationId
        parameters["paywall_variant_id"] = offerData.paywallVariantId
        parameters["tpcc"] = targetPromotionCampaignCode
        parameters["RDLCN"] = contentMetadata?.rdlcnParameter

        return createPaidEvent(parameters: parameters)
    }

    // swiftlint:disable function_parameter_count

    func createPurchaseEvent(contentMetadata: ContentMetadata?,
                             offerData: OfferData,
                             offerContextData: OfferContextData,
                             subscriptionPaymentData: SubscriptionPaymentData,
                             termId: String,
                             termConversionId: String,
                             targetPromotionCampaignCode: String?,
                             temporaryUserId: String?) -> Event {
        var parameters: [String: AnyHashable] = [:]

        parameters["event_category"] = "checkout"
        parameters["event_action"] = "purchase"
        parameters["supplier_app_id"] = offerData.supplierData.supplierAppId
        parameters["paywall_supplier"] = offerData.supplierData.paywallSupplier
        parameters["paywall_template_id"] = offerData.paywallTemplateId
        parameters["display_mode"] = offerData.displayMode.rawValue
        parameters["source"] = offerContextData.source
        parameters["term_id"] = termId
        parameters["term_conversion_id"] = termConversionId
        parameters["source_dx"] = contentMetadata?.dxParameter
        parameters["source_publication_uuid"] = contentMetadata?.publicationId
        parameters["paywall_variant_id"] = offerData.paywallVariantId
        parameters["tpcc"] = targetPromotionCampaignCode
        parameters["event_details"] = EventDetails(fakeUserId: temporaryUserId, subscriptionPaymentData: subscriptionPaymentData).jsonString
        parameters["payment_method"] = subscriptionPaymentData.paymentMethod.rawValue
        parameters["RDLCN"] = contentMetadata?.rdlcnParameter

        return createPaidEvent(parameters: parameters)
    }

    // swiftlint:enable function_parameter_count

    func createShowMetricLimitEvent(contentMetadata: ContentMetadata,
                                    supplierData: SupplierData,
                                    metricsData: MetricsData) -> Event {
        var parameters: [String: AnyHashable] = [:]

        parameters["event_category"] = "metric_limit"
        parameters["event_action"] = "showMetricLimit"
        parameters["supplier_app_id"] = supplierData.supplierAppId
        parameters["paywall_supplier"] = supplierData.paywallSupplier
        parameters["metric_limit_name"] = metricsData.metricLimitName
        parameters["free_pv_cnt"] = metricsData.freePageViewCount
        parameters["free_pv_limit"] = metricsData.freePageViewLimit
        parameters["source_dx"] = contentMetadata.dxParameter
        parameters["source_publication_uuid"] = contentMetadata.publicationId
        parameters["RDLCN"] = contentMetadata.rdlcnParameter

        return createPaidEvent(parameters: parameters)
    }

    func createLikelihoodScoringEvent(contentMetadata: ContentMetadata?,
                                      supplierData: SupplierData,
                                      likelihoodData: LikelihoodData) -> Event {
        var parameters: [String: AnyHashable] = [:]

        parameters["event_category"] = "likelihood_scoring"
        parameters["event_action"] = "likelihoodScoring"
        parameters["supplier_app_id"] = supplierData.supplierAppId
        parameters["paywall_supplier"] = supplierData.paywallSupplier
        parameters["source_dx"] = contentMetadata?.dxParameter
        parameters["source_publication_uuid"] = contentMetadata?.publicationId
        parameters["event_details"] = likelihoodData.jsonString
        parameters["RDLCN"] = contentMetadata?.rdlcnParameter

        return createPaidEvent(parameters: parameters)
    }

    func createMobileAppFakeUserIdReplacedEvent(temporaryUserId: String,
                                                realUserId: String) -> Event {
        var parameters: [String: AnyHashable] = [:]

        parameters["event_category"] = "mobile_app_fake_user_id_replaced"
        parameters["event_action"] = "mobileAppFakeUserIdReplaced"
        parameters["event_details"] = EventDetails(fakeUserId: temporaryUserId, realUserId: realUserId).jsonString

        return createPaidEvent(parameters: parameters)
    }
}
