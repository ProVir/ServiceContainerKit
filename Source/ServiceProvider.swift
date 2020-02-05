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

/// ServiceProvider with information for make service (singleton or many instances)
public struct ServiceProvider<ServiceType> {
    fileprivate let storage: ServiceProviderStorage<ServiceType>
    
    /// ServiceProvider with at one instance services.
    public init(_ service: ServiceType) {
        self.storage = .atOne(service)
    }
    
    /// ServiceProvider with factory. If service factoryType == .atOne and throw error when make - throw this error from constructor.
    public init<FactoryType: ServiceFactory>(tryFactory factory: FactoryType) throws where FactoryType.ServiceType == ServiceType {
        self.storage = try ServiceProvider.makeStorageAsResult(factory: factory).get()
    }
    
    /// ServiceProvider with factory.
    public init<FactoryType: ServiceFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType {
        self.storage = ServiceProvider.makeStorageWithError(factory: factory)
    }
    
    /// ServiceProvider with factory, use specific params.
    public init<FactoryType: ServiceParamsFactory>(factory: FactoryType, params: FactoryType.ParamsType) where FactoryType.ServiceType == ServiceType {
        self.storage = .factoryParams(factory, params)
    }
    
    /// ServiceProvider with lazy create service in closure.
    public init(lazy: @escaping () throws -> ServiceType) {
        self.storage = ServiceProvider.makeStorageWithError(factory: ServiceClosureFactory(closureFactory: lazy, lazyMode: true))
    }
    
    /// ServiceProvider with many instance service type, create service in closure.
    public init(manyFactory: @escaping () throws -> ServiceType) {
        self.storage = ServiceProvider.makeStorageWithError(factory: ServiceClosureFactory(closureFactory: manyFactory, lazyMode: false))
    }

    /// Get Service with detail information throwed error.
    public func getServiceAsResult() -> Result<ServiceType, ServiceObtainError> {
        return internalGetService(params: Void())
    }

    /// Get Service with detail information throwed error.
    public func getService() throws -> ServiceType {
        return try internalGetService(params: Void()).get()
    }

    /// Get Service if there are no errors.
    public func getServiceAsOptional() -> ServiceType? {
        return try? internalGetService(params: Void()).get()
    }
    
    /// Get Service if there are no errors or fatal when failure obtain.
    public func getServiceOrFatal() -> ServiceType {
        let result = internalGetService(params: Void())
        switch result {
        case .success(let service): return service
        case .failure(let error): fatalError(error.fatalMessage)
        }
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
    public func getServiceAsResult(params: ParamsType) -> Result<ServiceType, ServiceObtainError> {
        return internalGetService(params: params)
    }

    /// Get Service with detail information throwed error.
    public func getService(params: ParamsType) throws -> ServiceType {
        return try internalGetService(params: params).get()
    }

    /// Get Service if there are no errors.
    public func getServiceAsOptional(params: ParamsType) -> ServiceType? {
        return try? internalGetService(params: params).get()
    }

    /// Get Service if there are no errors or fatal when failure obtain.
    public func getServiceOrFatal(params: ParamsType) -> ServiceType {
        let result = internalGetService(params: params)
        switch result {
        case .success(let service): return service
        case .failure(let error): fatalError(error.fatalMessage)
        }
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
    case atOneError(ServiceObtainError)
    
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

    private static func makeStorageWithError<FactoryType: ServiceFactory>(factory: FactoryType, params: Any = Void()) -> ServiceProviderStorage<ServiceType> where FactoryType.ServiceType == ServiceType {
        let result = makeStorageAsResult(factory: factory, params: params)
        switch result {
        case .success(let storage): return storage
        case .failure(let error): return .atOneError(error)
        }
    }

    private static func makeStorageAsResult<FactoryType: ServiceFactory>(factory: FactoryType, params: Any = Void()) -> Result<ServiceProviderStorage<ServiceType>, ServiceObtainError> where FactoryType.ServiceType == ServiceType {
        switch factory.mode {
        case .atOne:
            do {
                if let service = try factory.coreMakeService(params: params) as? ServiceType {
                    return .success(.atOne(service))
                } else {
                    throw ServiceFactoryError.invalidFactory
                }
            } catch {
                return .failure(convertToObtainError(ServiceType.self, error: error))
            }

        case .lazy:
            let lazy = ServiceProviderStorage<ServiceType>.Lazy()
            lazy.factory = factory
            return .success(.lazy(lazy))

        case .many:
            return .success(.factory(factory))
        }
    }
}

extension ServiceParamsProvider: ServiceProviderPrivate { }

extension ServiceProviderPrivate {
    /// Get Services with core implementation
    fileprivate func internalGetService(params: Any) -> Result<ServiceType, ServiceObtainError> {
        switch storage {
        // Return single instance
        case .atOne(let service):
            return .success(service)
            
        case .atOneError(let error):
            return .failure(error)
            
        // Lazy service
        case .lazy(let lazy):
            if let service = lazy.instance {
                return .success(service)
            } else if let factory = lazy.factory {
                do {
                    if let service = try factory.coreMakeService(params: params) as? ServiceType {
                        lazy.instance = service
                        lazy.factory = nil

                        return .success(service)
                    } else {
                        throw ServiceFactoryError.invalidFactory
                    }
                } catch {
                    return .failure(convertToObtainError(ServiceType.self, error: error))
                }
            } else {
                fatalError("ServiceProvider: Internal error")
            }
            
        //Multiple service
        case .factory(let factory):
            do {
                if let service = try factory.coreMakeService(params: params) as? ServiceType {
                    return .success(service)
                } else {
                    throw ServiceFactoryError.invalidFactory
                }
            } catch {
                return .failure(convertToObtainError(ServiceType.self, error: error))
            }
        
        case .factoryParams(let factory, let params):
            do {
                if let service = try factory.coreMakeService(params: params) as? ServiceType {
                    return .success(service)
                } else {
                    throw ServiceFactoryError.invalidFactory
                }
            } catch {
                return .failure(convertToObtainError(ServiceType.self, error: error))
            }
        }
    }
}

private func convertToObtainError<ServiceType>(_ serviceType: ServiceType.Type, error: Error) -> ServiceObtainError {
    if let error = error as? ServiceObtainError {
        return error.withAddedToPath(service: ServiceType.self)
    } else {
        return ServiceObtainError(service: ServiceType.self, error: error)
    }
}
