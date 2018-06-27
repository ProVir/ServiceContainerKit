//
//  FirstServiceFactory.swift
//  Example
//
//  Created by Короткий Виталий on 28.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

struct FirstServiceFactory: ServiceFactory {
    let singletonServiceProvider: ServiceProvider<SingletonService>
    
    let factoryType: ServiceFactoryType = .many
    func createService() throws -> FirstService {
        return FirstService(singletonService: try singletonServiceProvider.tryService())
    }
}
