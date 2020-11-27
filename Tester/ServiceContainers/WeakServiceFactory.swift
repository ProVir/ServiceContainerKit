//
//  WeakServiceFactory.swift
//  Example
//
//  Created by Короткий Виталий on 16.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

struct WeakServiceFactory: ServiceFactory {
    let mode: ServiceFactoryMode = .weak
    
    func makeService() throws -> WeakService {
        return WeakServiceImpl()
    }
}

struct WeakServiceSessionFactory: ServiceSessionFactory {
    let mode: ServiceSessionFactoryMode = .weak
    
    func activateService(_ service: WeakServiceImpl, session: UserSession) {
        service.value = "UserId: \(session.userId) ENABLED"
    }
    
    func deactivateService(_ service: WeakServiceImpl, session: UserSession) -> Bool {
        service.value = "UserId: \(session.userId) DISABLED"
        return true
    }
    
    func makeService(session: UserSession) throws -> WeakServiceImpl {
        let service = WeakServiceImpl()
        service.value = "UserId: \(session.userId)"
        return service
    }
}
