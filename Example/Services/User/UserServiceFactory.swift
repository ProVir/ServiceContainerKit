//
//  UserServiceFactory.swift
//  Example
//
//  Created by Короткий Виталий on 30.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

struct UserServiceFactory: ServiceFactory {
    let apiClient: ServiceProvider<APIClient>
    let userIdProvider: UserIdProvider
    
    let mode: ServiceFactoryMode = .atOne
    func makeService() throws -> UserService {
        let service = UserServiceImpl(apiClient: try apiClient.getService())
        userIdProvider.userService = service
        return service
    }
}
