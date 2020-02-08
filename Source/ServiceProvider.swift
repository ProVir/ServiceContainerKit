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

/// ServiceProvider with information for make service (singleton or many instances)
public class ServiceProvider<ServiceType> {
    private enum Storage<ServiceType> {
        case instance(ServiceType)
        case atOneError(ServiceObtainError)
        case lazy(ServiceCoreFactory)
        case factory(ServiceCoreFactory, params: Any)

        func validateError() throws {
            switch self {
            case .atOneError(let error): throw error
            default: return
            }
        }
    }

    private let helper = ServiceProviderHelper<ServiceType>()
    private var storage: Storage<ServiceType>
    
    /// ServiceProvider with at one instance services.
    public init(_ service: ServiceType) {
        self.storage = .instance(service)
    }
    
    /// ServiceProvider with factory.
    public init<FactoryType: ServiceFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType {
        switch factory.mode {
        case .atOne:
            let result = helper.makeService(factory: factory, params: Void())
            switch result {
            case let .success(service): self.storage = .instance(service)
            case let .failure(error): self.storage = .atOneError(error)
            }

        case .lazy:
            self.storage =  .lazy(factory)

        case .many:
            self.storage =  .factory(factory, params: Void())
        }
    }
    
    /// ServiceProvider with factory, use specific params.
    public init<FactoryType: ServiceParamsFactory>(factory: FactoryType, params: FactoryType.ParamsType) where FactoryType.ServiceType == ServiceType {
        self.storage = .factory(factory, params: params)
    }

    init(coreFactory: ServiceCoreFactory, params: Any) {
        self.storage = .factory(coreFactory, params: params)
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

        case let.lazy(factory):
            let result = helper.makeService(factory: factory, params: Void())
            if case let .success(service) = result {
                storage = .instance(service)
            }
            return result

        case let .factory(factory, params):
            return helper.makeService(factory: factory, params: params)
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



