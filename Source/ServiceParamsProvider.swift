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
        return .init(factory: self)
    }

    /// Wrap the factory in ServiceProvider with specific params.
    func serviceProvider(params: ParamsType) -> ServiceProvider<ServiceType> {
        return .init(factory: self, params: params)
    }

    /// Wrap the factory in ServiceParamsSafeProvider
    func serviceSafeProvider(safeThread kind: ServiceSafeProviderKind = .lock) -> ServiceParamsSafeProvider<ServiceType, ParamsType> {
        return .init(factory: self, safeThread: kind)
    }

    /// Wrap the factory in ServiceSafeProvider with specific params.
    func serviceSafeProvider(params: ParamsType, safeThread kind: ServiceSafeProviderKind = .lock) -> ServiceSafeProvider<ServiceType> {
        return .init(factory: self, params: params, safeThread: kind)
    }
}

/// ServiceProvider with information for create service (static or factory)
public class ServiceParamsProvider<ServiceType, ParamsType> {
    private let helper = ServiceProviderHelper<ServiceType>()
    fileprivate let factory: ServiceCoreFactory

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
    public func getServiceOrFatal(params: ParamsType, file: StaticString = #file, line: UInt = #line) -> ServiceType {
        let result = getServiceAsResult(params: params)
        switch result {
        case .success(let service): return service
        case .failure(let error): fatalError(error.fatalMessage, file: file, line: line)
        }
    }

    /// Get ServiceProvider without params with specific params.
    public func convert(params: ParamsType) -> ServiceProvider<ServiceType> {
        return .init(coreFactory: factory, params: params)
    }
}

// MARK: - Safe thread
public class ServiceParamsSafeProvider<ServiceType, ParamsType>: ServiceParamsProvider<ServiceType, ParamsType> {
    private let hanlder: ServiceSafeProviderHandler

    /// ServiceProvider with factory.
    public init<FactoryType: ServiceParamsFactory>(factory: FactoryType, safeThread kind: ServiceSafeProviderKind = .lock) where FactoryType.ServiceType == ServiceType, FactoryType.ParamsType == ParamsType {
        self.hanlder = .init(kind: kind)
        super.init(factory: factory)
    }

    /// Get Service with detail information throwed error.
    public override func getServiceAsResult(params: ParamsType) -> Result<ServiceType, ServiceObtainError> {
        return hanlder.safelyHandling { super.getServiceAsResult(params: params) }
    }

    public func getServiceAsResultNotSafe(params: ParamsType) -> Result<ServiceType, ServiceObtainError> {
        return super.getServiceAsResult(params: params)
    }

    /// Get ServiceProvider without params with specific params.
    public override func convert(params: ParamsType) -> ServiceSafeProvider<ServiceType> {
        return .init(coreFactory: factory, params: params, handler: hanlder)
    }
}
