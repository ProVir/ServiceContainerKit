//
//  LazyServiceFactory.swift
//  Example
//
//  Created by Короткий Виталий on 28.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

/// Variant key 3 - used static variable in service
extension LazyService {
    static var locatorKey: ServiceLocatorEasyKey<LazyService> { return .init() }
}

struct LazyServiceFactory: ServiceFactory {
    let mode: ServiceFactoryMode = .lazy
    
    func makeService() throws -> LazyService {
        let instance = LazyService()
        
        instance.value = "Created: \(Date())"
        
        return instance
    }
}
