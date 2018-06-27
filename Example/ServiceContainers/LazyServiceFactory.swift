//
//  LazyServiceFactory.swift
//  Example
//
//  Created by Короткий Виталий on 28.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

struct LazyServiceFactory: ServiceFactory {
    let factoryType: ServiceFactoryType = .lazy
    
    func createService() throws -> LazyService {
        let instance = LazyService()
        
        instance.value = "Created: \(Date())"
        
        return instance
    }
}
