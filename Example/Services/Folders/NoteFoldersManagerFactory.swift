//
//  NoteFoldersManagerFactory.swift
//  Example
//
//  Created by Короткий Виталий on 30.11.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

struct NoteFoldersManagerFactory: ServiceFactory {
    let apiClient: ServiceProvider<APIClient>
    let userService: ServiceProvider<UserService>
    
    let mode: ServiceFactoryMode = .lazy
    func makeService() throws -> NoteFoldersManager {
        return NoteFoldersManagerImpl(
            apiClient: try apiClient.getService(),
            userService: try userService.getService())
    }
}
