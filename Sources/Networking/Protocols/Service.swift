//
//  Service.swift
//  Service
//
//  Created by Artur Rymarz on 13/09/2021.
//  Copyright © 2021 Ringier Axel Springer Tech. All rights reserved.
//

import Foundation

protocol Service {
    
    func call<T: Endpoint>(_ endpoint: T, completion: @escaping (Result<T.Response, ServiceError>) -> Void)
}
