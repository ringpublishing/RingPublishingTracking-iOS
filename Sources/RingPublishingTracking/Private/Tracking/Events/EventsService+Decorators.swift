//
//  EventsService+Decorators.swift
//  
//
//  Created by Adam Mordavsky on 15.11.23.
//

import Foundation

extension EventsService {

    /// Registers decorator for decorating data parameters
    /// - Parameters:
    ///   - decorator: `Decorator`
    func registerDecorator(_ decorator: Decorator) {
        decorators.append(decorator)
    }

    /// Prepares event decorators
    func prepareDecorators() {
        // Generic
        registerDecorator(SizeDecorator())
        registerDecorator(uniqueIdentifierDecorator)
        registerDecorator(structureInfoDecorator)
        registerDecorator(adAreaDecorator)
        registerDecorator(userDataDecorator)
        registerDecorator(tenantIdentifierDecorator)
        registerDecorator(clientDecorator)
    }

    // MARK: - Decorators helpers

    func updateApplicationAdvertisementArea(_ currentAdvertisementArea: String) {
        adAreaDecorator.updateApplicationAdvertisementArea(applicationAdvertisementArea: currentAdvertisementArea)
    }

    func updateUserData(userId: String?, email: String?) {
        userDataDecorator.updateUserData(userId: userId, email: email)
    }

    func updateActiveSubscriber(_ isActiveSubscriber: Bool) {
        userDataDecorator.updateActiveSubscriber(isActiveSubscriber)
    }

    func updateSSO(ssoSystemName: String?) {
        userDataDecorator.updateSSO(ssoSystemName: ssoSystemName)
    }

    func updateUniqueIdentifier(partiallyReloaded: Bool) {
        if partiallyReloaded {
            uniqueIdentifierDecorator.updateSecondaryIdentifier()
        } else {
            uniqueIdentifierDecorator.updateIdentifiers()
        }
    }

    func updateTenantId(tenantId: String) {
        tenantIdentifierDecorator.updateTenantId(tenantId: tenantId)
    }

    func updateStructureType(structureType: StructureType, contentPageViewSource: ContentPageViewSource?) {
        structureInfoDecorator.updateStructureType(structureType: structureType, contentPageViewSource: contentPageViewSource)
    }

    func updateApplicationRootPath(applicationRootPath: String) {
        structureInfoDecorator.updateApplicationRootPath(applicationRootPath: applicationRootPath)
        adAreaDecorator.updateApplicationRootPath(applicationRootPath: applicationRootPath)
    }
}
