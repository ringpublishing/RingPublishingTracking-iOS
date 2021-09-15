//
//  IdentityResponse.swift
//  IdentityResponse
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

struct IdentityResponse: Decodable {
    
    let ids: [String: IdsWithLifetime]
    let profile: Profile
    let postInterval: Int
}
