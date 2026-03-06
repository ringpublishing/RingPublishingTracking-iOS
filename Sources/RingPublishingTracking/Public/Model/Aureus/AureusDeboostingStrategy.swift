//
//  AureusDeboostingStrategy.swift
//  RingPublishingTracking
//
//  Created by Adam Szeremeta on 05/03/2026.
//

import Foundation

/// Aureus deboosting strategy
public enum AureusDeboostingStrategy: String {

    /// User was engaged with content
    case click

    /// User saw content multiple times but never interacted with it
    case view
}
