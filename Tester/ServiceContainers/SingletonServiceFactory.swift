//
//  SingletonServiceFactory.swift
//  Example
//
//  Created by Короткий Виталий on 28.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit
import ExampleServiceLocators

/// Variant key 2 - used typealias
typealias SingletonServiceLocatorKey = ServiceLocatorSimpleKey<SingletonService>

struct SingletonServiceFactory: ServiceFactory {
    let mode: ServiceFactoryMode = .atOne
    
    func makeService() throws -> SingletonService {
        let instance = SingletonService()
        
        instance.value = "created in factory as singleton"
        
        return instance
    }
}
