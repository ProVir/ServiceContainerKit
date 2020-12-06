//
//  ServicesFolders.swift
//  Example
//
//  Created by Короткий Виталий on 05.12.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

extension Services.Folders {
    static func makeDefault(core: ServicesCore, user: Services.User) -> Self {
        let manager = NoteFoldersManagerFactory(
            apiClient: core.apiClient,
            userService: user.userService
        ).serviceProvider()
        
        return .init(manager: manager)
    }
}
