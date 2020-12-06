//
//  APIClientFactory.swift
//  Example
//
//  Created by Короткий Виталий on 29.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

struct APIClientFactory: ServiceFactory {
    let userIdProvider: APIUserIdProvider
    
    let mode: ServiceFactoryMode = .atOne
    func makeService() throws -> APIClient {
        return APIMockClient(userIdProvider: userIdProvider)
    }
}
