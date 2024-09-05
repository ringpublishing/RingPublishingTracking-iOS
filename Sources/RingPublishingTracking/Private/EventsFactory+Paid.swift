//
//  EventsFactory+Paid.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//

import Foundation

extension EventsFactory {

    func createPaidEvent(parameters: [String: AnyHashable]) -> Event {
        return Event(analyticsSystemName: AnalyticsSystem.kropkaEvents.rawValue,
                     eventName: EventType.paid.rawValue,
                     eventParameters: parameters)
    }

    func createShowOfferEvent(contentMetadata: ContentMetadata?,
                              offerData: OfferData,
                              offerContextData: OfferContextData,
                              targetPromotionCampaignCode: String?) -> Event {
        var parameters: [PaidEventParameter: AnyHashable] = [:]

        parameters[.eventCategory] = "checkout"
        parameters[.eventAction] = "showOffer"
        parameters[.supplierAppId] = offerData.supplierData.supplierAppId
        parameters[.paywallSupplier] = offerData.supplierData.paywallSupplier
        parameters[.paywallTemplateId] = offerData.paywallTemplateId
        parameters[.displayMode] = offerData.displayMode.rawValue
        parameters[.source] = offerContextData.source
        parameters[.sourceDx] = contentMetadata?.dxParameter
        parameters[.sourcePublicationUuid] = contentMetadata?.publicationId
        parameters[.paywallVariantId] = offerData.paywallVariantId
        parameters[.closurePercentage] = offerContextData.closurePercentage
        parameters[.tpcc] = targetPromotionCampaignCode
        parameters[.contentMarkedAsPaid] = contentMetadata?.rdlcnParameter

        return createPaidEvent(parameters: parameters.keysAsStrings)
    }

    func createShowOfferTeaserEvent(contentMetadata: ContentMetadata?,
                                    offerData: OfferData,
                                    offerContextData: OfferContextData,
                                    targetPromotionCampaignCode: String?) -> Event {
        var parameters: [PaidEventParameter: AnyHashable] = [:]

        parameters[.eventCategory] = "checkout"
        parameters[.eventAction] = "showOfferTeaser"
        parameters[.supplierAppId] = offerData.supplierData.supplierAppId
        parameters[.paywallSupplier] = offerData.supplierData.paywallSupplier
        parameters[.paywallTemplateId] = offerData.paywallTemplateId
        parameters[.displayMode] = offerData.displayMode.rawValue
        parameters[.source] = offerContextData.source
        parameters[.sourceDx] = contentMetadata?.dxParameter
        parameters[.sourcePublicationUuid] = contentMetadata?.publicationId
        parameters[.paywallVariantId] = offerData.paywallVariantId
        parameters[.closurePercentage] = offerContextData.closurePercentage
        parameters[.tpcc] = targetPromotionCampaignCode
        parameters[.contentMarkedAsPaid] = contentMetadata?.rdlcnParameter

        return createPaidEvent(parameters: parameters.keysAsStrings)
    }

    func createPurchaseClickButtonEvent(contentMetadata: ContentMetadata?,
                                        offerData: OfferData,
                                        offerContextData: OfferContextData,
                                        termId: String,
                                        targetPromotionCampaignCode: String?) -> Event {
        var parameters: [PaidEventParameter: AnyHashable] = [:]

        parameters[.eventCategory] = "checkout"
        parameters[.eventAction] = "clickButton"
        parameters[.supplierAppId] = offerData.supplierData.supplierAppId
        parameters[.paywallSupplier] = offerData.supplierData.paywallSupplier
        parameters[.paywallTemplateId] = offerData.paywallTemplateId
        parameters[.displayMode] = offerData.displayMode.rawValue
        parameters[.source] = offerContextData.source
        parameters[.termId] = termId
        parameters[.sourceDx] = contentMetadata?.dxParameter
        parameters[.sourcePublicationUuid] = contentMetadata?.publicationId
        parameters[.paywallVariantId] = offerData.paywallVariantId
        parameters[.tpcc] = targetPromotionCampaignCode
        parameters[.contentMarkedAsPaid] = contentMetadata?.rdlcnParameter

        return createPaidEvent(parameters: parameters.keysAsStrings)
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
        var parameters: [PaidEventParameter: AnyHashable] = [:]

        parameters[.eventCategory] = "checkout"
        parameters[.eventAction] = "purchase"
        parameters[.supplierAppId] = offerData.supplierData.supplierAppId
        parameters[.paywallSupplier] = offerData.supplierData.paywallSupplier
        parameters[.paywallTemplateId] = offerData.paywallTemplateId
        parameters[.displayMode] = offerData.displayMode.rawValue
        parameters[.source] = offerContextData.source
        parameters[.termId] = termId
        parameters[.termConversionId] = termConversionId
        parameters[.paymentMethod] = subscriptionPaymentData.paymentMethod.rawValue
        parameters[.subscriptionBasePrice] = subscriptionPaymentData.subscriptionBasePrice
        parameters[.subscriptionPriceCurrency] = subscriptionPaymentData.subscriptionPriceCurrency
        parameters[.sourceDx] = contentMetadata?.dxParameter
        parameters[.sourcePublicationUuid] = contentMetadata?.publicationId
        parameters[.paywallVariantId] = offerData.paywallVariantId
        parameters[.tpcc] = targetPromotionCampaignCode
        parameters[.subscriptionPromoPrice] = subscriptionPaymentData.subscriptionPromoPrice
        parameters[.subscriptionPromoPriceDuration] = subscriptionPaymentData.subscriptionPromoPriceDuration
        parameters[.eventDetails] = PaidEventUserId(fakeUserId: temporaryUserId, realUserId: nil).jsonString
        parameters[.contentMarkedAsPaid] = contentMetadata?.rdlcnParameter

        return createPaidEvent(parameters: parameters.keysAsStrings)
    }

    // swiftlint:enable function_parameter_count

    func createShowMetricLimitEvent(contentMetadata: ContentMetadata?,
                                    supplierData: SupplierData,
                                    metricsData: MetricsData) -> Event {
        var parameters: [PaidEventParameter: AnyHashable] = [:]

        parameters[.eventCategory] = "metric_limit"
        parameters[.eventAction] = "showMetricLimit"
        parameters[.supplierAppId] = supplierData.supplierAppId
        parameters[.paywallSupplier] = supplierData.paywallSupplier
        parameters[.metricLimitName] = metricsData.metricLimitName
        parameters[.freePvCnt] = metricsData.freePageViewCount
        parameters[.freePvLimit] = metricsData.freePageViewLimit
        parameters[.sourceDx] = contentMetadata?.dxParameter
        parameters[.sourcePublicationUuid] = contentMetadata?.publicationId
        parameters[.contentMarkedAsPaid] = contentMetadata?.rdlcnParameter

        return createPaidEvent(parameters: parameters.keysAsStrings)
    }

    func createLikelihoodScoringEvent(contentMetadata: ContentMetadata?,
                                      supplierData: SupplierData,
                                      likelihoodData: LikelihoodData) -> Event {
        var parameters: [PaidEventParameter: AnyHashable] = [:]

        parameters[.eventCategory] = "likelihood_scoring"
        parameters[.eventAction] = "likelihoodScoring"
        parameters[.supplierAppId] = supplierData.supplierAppId
        parameters[.paywallSupplier] = supplierData.paywallSupplier
        parameters[.sourceDx] = contentMetadata?.dxParameter
        parameters[.sourcePublicationUuid] = contentMetadata?.publicationId
        parameters[.eventDetails] = likelihoodData.jsonString
        parameters[.contentMarkedAsPaid] = contentMetadata?.rdlcnParameter

        return createPaidEvent(parameters: parameters.keysAsStrings)
    }

    func createMobileAppFakeUserIdReplacedEvent(contentMetadata: ContentMetadata?,
                                                temporaryUserId: String,
                                                realUserId: String) -> Event {
        var parameters: [PaidEventParameter: AnyHashable] = [:]

        parameters[.eventCategory] = "mobile_app_fake_user_id_replaced"
        parameters[.eventAction] = "mobileAppFakeUserIdReplaced"
        parameters[.eventDetails] = PaidEventUserId(fakeUserId: temporaryUserId, realUserId: realUserId).jsonString
        parameters[.contentMarkedAsPaid] = ContentMarkAsPaid(contentMetadata: contentMetadata)?.jsonStringBase64

        return createPaidEvent(parameters: parameters.keysAsStrings)
    }

}
