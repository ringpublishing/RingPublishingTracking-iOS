//
//  String+UUID.swift
//  RingPublishingTracking
//
//  Created by Bernard Bijoch on 06/11/2024.
//

import Foundation

extension String {
    func uuidValidation() -> String? {
        UUID(uuidString: self) != nil ? self : nil
    }
}
