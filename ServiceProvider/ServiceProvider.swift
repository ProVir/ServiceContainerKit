//
//  ServiceProvider.swift
//  ServiceProvider 1.0.0
//
//  Created by Короткий Виталий (ViR) on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

public extension ServiceFactory {
    func serviceProvider() -> ServiceProvider<ServiceType> {
        return ServiceProvider<ServiceType>.init(factory: self)
    }
}

public extension ServiceParamsFactory {
    func serviceProvider() -> ServiceParamsProvider<ServiceType, ParamsType> {
        return ServiceParamsProvider<ServiceType, ParamsType>.init(factory: self)
    }
    
    func serviceProvider(params: ParamsType) -> ServiceProvider<ServiceType> {
        return ServiceProvider<ServiceType>.init(factory: self, params: params)
    }
}

/// ServiceProvider with information for create service (static or factory)
public struct ServiceProvider<ServiceType> {
    fileprivate let storage: ServiceProviderStorage<ServiceType>
    
    public init(_ service: ServiceType) {
        self.storage = .single(service)
    }
    
    public init<FactoryType: ServiceFactory>(tryFactory factory: FactoryType) throws where FactoryType.ServiceType == ServiceType {
        self.storage = try ServiceProvider.createStorage(factory: factory)
    }
    
    public init<FactoryType: ServiceFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType {
        do {
            self.storage = try ServiceProvider.createStorage(factory: factory)
        } catch {
            self.storage = .singleError(error)
        }
    }
    
    public init<FactoryType: ServiceParamsFactory>(factory: FactoryType, params: FactoryType.ParamsType) where FactoryType.ServiceType == ServiceType {
        self.storage = .factoryParams(factory, params)
    }
    
    public init(lazy: @escaping () throws -> ServiceType) {
        self.storage = .factory(ServiceClosureFactory(closureFactory: lazy, lazyRegime: true))
    }
    
    public init(factory closure: @escaping () throws -> ServiceType) {
        self.storage = .factory(ServiceClosureFactory(closureFactory: closure, lazyRegime: false))
    }
    
    public func tryService() throws -> ServiceType {
        return try internalTryService(params: Void())
    }
    
    public func getService() -> ServiceType? {
        return try? internalTryService(params: Void())
    }
}

/// ServiceProvider with information for create service (static or factory)
public struct ServiceParamsProvider<ServiceType, ParamsType> {
    fileprivate let storage: ServiceProviderStorage<ServiceType>
    
    public init<FactoryType: ServiceParamsFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType, FactoryType.ParamsType == ParamsType {
        self.storage = .factory(factory)
    }
    
    public func tryService(params: ParamsType) throws -> ServiceType {
        return try internalTryService(params: params)
    }
    
    public func getService(params: ParamsType) -> ServiceType? {
        return try? internalTryService(params: params)
    }
    
    public func convert(params: ParamsType) -> ServiceProvider<ServiceType> {
        switch storage {
        case .factory(let factory):
            return ServiceProvider<ServiceType>.init(coreFactory: factory, params: params)
        default:
            fatalError("Internal error: Invalid provider")
        }
    }
}

//MARK: - Private
private enum ServiceProviderStorage<ServiceType> {
    case single(ServiceType)
    case lazy(Lazy)
    case factory(ServiceCoreFactory)
    case factoryParams(ServiceCoreFactory, Any)
    case singleError(Error)
    
    class Lazy {
        var factory: ServiceCoreFactory?
        var instance: ServiceType?
    }
}

private protocol ServiceProviderPrivate {
    associatedtype ServiceType
    var storage: ServiceProviderStorage<ServiceType> { get }
}

extension ServiceProvider: ServiceProviderPrivate {
    fileprivate init(coreFactory: ServiceCoreFactory, params: Any)  {
        self.storage = .factoryParams(coreFactory, params)
    }
    
    private static func createStorage<FactoryType: ServiceFactory>(factory: FactoryType, params: Any = Void()) throws -> ServiceProviderStorage<ServiceType> where FactoryType.ServiceType == ServiceType {
        switch factory.factoryType {
        case .single:
            if let service = try factory.coreCreateService(params: params) as? ServiceType {
                return .single(service)
            } else {
                throw ServiceProviderError.wrongService
            }
            
        case .lazy:
            let lazy = ServiceProviderStorage<ServiceType>.Lazy()
            lazy.factory = factory
            return .lazy(lazy)
            
        case .multiple:
            return .factory(factory)
        }
    }
}

extension ServiceParamsProvider: ServiceProviderPrivate { }

extension ServiceProviderPrivate {
    fileprivate func internalTryService(params: Any) throws -> ServiceType {
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

