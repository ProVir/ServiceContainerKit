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
public final class ServiceProvider<ServiceType> {
    private enum Storage<ServiceType> {
        case instance(ServiceType)
        case atOneError(ServiceObtainError)
        case factory(ServiceCoreFactory, params: Any, lazy: Bool)

        func validateError() throws {
            switch self {
            case .atOneError(let error): throw error
            default: return
            }
        }
    }

    private var storage: Storage<ServiceType>
    
    /// ServiceProvider with at one instance services.
    public init(_ service: ServiceType) {
        self.storage = .instance(service)
    }
    
    /// ServiceProvider with factory.
    public init<FactoryType: ServiceFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType {
        switch factory.mode {
        case .atOne:
            do {
                if let service = try factory.coreMakeService(params: Void()) as? ServiceType {
                    self.storage = .instance(service)
                } else {
                    throw ServiceFactoryError.invalidFactory
                }
            } catch {
                self.storage =  .atOneError(convertToObtainError(ServiceType.self, error: error))
            }

        case .lazy:
            self.storage =  .factory(factory, params: Void(), lazy: true)

        case .many:
            self.storage =  .factory(factory, params: Void(), lazy: false)
        }
    }
    
    /// ServiceProvider with factory, use specific params.
    public init<FactoryType: ServiceParamsFactory>(factory: FactoryType, params: FactoryType.ParamsType) where FactoryType.ServiceType == ServiceType {
        self.storage = .factory(factory, params: params, lazy: false)
    }

    public init<ParamsType>(provider: ServiceParamsProvider<ServiceType, ParamsType>, params: ParamsType) {
        self.storage = .factory(provider.factory, params: params, lazy: false)
    }

    /// ServiceProvider with factory. If service factoryType == .atOne and throw error when make - throw this error from constructor.
    public convenience init<FactoryType: ServiceFactory>(tryFactory factory: FactoryType) throws where FactoryType.ServiceType == ServiceType {
        self.init(factory: factory)
        try storage.validateError()
    }

    /// ServiceProvider with lazy create service in closure.
    public convenience init(lazy: @escaping () throws -> ServiceType) {
        self.init(factory: ServiceClosureFactory(closureFactory: lazy, lazyMode: true))
    }
    
    /// ServiceProvider with many instance service type, create service in closure.
    public convenience init(manyFactory: @escaping () throws -> ServiceType) {
        self.init(factory: ServiceClosureFactory(closureFactory: manyFactory, lazyMode: false))
    }


    /// Get Service with detail information throwed error.
    public func getServiceAsResult() -> Result<ServiceType, ServiceObtainError> {
        switch storage {
        case let .instance(service):
            return .success(service)

        case let .atOneError(error):
            return .failure(error)

        case let .factory(factory, params, lazy):
            do {
                if let service = try factory.coreMakeService(params: params) as? ServiceType {
                    if lazy { storage = .instance(service) }
                    return .success(service)
                } else {
                    throw ServiceFactoryError.invalidFactory
                }
            } catch {
                return .failure(convertToObtainError(ServiceType.self, error: error))
            }
        }
    }

    /// Get Service with detail information throwed error.
    public func getService() throws -> ServiceType {
        return try getServiceAsResult().get()
    }

    /// Get Service if there are no errors.
    public func getServiceAsOptional() -> ServiceType? {
        return try? getServiceAsResult().get()
    }
    
    /// Get Service if there are no errors or fatal when failure obtain.
    public func getServiceOrFatal() -> ServiceType {
        let result = getServiceAsResult()
        switch result {
        case .success(let service): return service
        case .failure(let error): fatalError(error.fatalMessage)
        }
    }
}

/// ServiceProvider with information for create service (static or factory)
public final class ServiceParamsProvider<ServiceType, ParamsType> {
    fileprivate let factory: ServiceCoreFactory
    
    /// ServiceProvider with factory.
    public init<FactoryType: ServiceParamsFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType, FactoryType.ParamsType == ParamsType {
        self.factory = factory
    }
    
    /// Get Service with detail information throwed error.
    public func getServiceAsResult(params: ParamsType) -> Result<ServiceType, ServiceObtainError> {
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

    /// Get Service with detail information throwed error.
    public func getService(params: ParamsType) throws -> ServiceType {
        return try getServiceAsResult(params: params).get()
    }

    /// Get Service if there are no errors.
    public func getServiceAsOptional(params: ParamsType) -> ServiceType? {
        return try? getServiceAsResult(params: params).get()
    }

    /// Get Service if there are no errors or fatal when failure obtain.
    public func getServiceOrFatal(params: ParamsType) -> ServiceType {
        let result = getServiceAsResult(params: params)
        switch result {
        case .success(let service): return service
        case .failure(let error): fatalError(error.fatalMessage)
        }
    }

    /// Get ServiceProvider without params with specific params.
    public func convert(params: ParamsType) -> ServiceProvider<ServiceType> {
        return .init(provider: self, params: params)
    }
}

private func convertToObtainError<ServiceType>(_ serviceType: ServiceType.Type, error: Error) -> ServiceObtainError {
    if let error = error as? ServiceObtainError {
        return error.withAddedToPath(service: ServiceType.self)
    } else {
        return ServiceObtainError(service: ServiceType.self, error: error)
    }
}
