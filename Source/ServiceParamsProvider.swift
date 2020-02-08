//
//  ServiceParamsProvider.swift
//  ServiceContainerKit
//
//  Created by Vitalii Korotkii on 07/02/2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

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

/// ServiceProvider with information for create service (static or factory)
public final class ServiceParamsProvider<ServiceType, ParamsType> {
    private let helper = ServiceProviderHelper<ServiceType>()
    private let factory: ServiceCoreFactory

    /// ServiceProvider with factory.
    public init<FactoryType: ServiceParamsFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType, FactoryType.ParamsType == ParamsType {
        self.factory = factory
    }

    /// Get Service with detail information throwed error.
    public func getServiceAsResult(params: ParamsType) -> Result<ServiceType, ServiceObtainError> {
        return helper.makeService(factory: factory, params: params)
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
        return .init(coreFactory: factory, params: params)
    }
}
