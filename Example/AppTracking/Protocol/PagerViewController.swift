//
//  PagerViewController.swift
//  AppTracking-Example
//
//  Created by Adam Szeremeta on 17/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation
import UIKit

protocol PagerViewController where Self: UIViewController {

    var pageIndex: Int { get }
}
