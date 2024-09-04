//
//  EventsFactory+Paid.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 04/09/2024.
//

import Foundation

extension EventsFactory {
    
    func createShowOfferEvent(contentMetadata: ContentMetadata?, 
                              offerData: OfferData,
                              offerContextData: OfferContextData,
                              targetPromotionCampaignCode: String?) -> Event {
        var parameters: [PaidEventParameter: Any] = [:]

        parameters[.eventCategory] = "checkout"
        parameters[.eventAction] = "showOffer"
        parameters[.supplierAppId] = offerData.supplierData.supplierAppId
        parameters[.paywallSupplier] = offerData.supplierData.paywallSupplier
        parameters[.paywallTemplateId] = offerData.paywallTemplateId
        parameters[.displayMode] = offerData.displayMode.rawValue
        parameters[.source] = offerContextData.source

        if let contentMetadata = contentMetadata {
            parameters[.sourceDx] = contentMetadata.dxParameter
            parameters[.sourcePublicationUuid] = contentMetadata.publicationId
        }

        if let paywallVariantId = offerData.paywallVariantId {
            parameters[.paywallVariantId] = paywallVariantId
        }

        if let closurePercentage = offerContextData.closurePercentage {
            parameters[.closurePercentage] = closurePercentage
        }

        if let targetPromotionCampaignCode = targetPromotionCampaignCode {
            parameters[.tpcc] = targetPromotionCampaignCode
        }

            parameters[.rdlcn] = contentMetadata?.

        return createPaidEvent(parameters: parameters.keysAsStrings)
    }

}
