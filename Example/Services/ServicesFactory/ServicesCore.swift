//
//  ServicesCore.swift
//  Example
//
//  Created by Короткий Виталий on 06.12.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

struct ServicesCore {
    let userIdProvider: UserIdProvider
    let apiClient: ServiceProvider<APIClient>
}

extension ServicesCore {
    static func makeDefault() -> Self {
        let userIdProvider = UserIdProvider()
        
        let apiClient = APIClientFactory(
            userIdProvider: userIdProvider
        ).serviceProvider()
        
        return .init(
            userIdProvider: userIdProvider,
            apiClient: apiClient
        )
    }
}
