//
//  ServicesUser.swift
//  Example
//
//  Created by Короткий Виталий on 05.12.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

extension Services.User {
    static func makeDefault(core: ServicesCore) -> Self {
        let userService = UserServiceFactory(
            apiClient: core.apiClient,
            userIdProvider: core.userIdProvider
        ).serviceProvider()
        
        return .init(userService: userService)
    }
}
