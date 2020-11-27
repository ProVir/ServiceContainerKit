//
//  ServiceLocator.swift
//  Example
//
//  Created by Короткий Виталий on 28.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

@objc protocol FirstServiceShared: NSObjectProtocol { }
extension FirstService: FirstServiceShared { }

/// Variant key 1 - Static store keys in empty enum
enum ServiceLocatorKeys {
    static let singletonService = SingletonServiceFactory.defaultKey
    static let lazyService = LazyServiceFactory.defaultKey
    static let firstService = FirstServiceFactory.defaultKey
    static let firstServiceShared = FirstServiceFactory.sharedKey
    static let secondService = SecondServiceFactory.defaultKey
}

extension ServiceLocatorObjCKey {
    @objc static var firstService: ServiceLocatorObjCKey { return .init(ServiceLocatorKeys.firstService) }
    @objc static var firstServiceShared: ServiceLocatorObjCKey { return .init(ServiceLocatorKeys.firstServiceShared) }
}

extension ServiceLocator {
    static func createDefault() -> ServiceLocator {
        //Create services providers
        let singletonServiceProvider = SingletonServiceFactory().serviceProvider()
        let lazyServiceProvider = LazyServiceFactory().serviceProvider()
        
        let firstServiceProvider = FirstServiceFactory(singletonServiceProvider: singletonServiceProvider).serviceProvider()
        
        let secondServiceProvider = SecondServiceFactory(lazyServiceProvider: lazyServiceProvider,
                                                         firstServiceProvider: firstServiceProvider).serviceProvider()
        
        let sharedFirstService: FirstService = firstServiceProvider.getServiceOrFatal()
        
        //Setup ServiceLocator
        let serviceLocator = ServiceLocator()
        
//      serviceLocator.addService(key: ServiceLocatorKeys.singletonService, provider: singletonServiceProvider) //Variant 1
        serviceLocator.addService(key: SingletonServiceLocatorKey(), provider: singletonServiceProvider) //Variant 2
        
//      serviceLocator.addService(key: ServiceLocatorKeys.lazyService, provider: lazyServiceProvider) //Variant 1
        serviceLocator.addService(key: LazyService.locatorKey, provider: lazyServiceProvider) //Variant 3
        
        serviceLocator.addService(key: ServiceLocatorKeys.firstService, provider: firstServiceProvider)
        serviceLocator.addService(key: ServiceLocatorKeys.secondService, provider: secondServiceProvider)
        
        serviceLocator.addService(key: ServiceLocatorKeys.firstServiceShared, service: sharedFirstService)
        
        serviceLocator.setReadOnly()
        return serviceLocator
    }
}

extension ServiceLocatorObjC {
    @objc static func createDefault() -> ServiceLocatorObjC {
        return .init(.createDefault())
    }
}

extension ServiceSimpleLocator {
    static func setupSharedDefault() {
        //Create services providers
        let singletonServiceProvider = SingletonServiceFactory().serviceProvider()
        let lazyServiceProvider = LazyServiceFactory().serviceProvider()
        
        let firstServiceProvider = FirstServiceFactory(singletonServiceProvider: singletonServiceProvider).serviceProvider()
        
        let secondServiceProvider = SecondServiceFactory(lazyServiceProvider: lazyServiceProvider,
                                                         firstServiceProvider: firstServiceProvider).serviceProvider()
        
        let sharedFirstService: FirstService = firstServiceProvider.getServiceOrFatal()
        
        //Setup ServiceLocator
        let serviceLocator = ServiceSimpleLocator()
        
        serviceLocator.addService(provider: singletonServiceProvider)
        serviceLocator.addService(provider: lazyServiceProvider)
        serviceLocator.addService(provider: firstServiceProvider)
        serviceLocator.addService(provider: secondServiceProvider)
        
        // Get shared use protocol: let service = (serviceLocator.getService() as FirstServiceShared?) as! FirstService
        serviceLocator.addService(sharedFirstService as FirstServiceShared)
        
        serviceLocator.setReadOnly()
        ServiceSimpleLocator.setupShared(serviceLocator, readOnlySharedAfter: true)
    }
}

