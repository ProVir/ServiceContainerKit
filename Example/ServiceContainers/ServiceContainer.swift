//
//  ServiceContainer.swift
//  Example
//
//  Created by Короткий Виталий on 28.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

/// DI Continer for swift
struct ServiceContainer {
    struct Second {
        let secondServiceProvider: ServiceParamsProvider<SecondService, SecondServiceParams?>
        let numberParamsProvider: ServiceParamsProvider<NumberService, SecondServiceParams>
        let secondServiceNumber0Provider: ServiceProvider<SecondService>
    }
    
    let second: Second
    
    let singletonServiceProvider: ServiceProvider<SingletonService>
    let lazyServiceProvider: ServiceProvider<LazyService>
    
    let firstServiceProvider: ServiceProvider<FirstService>
    let secondServiceProvider: ServiceParamsProvider<SecondService, SecondServiceParams?>
    let numberParamsProvider: ServiceParamsProvider<NumberService, SecondServiceParams>
    
    let sharedFirstService: FirstService
    let secondServiceNumber0Provider: ServiceProvider<SecondService>
    let numberProvider: ServiceProvider<NumberService>

    let userMediator: ServiceSessionMediator<UserSession>
    let sessionSingletonServiceProvider: ServiceProvider<SingletonService>
}

/// DI Container for ObjC
@objc(ServiceContainer)
class ServiceContainerObjC: NSObject {
    init(container: ServiceContainer) {
        firstServiceProvider = ServiceProviderObjC(container.firstServiceProvider)
        sharedFirstService = container.sharedFirstService
        
        super.init()
    }
    
    @objc let firstServiceProvider: ServiceProviderObjC
    @objc let sharedFirstService: FirstService
}

//MARK: Setup
extension ServiceContainer {
    static func createDefault() -> ServiceContainer {
        let singletonServiceProvider = SingletonServiceFactory().serviceProvider()
        let lazyServiceProvider = ServiceProvider(factory: LazyServiceFactory())

        let firstServiceProvider = FirstServiceFactory(singletonServiceProvider: singletonServiceProvider).serviceProvider()
        let secondServiceProvider = SecondServiceFactory(lazyServiceProvider: lazyServiceProvider,
                                                         firstServiceProvider: firstServiceProvider).serviceProvider()

        let sharedFirstService: FirstService = firstServiceProvider.getServiceOrFatal()
        let secondServiceNumber0Provider = secondServiceProvider.convert(params: .init(number: 0))
        let numberProvider = ServiceProvider<NumberService> { try secondServiceNumber0Provider.getService() }
        let numberParamsProvider = ServiceParamsProvider<NumberService, SecondServiceParams> { try secondServiceProvider.getService(params: $0) }

        let userMediator = ServiceSessionMediator<UserSession>(session: .init(userId: 0))
        let sessionSingletonServiceProvider = SingletonServiceSessionFactory().serviceProvider(mediator: userMediator)
        
        let secondConatainer = ServiceContainer.Second(
            secondServiceProvider: secondServiceProvider,
            numberParamsProvider: numberParamsProvider,
            secondServiceNumber0Provider: secondServiceNumber0Provider
        )
        
        return ServiceContainer(second: secondConatainer,
                                singletonServiceProvider: singletonServiceProvider,
                                lazyServiceProvider: lazyServiceProvider,
                                firstServiceProvider: firstServiceProvider,
                                secondServiceProvider: secondServiceProvider,
                                numberParamsProvider: numberParamsProvider,
                                sharedFirstService: sharedFirstService,
                                secondServiceNumber0Provider: secondServiceNumber0Provider,
                                numberProvider: numberProvider,
                                userMediator: userMediator,
                                sessionSingletonServiceProvider: sessionSingletonServiceProvider)
    }
}
