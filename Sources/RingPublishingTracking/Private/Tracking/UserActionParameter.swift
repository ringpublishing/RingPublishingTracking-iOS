//
//  UserActionParameter.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 12/10/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

/// User action parameter enum used for an UserActionEvent
enum UserActionParameter {

    case parameters([String: AnyHashable])
    case plain(String?)
}
