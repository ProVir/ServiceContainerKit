//
//  ServicesFactory.swift
//  Example
//
//  Created by Короткий Виталий on 06.12.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

enum ServicesFactory {
    static func makeDefault() -> (Services, AppDelegateServices) {
        let core = ServicesCore.makeDefault()
        
        let user = Services.User.makeDefault(core: core)
        let folders = Services.Folders.makeDefault(core: core, user: user)
        let notes = Services.Notes.makeDefault(core: core, user: user, folders: folders)
        
        let services = Services(
            user: user,
            folders: folders,
            notes: notes
        )
        let appDelegateService = AppDelegateServices(
            userService: user.userService.getServiceOrFatal()
        )
        return (services, appDelegateService)
    }
}
