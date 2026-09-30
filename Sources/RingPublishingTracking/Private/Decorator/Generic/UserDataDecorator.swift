//
//  UserDataDecorator.swift
//  RingPublishingTracking-Example
//
//  Created by Artur Rymarz on 04/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

private let userDataParameterName = "RDLU"

final class UserDataDecorator: Decorator {

    private lazy var encoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }()

    private var data: UserData = UserData()

    var sso: SSO? {
        return data.sso
    }

    var parameters: [String: AnyHashable] {
        var userDataParams: [String: AnyHashable] = [:]

        // RDLU
        if let rdlu = prepareRDLU(data: data) {
            userDataParams[userDataParameterName] = rdlu.base64EncodedString()
        }

        // IZ
        if let userId = data.sso?.logged.id, data.ssoSystemName == Constants.raspSsoSystemName {
            userDataParams["IZ"] = userId
        }

        return userDataParams
    }
}

extension UserDataDecorator {

    func updateUserData(userId: String?, email: String?) {
        data.userId = userId
        data.email = email
    }

    func updateSSO(ssoSystemName: String?) {
        data.ssoSystemName = ssoSystemName
    }

    func updateArtemisData(artemis: ArtemisID?) {
        data.id = artemis
    }

    func updateActiveSubscriber(_ isActiveSubscriber: Bool?) {
        data.isActiveSubscriber = isActiveSubscriber
    }
}

private extension UserDataDecorator {

    func prepareRDLU(data: UserData?) -> Data? {
        guard let data = data, data.sso != nil || data.id != nil else { return nil }

        return try? encoder.encode(data)
    }
}

// MARK: - Completing the user data of a decorated event
extension Event {

    /// Whether the user data (`RDLU`) of the event carries the Artemis identifier
    var carriesArtemisID: Bool {
        userData?[UserData.CodingKeys.id.rawValue] != nil
    }

    /// Returns the event with the Artemis identifier added to its user data (`RDLU`).
    /// Every other field of the user data keeps the value the event was decorated with.
    ///
    /// - Parameter artemisID: Artemis identifier which was not known yet when the event was decorated
    /// - Returns: `Event`
    func addingArtemisID(_ artemisID: ArtemisID) -> Event {
        guard !carriesArtemisID,
              let artemisData = try? JSONEncoder().encode(artemisID),
              let artemisObject = try? JSONSerialization.jsonObject(with: artemisData) else {
            return self
        }

        var completedUserData = userData ?? [:]
        completedUserData[UserData.CodingKeys.id.rawValue] = artemisObject

        guard let userDataJSON = try? JSONSerialization.data(withJSONObject: completedUserData, options: .sortedKeys) else {
            return self
        }

        var parameters = eventParameters
        parameters[userDataParameterName] = userDataJSON.base64EncodedString()

        return Event(analyticsSystemName: analyticsSystemName, eventName: eventName, eventParameters: parameters)
    }
}

private extension Event {

    var userData: [String: Any]? {
        guard let value = eventParameters[userDataParameterName] as? String, let data = Data(base64Encoded: value) else {
            return nil
        }

        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}
