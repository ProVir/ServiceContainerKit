//
//  ServiceLocator.swift
//  Example
//
//  Created by Короткий Виталий on 28.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

protocol FirstServiceShared { }
extension FirstService: FirstServiceShared { }


extension ServiceLocator {
    static func setupSharedDefault() {
        //Create services providers
        let singletonServiceProvider = SingletonServiceFactory().serviceProvider()
        let lazyServiceProvider = LazyServiceFactory().serviceProvider()
        
        let firstServiceProvider = FirstServiceFactory(singletonServiceProvider: singletonServiceProvider).serviceProvider()
        
        let secondServiceProvider = SecondServiceFactory(lazyServiceProvider: lazyServiceProvider,
                                                         firstServiceProvider: firstServiceProvider).serviceProvider()
        
        let sharedFirstService: FirstService = firstServiceProvider.getService()!
        
        //Setup ServiceLocator
        let serviceLocator = ServiceLocator()
        
        serviceLocator.addService(provider: singletonServiceProvider)
        serviceLocator.addService(provider: lazyServiceProvider)
        serviceLocator.addService(provider: firstServiceProvider)
        serviceLocator.addService(provider: secondServiceProvider)
        
        // Get shared use protocol: let service = (serviceLocator.getService() as FirstServiceShared?) as! FirstService
        serviceLocator.addService(sharedFirstService as FirstServiceShared)
        
        
        serviceLocator.setReadOnly()
        ServiceLocator.setupShared(serviceLocator: serviceLocator, readOnlySharedAfter: true)
    }
}
