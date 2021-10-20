//
//  VendorIdentifiable.swift
//  RingPublishingTracking
//
//  Created by Artur Rymarz on 27/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit

protocol VendorIdentifiable {

    var identifierForVendor: UUID? { get }
}

extension UIDevice: VendorIdentifiable {}
