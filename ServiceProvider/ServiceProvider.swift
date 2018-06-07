//
//  ServiceProvider.swift
//  ServiceProvider 1.0.0
//
//  Created by Короткий Виталий (ViR) on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

public extension ServiceFactory {
    func createServiceProvider() -> ServiceProvider<TypeService> {
        return ServiceProvider<TypeService>.init(factory: self)
    }
}

/// ServiceProvider with information for create service (static or factory)
public struct ServiceProvider<T> {
    
    public init(_ service: T) {
        self.storage = Storage.single(service)
    }
    
    public init<FactoryType: ServiceFactory>(tryFactory factory: FactoryType) throws where FactoryType.TypeService == T {
        self.storage = try ServiceProvider.createStorage(factory: factory)
    }
    
    public init<FactoryType: ServiceFactory>(factory: FactoryType) where FactoryType.TypeService == T {
        do {
            self.storage = try ServiceProvider.createStorage(factory: factory)
        } catch {
            self.storage = Storage.singleError(error)
        }
    }
    
    public init(lazy: @escaping () throws -> T) {
        self.storage = Storage.factory(ServiceClosureLazyFactory(closureFactory: lazy))
    }
    
    public init(factory closure:@escaping (ServiceFactorySettings?) throws ->T) {
        self.storage = Storage.factory(ServiceClosureFactory(closureFactory: closure))
    }
    
    public func tryService(settings: ServiceFactorySettings? = nil) throws -> T {
        switch storage {
            // Return single instance
        case .single(let service):
            return service
            
        case .singleError(let error):
            throw error
            
            // Lazy service
        case .lazy(let lazy):
            if let service = lazy.instance {
                return service
            } else if let factory = lazy.factory {
                if let service = try factory.coreCreateService(settings: nil) as? T {
                    lazy.instance = service
                    lazy.factory = nil
                    
                    return service
                } else {
                    fatalError("Created service with invalid type. Use only createService(), you can not use coreCreateService().")
                }
            } else {
                fatalError()
            }
            
            //Multiple service
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
    
    //MARK: - Private
    private enum Storage {
        case single(T)
        case lazy(Lazy)
        case factory(ServiceCoreFactory)
        case singleError(Error)
    }
    
    private class Lazy {
        var factory: ServiceCoreFactory?
        var instance: T?
    }
    
    private let storage: Storage
    
    
    private static func createStorage<FactoryType: ServiceFactory>(factory: FactoryType) throws -> Storage where FactoryType.TypeService == T {
        switch factory.factoryType {
        case .single:
            if let service = try factory.coreCreateService(settings: nil) as? T {
                return Storage.single(service)
            } else {
                fatalError("Created service with invalid type. Use only createService(), you can not use coreCreateService().")
            }
            
        case .lazy:
            let lazy = Lazy()
            lazy.factory = factory
            return Storage.lazy(lazy)
            
        case .multiple:
            return Storage.factory(factory)
        }
    }
}
