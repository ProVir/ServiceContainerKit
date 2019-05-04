//
//  ServiceProvider.swift
//  ServiceContainerKit/ServiceProvider 2.0.0
//
//  Created by Короткий Виталий (ViR) on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

public extension ServiceFactory {
    /// Wrap the factory in ServiceProvider
    func serviceProvider() -> ServiceProvider<ServiceType> {
        return ServiceProvider<ServiceType>.init(factory: self)
    }
}

public extension ServiceParamsFactory {
    /// Wrap the factory in ServiceParamsProvider
    func serviceProvider() -> ServiceParamsProvider<ServiceType, ParamsType> {
        return ServiceParamsProvider<ServiceType, ParamsType>.init(factory: self)
    }
    
    /// Wrap the factory in ServiceProvider with specific params.
    func serviceProvider(params: ParamsType) -> ServiceProvider<ServiceType> {
        return ServiceProvider<ServiceType>.init(factory: self, params: params)
    }
}

/// ServiceProvider with information for create service (singleton or many instances)
public struct ServiceProvider<ServiceType> {
    fileprivate let storage: ServiceProviderStorage<ServiceType>
    
    /// ServiceProvider with at one instance services.
    public init(_ service: ServiceType) {
        self.storage = .atOne(service)
    }
    
    /// ServiceProvider with factory. If service factoryType == .atOne and throw error when create - throw this error from constructor.
    public init<FactoryType: ServiceFactory>(tryFactory factory: FactoryType) throws where FactoryType.ServiceType == ServiceType {
        self.storage = try ServiceProvider.tryCreateStorage(factory: factory)
    }
    
    /// ServiceProvider with factory.
    public init<FactoryType: ServiceFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType {
        self.storage = ServiceProvider.createStorage(factory: factory)
    }
    
    /// ServiceProvider with factory, use specific params.
    public init<FactoryType: ServiceParamsFactory>(factory: FactoryType, params: FactoryType.ParamsType) where FactoryType.ServiceType == ServiceType {
        self.storage = .factoryParams(factory, params)
    }
    
    /// ServiceProvider with lazy create service in closure.
    public init(lazy: @escaping () throws -> ServiceType) {
        self.storage = ServiceProvider.createStorage(factory: ServiceClosureFactory(closureFactory: lazy, lazyRegime: true))
    }
    
    /// ServiceProvider with many instance service type, create service in closure.
    public init(manyFactory: @escaping () throws -> ServiceType) {
        self.storage = ServiceProvider.createStorage(factory: ServiceClosureFactory(closureFactory: manyFactory, lazyRegime: false))
    }
    
    /// Get Service with detail information throwed error.
    public func tryService() throws -> ServiceType {
        return try internalTryService(params: Void())
    }
    
    /// Get Service if there are no errors.
    public func getService() -> ServiceType? {
        return try? internalTryService(params: Void())
    }
}

/// ServiceProvider with information for create service (static or factory)
public struct ServiceParamsProvider<ServiceType, ParamsType> {
    fileprivate let storage: ServiceProviderStorage<ServiceType>
    
    /// ServiceProvider with factory.
    public init<FactoryType: ServiceParamsFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType, FactoryType.ParamsType == ParamsType {
        self.storage = .factory(factory)
    }
    
    /// Get Service with detail information throwed error.
    public func tryService(params: ParamsType) throws -> ServiceType {
        return try internalTryService(params: params)
    }
    
    /// Get Service if there are no errors.
    public func getService(params: ParamsType) -> ServiceType? {
        return try? internalTryService(params: params)
    }
    
    /// Get ServiceProvider without params with specific params.
    public func convert(params: ParamsType) -> ServiceProvider<ServiceType> {
        switch storage {
        case .factory(let factory):
            return .init(coreFactory: factory, params: params)
        default:
            fatalError("Internal error: Invalid provider")
        }
    }
}

// MARK: - Private
private enum ServiceProviderStorage<ServiceType> {
    case atOne(ServiceType)
    case lazy(Lazy)
    case factory(ServiceCoreFactory)
    case factoryParams(ServiceCoreFactory, Any)
    case atOneError(Error)
    
    class Lazy {
        var factory: ServiceCoreFactory?
        var instance: ServiceType?
    }
}

// MARK: Private base functional for ServiceProvider and ServiceParamsProvider
private protocol ServiceProviderPrivate {
    associatedtype ServiceType
    var storage: ServiceProviderStorage<ServiceType> { get }
}

/// Private constructors for ServiceProvider
extension ServiceProvider: ServiceProviderPrivate {
    fileprivate init(coreFactory: ServiceCoreFactory, params: Any) {
        self.storage = .factoryParams(coreFactory, params)
    }
    
    private static func createStorage<FactoryType: ServiceFactory>(factory: FactoryType, params: Any = Void()) -> ServiceProviderStorage<ServiceType> where FactoryType.ServiceType == ServiceType {
        do {
            return try tryCreateStorage(factory: factory, params: params)
        } catch {
            return .atOneError(error)
        }
    }
    
    private static func tryCreateStorage<FactoryType: ServiceFactory>(factory: FactoryType, params: Any = Void()) throws -> ServiceProviderStorage<ServiceType> where FactoryType.ServiceType == ServiceType {
        switch factory.factoryType {
        case .atOne:
            if let service = try factory.coreCreateService(params: params) as? ServiceType {
                return .atOne(service)
            } else {
                throw ServiceProviderError.wrongService
            }
            
        case .lazy:
            let lazy = ServiceProviderStorage<ServiceType>.Lazy()
            lazy.factory = factory
            return .lazy(lazy)
            
        case .many:
            return .factory(factory)
        }
    }
}

extension ServiceParamsProvider: ServiceProviderPrivate { }

extension ServiceProviderPrivate {
    /// Get Services with core implementation
    fileprivate func internalTryService(params: Any) throws -> ServiceType {
        switch storage {
        // Return single instance
        case .atOne(let service):
            return service
            
        case .atOneError(let error):
            throw error
            
        // Lazy service
        case .lazy(let lazy):
            if let service = lazy.instance {
                return service
            } else if let factory = lazy.factory {
                if let service = try factory.coreCreateService(params: params) as? ServiceType {
                    lazy.instance = service
                    lazy.factory = nil
                    
                    return service
                } else {
                    throw ServiceProviderError.wrongService
                }
            } else {
                fatalError("ServiceProvider: Internal error")
            }
            
        //Multiple service
        case .factory(let factory):
            if let service = try factory.coreCreateService(params: params) as? ServiceType {
                return service
            } else {
                throw ServiceProviderError.wrongService
            }
        
        case .factoryParams(let factory, let params):
            if let service = try factory.coreCreateService(params: params) as? ServiceType {
                return service
            } else {
                throw ServiceProviderError.wrongService
            }
        }
    }
}
