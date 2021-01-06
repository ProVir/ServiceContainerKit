//
//  ServiceParamsProvider.swift
//  ServiceContainerKit/Core 3.0.0
//
//  Created by Vitalii Korotkii on 07/02/2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

/// ServiceProvider with information for make service
public class ServiceParamsProvider<ServiceType, ParamsType> {
    private let helper = ServiceProviderHelper<ServiceType>()
    fileprivate let factory: ServiceCoreFactory

    /// ServiceProvider with factory.
    public init<FactoryType: ServiceParamsFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType, FactoryType.ParamsType == ParamsType {
        self.factory = factory
    }
    
    /// ServiceProvider with make service in closure.
    public convenience init(factory: @escaping (ParamsType) throws -> ServiceType) {
        self.init(factory: ServiceParamsClosureFactory(factory: factory))
    }

    /// Get Service with detail information throwed error used `Result`.
    public func getServiceAsResult(params: ParamsType) -> Result<ServiceType, ServiceObtainError> {
        let result = helper.makeService(factory: factory, params: params)
        if case let .failure(error) = result {
            LogRecorder.serviceProviderMakeFailure(type: ServiceType.self, error: error)
        }
        return result
    }

    /// Get Service with detail information throwed error.
    public func getService(params: ParamsType) throws -> ServiceType {
        return try getServiceAsResult(params: params).get()
    }

    /// Get Service if there are no errors.
    public func getServiceAsOptional(params: ParamsType) -> ServiceType? {
        return try? getServiceAsResult(params: params).get()
    }

    /// Get Service if there are no errors or fatal with debug details when failure obtain.
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

// MARK: Safe thread
/// Thread safe ServiceProvider with information for make service
public class ServiceParamsSafeProvider<ServiceType, ParamsType>: ServiceParamsProvider<ServiceType, ParamsType> {
    private let handler: ServiceSafeProviderHandler

    /// ServiceProvider with factory.
    public init<FactoryType: ServiceParamsFactory>(factory: FactoryType, safeThread kind: ServiceSafeProviderKind = .default) where FactoryType.ServiceType == ServiceType, FactoryType.ParamsType == ParamsType {
        self.handler = .init(kind: kind)
        super.init(factory: factory)
    }
    
    /// ServiceProvider with make service in closure.
    public convenience init(safeThread kind: ServiceSafeProviderKind = .default, factory: @escaping (ParamsType) throws -> ServiceType) {
        self.init(factory: ServiceParamsClosureFactory(factory: factory), safeThread: kind)
    }

    /// Get Service in safe thread mode with detail information throwed error.
    public override func getServiceAsResult(params: ParamsType) -> Result<ServiceType, ServiceObtainError> {
        return handler.safelyHandling { super.getServiceAsResult(params: params) }
    }

    /// Get Service in unsafe thread mode with detail information throwed error.
    public func getServiceAsResultNotSafe(params: ParamsType) -> Result<ServiceType, ServiceObtainError> {
        return super.getServiceAsResult(params: params)
    }

    /// Get ServiceSafeProvider without params with specific params.
    public override func convert(params: ParamsType) -> ServiceSafeProvider<ServiceType> {
        return .init(coreFactory: factory, params: params, handler: handler)
    }
}
