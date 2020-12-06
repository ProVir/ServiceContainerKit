//
//  Services.swift
//  Example
//
//  Created by Короткий Виталий on 05.12.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

struct Services {
    struct User {
        let userService: ServiceProvider<UserService>
    }
    
    struct Folders {
        let manager: ServiceProvider<NoteFoldersManager>
    }
    
    struct Notes {
        let manager: ServiceParamsProvider<NoteRecordsManager, NoteRecordsManagerParams>
        let editService: ServiceParamsProvider<NoteRecordEditService, NoteRecordEditServiceParams>
    }
    
    let user: User
    let folders: Folders
    let notes: Notes
}

struct AppDelegateServices {
    let userService: UserService
}
