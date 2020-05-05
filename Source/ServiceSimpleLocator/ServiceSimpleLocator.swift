//
//  ServiceSimpleLocator.swift
//  ServiceContainerKit/ServiceSimpleLocator 2.0.0
//
//  Created by Короткий Виталий on 16/04/2019.
//  Copyright © 2019 ProVir. All rights reserved.
//

import Foundation

/// ServiceLocator as easy storage ServiceProviders
open class ServiceSimpleLocator {
    private let keyLocator: ServiceLocator
    
    public init() {
        keyLocator = ServiceLocator()
    }

    /// Constructor used for clone locator. ServiceSimpleLocator need by allowClone = true
    public required init(other: ServiceSimpleLocator) {
        self.keyLocator = other.keyLocator.clone()
    }
    
    /// Lock used for all public methods
    public var lock: NSRecursiveLock {
        return keyLocator.lock
    }
    
    /// Services list support and factoryes don't can change if is `true`.
    public var readOnly: Bool {
        return keyLocator.readOnly
    }
    
    /// Deny clone locator
    public var denyClone: Bool {
        return keyLocator.denyClone
    }
    
    /// In readOnly regime can't use addService and removeService. Also when denyClone = true (default), can't use clone()
    open func setReadOnly(denyClone: Bool = true, assertionFailure: Bool = true) {
        keyLocator.setReadOnly(denyClone: denyClone, assertionFailure: assertionFailure)
    }
    
    /// Clone ServiceSimpleLocator with all providers, but with readOnly = false in new instance.
    open func clone<T: ServiceSimpleLocator>(type: T.Type = T.self) -> T {
        return T.init(other: self)
    }
    
    // MARK: - Setup services
    /// Add ServiceProvider with service for ServiceLocator
    open func addService<ServiceType>(provider: ServiceProvider<ServiceType>) {
        keyLocator.addService(key: ServiceLocatorSimpleKey<ServiceType>(), provider: provider)
    }
    
    /// Add ServiceParamsProvider with service for ServiceLocator
    open func addService<ServiceType, ParamsType>(provider: ServiceParamsProvider<ServiceType, ParamsType>) {
        keyLocator.addService(key: ServiceLocatorParamsSimpleKey<ServiceType, ParamsType>(), provider: provider)
    }
    
    /// Add service at one instance.
    open func addService<ServiceType>(_ service: ServiceType) {
        keyLocator.addService(key: ServiceLocatorSimpleKey<ServiceType>(), service: service)
    }
    
    /// Add factory service
    open func addService<ServiceType, FactoryType: ServiceFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType {
        keyLocator.addService(key: ServiceLocatorSimpleKey<ServiceType>(), factory: factory)
    }
    
    /// Add factory service with params
    open func addService<ServiceType, ParamsType, FactoryType: ServiceParamsFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType, FactoryType.ParamsType == ParamsType {
        keyLocator.addService(key: ServiceLocatorParamsSimpleKey<ServiceType, ParamsType>(), factory: factory)
    }
    
    /// Add service with lazy create service in closure
    open func addLazyService<ServiceType>(_ lazy: @escaping () throws -> ServiceType) {
        keyLocator.addLazyService(key: ServiceLocatorSimpleKey<ServiceType>(), lazy)
    }
    
    /// Add service with many instance service type, create service in closure
    open func addService<ServiceType>(manyFactory closure: @escaping () throws -> ServiceType) {
        keyLocator.addService(key: ServiceLocatorSimpleKey<ServiceType>(), manyFactory: closure)
    }
    
    /// Remove service from ServiceSimpleLocator.
    @discardableResult
    open func removeService<ServiceType>(_ serviceType: ServiceType.Type) -> Bool {
        return keyLocator.removeService(key: ServiceLocatorSimpleKey<ServiceType>())
    }
    
    // MARK: - Get service
    /// Get Service with detailed information throwed error.
    open func getServiceAsResult<ServiceType>(_ type: ServiceType.Type = ServiceType.self) -> Result<ServiceType, ServiceObtainError> {
        return keyLocator.getServiceAsResult(key: ServiceLocatorSimpleKey<ServiceType>())
    }

    /// Get Service with params and detailed information throwed error.
    open func getServiceAsResult<ServiceType, ParamsType>(_ type: ServiceType.Type = ServiceType.self, params: ParamsType) -> Result<ServiceType, ServiceObtainError> {
        return keyLocator.getServiceAsResult(key: ServiceLocatorParamsSimpleKey<ServiceType, ParamsType>(), params: params)
    }

    /// Get Service with detailed information throwed error.
    public func getService<ServiceType>(_ type: ServiceType.Type = ServiceType.self) throws -> ServiceType {
        return try getServiceAsResult(type).get()
    }
    
    /// Get Service with params and detailed information throwed error.
    public func getService<ServiceType, ParamsType>(_ type: ServiceType.Type = ServiceType.self, params: ParamsType) throws -> ServiceType {
        return try getServiceAsResult(type, params: params).get()
    }
    
    /// Get Service if there are no errors.
    public func getServiceAsOptional<ServiceType>(_ type: ServiceType.Type = ServiceType.self) -> ServiceType? {
        return try? getServiceAsResult(type).get()
    }
    
    /// Get Service with params if there are no errors
    public func getServiceAsOptional<ServiceType, ParamsType>(_ type: ServiceType.Type = ServiceType.self, params: ParamsType) -> ServiceType? {
        return try? getServiceAsResult(type, params: params).get()
    }

    public func getServiceOrFatal<ServiceType>(_ type: ServiceType.Type = ServiceType.self) -> ServiceType {
        let result = getServiceAsResult(type)
        switch result {
        case .success(let service): return service
        case .failure(let error): fatalError(error.fatalMessage)
        }
    }

    public func getServiceOrFatal<ServiceType, ParamsType>(_ type: ServiceType.Type = ServiceType.self, params: ParamsType) -> ServiceType {
        let result = getServiceAsResult(type, params: params)
        switch result {
        case .success(let service): return service
        case .failure(let error): fatalError(error.fatalMessage)
        }
    }

    // MARK: Get provider
    
    /// Get ServiceProvider with service
    open func getServiceProvider<ServiceType>(serviceType: ServiceType.Type = ServiceType.self) -> ServiceProvider<ServiceType>? {
        return keyLocator.getServiceProvider(key: ServiceLocatorSimpleKey<ServiceType>())
    }
    
    /// Get ServiceParamsProvider with service
    open func getServiceProvider<ServiceType, ParamsType>(serviceType: ServiceType.Type = ServiceType.self) -> ServiceParamsProvider<ServiceType, ParamsType>? {
        return keyLocator.getServiceProvider(key: ServiceLocatorParamsSimpleKey<ServiceType, ParamsType>())
    }

    @discardableResult
    open func testContainsService<ServiceType>(_ serviceType: ServiceType.Type, assert: Bool = true, file: StaticString = #file, line: UInt = #line) -> Bool {
        keyLocator.testContainsService(key: ServiceLocatorSimpleKey<ServiceType>(), assert: assert, file: file, line: line)
    }
    
    // MARK: ObjC
    /// Get Service use typeName as ServiceLocatorKey.storeKey
    open func getServiceObjC(typeName: String) -> Result<NSObject, ServiceObtainError> {
        //swiftlint:disable:next syntactic_sugar
        return getServiceObjC(typeName: typeName, params: Optional<Any>.none as Any)
    }

    /// Get Service with params use typeName as ServiceLocatorKey.storeKey
    open func getServiceObjC(typeName: String, params: Any) -> Result<NSObject, ServiceObtainError> {
        let result = keyLocator.getServiceObjC(key: ServiceLocatorObjCKey(storeKey: typeName), params: params)
        let firstError: ServiceObtainError
        switch result {
        case .success(let service):
            return .success(service)
        case .failure(let error):
            guard error.isServiceNotFound else {
                return .failure(error)
            }
            firstError = error
        }

        guard let typeName = serviceTypeNameWithoutBundle(typeName: typeName) else {
            return .failure(firstError)
        }

        return keyLocator.getServiceObjC(key: ServiceLocatorObjCKey(storeKey: typeName), params: params)
    }

    /// TypeName without bundle prefix
    public func serviceTypeNameWithoutBundle(typeName: String) -> String? {
        if let pointIndex = typeName.firstIndex(of: ".") {
            return String(typeName[typeName.index(after: pointIndex)..<typeName.endIndex])
        } else {
            return nil
        }
    }
}
