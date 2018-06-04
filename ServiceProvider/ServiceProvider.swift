//
//  ServiceProvider.swift
//  ServiceProvider 1.0.0
//
//  Created by Короткий Виталий (ViR) on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation


/// ServiceProvider with information for create service (static or factory)
public struct ServiceProvider<T> {
    private enum Storage {
        case simple(T)
        case factory(ServiceCoreFactory)
    }
    
    private let storage: Storage
    
    public init(_ service: T) {
        self.storage = Storage.simple(service)
    }
    
    public init<FactoryType: ServiceFactory>(factory: FactoryType) where FactoryType.TypeService == T {
        self.storage = Storage.factory(factory)
    }
    
    public init(lazy: @escaping () throws -> T) {
        self.storage = Storage.factory(ServiceClosureFactory(closureFactory: { _ -> T in
            try lazy()
        }, lazyRegime: true))
    }
    
    public init(factory closure:@escaping (ServiceFactorySettings?) throws ->T) {
        self.storage = Storage.factory(ServiceClosureFactory(closureFactory: closure, lazyRegime: false))
    }
    
    
    public func tryService(settings: ServiceFactorySettings? = nil) throws -> T {
        switch storage {
        case .simple(let service):
            return service
            
        case .factory(let factory):
            if let service = try factory.coreCreateService(settings: settings) as? T {
                return service
            } else {
                fatalError("Created service with invalid type. Use only createService(), you can not use coreCreateService().")
            }
        }
    }
    
    public func getService(settings: ServiceFactorySettings? = nil) -> T? {
        return try? tryService(settings: settings)
    }
}

public extension ServiceFactory {
    func createServiceProvider() -> ServiceProvider<TypeService> {
        return ServiceProvider<TypeService>.init(factory: self)
    }
}
