//
//  SessionServiceFactory.swift
//  Example
//
//  Created by Vitalii Korotkii on 05.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

struct UserSession: ServiceSession {
    let userId: Int

    var key: AnyHashable { return userId }
}

struct SingletonServiceSessionFactory: ServiceSessionFactory {
    let isLazy = false

    func deactivateService(_ service: SingletonService, session: UserSession) -> Bool {
        print("> deactivateService SingletonService, userId = \(session.userId)")
        service.value = "userId = \(session.userId), deactivated"
        return true
    }

    func activateService(_ service: SingletonService, session: UserSession) {
        print("> activateService SingletonService, userId = \(session.userId)")
        service.value = "userId = \(session.userId), activated"
    }

    func makeService(session: UserSession) throws -> SingletonService {
        print("> makeService SingletonService, userId = \(session.userId)")
        let service = SingletonService()
        service.value = "userId = \(session.userId), maked"
        return service
    }
}
