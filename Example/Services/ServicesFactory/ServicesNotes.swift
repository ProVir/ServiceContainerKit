//
//  ServicesNotes.swift
//  Example
//
//  Created by Короткий Виталий on 05.12.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

extension Services.Notes {
    static func makeDefault(core: ServicesCore, user: Services.User, folders: Services.Folders) -> Self {
        let manager = NoteRecordsManagerFactory(
            apiClient: core.apiClient,
            userService: user.userService
        ).serviceProvider()
        
        let editService = NoteRecordEditServiceFactory(
            apiClient: core.apiClient,
            recordsManager: manager
        ).serviceProvider()
        
        return .init(manager: manager, editService: editService)
    }
}
