//
//  SecondServiceFactory.swift
//  Example
//
//  Created by Короткий Виталий on 28.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

struct SecondServiceParams {
    let number: Int
}

//Support params for ServiceLocator (not optional).
extension SecondService: ServiceSupportFactoryParams {
    typealias ParamsType = SecondServiceParams
}

struct SecondServiceFactory: ServiceParamsFactory {
    let lazyServiceProvider: ServiceProvider<LazyService>
    let firstServiceProvider: ServiceProvider<FirstService>
    
    /// Optional params for support get service without params in ServiceLocator. 
    func createService(params: SecondServiceParams?) throws -> SecondService {
        let instance = SecondService(lazyService: try lazyServiceProvider.tryService(),
                                     firstService: try firstServiceProvider.tryService())
        
        instance.number = params?.number ?? -1
        
        return instance
    }
}
