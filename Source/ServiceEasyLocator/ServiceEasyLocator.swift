//
//  ServiceEasyLocator.swift
//  ServiceContainerKit/ServiceEasyLocator 2.0.0
//
//  Created by Короткий Виталий on 16/04/2019.
//  Copyright © 2019 ProVir. All rights reserved.
//

import Foundation

/// ServiceLocator as easy storage ServiceProviders
open class ServiceEasyLocator {
    private let keyLocator: ServiceLocator
    
    public init() {
        keyLocator = ServiceLocator()
    }

    /// Constructor used for clone locator. ServiceEasyLocator need by allowClone = true
    public required init(other: ServiceEasyLocator) {
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
    
    /// Clone ServiceEasyLocator with all providers, but with readOnly = false in new instance.
    open func clone<T: ServiceEasyLocator>(type: T.Type = T.self) -> T {
        return T.init(other: self)
    }
    
    // MARK: - Setup services
    /// Add ServiceProvider with service for ServiceLocator
    open func addService<ServiceType>(provider: ServiceProvider<ServiceType>) {
        keyLocator.addService(key: ServiceLocatorEasyKey<ServiceType>(), provider: provider)
    }
    
    /// Add ServiceParamsProvider with service for ServiceLocator
    open func addService<ServiceType, ParamsType>(provider: ServiceParamsProvider<ServiceType, ParamsType>) {
        keyLocator.addService(key: ServiceLocatorParamsEasyKey<ServiceType, ParamsType>(), provider: provider)
    }
    
    /// Add service at one instance.
    open func addService<ServiceType>(_ service: ServiceType) {
        keyLocator.addService(key: ServiceLocatorEasyKey<ServiceType>(), service: service)
    }
    
    /// Add factory service
    open func addService<ServiceType, FactoryType: ServiceFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType {
        keyLocator.addService(key: ServiceLocatorEasyKey<ServiceType>(), factory: factory)
    }
    
    /// Add factory service with params
    open func addService<ServiceType, ParamsType, FactoryType: ServiceParamsFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType, FactoryType.ParamsType == ParamsType {
        keyLocator.addService(key: ServiceLocatorParamsEasyKey<ServiceType, ParamsType>(), factory: factory)
    }
    
    /// Add service with lazy create service in closure
    open func addLazyService<ServiceType>(_ lazy: @escaping () throws -> ServiceType) {
        keyLocator.addLazyService(key: ServiceLocatorEasyKey<ServiceType>(), lazy)
    }
    
    /// Add service with many instance service type, create service in closure
    open func addService<ServiceType>(manyFactory closure: @escaping () throws -> ServiceType) {
        keyLocator.addService(key: ServiceLocatorEasyKey<ServiceType>(), manyFactory: closure)
    }
    
    /// Remove service from ServiceEasyLocator.
    @discardableResult
    open func removeService<ServiceType>(_ serviceType: ServiceType.Type) -> Bool {
        return keyLocator.removeService(key: ServiceLocatorEasyKey<ServiceType>())
    }
    
    // MARK: - Get
    /// Get Service with detailed information throwed error.
    open func tryService<ServiceType>(_ type: ServiceType.Type = ServiceType.self) throws -> ServiceType {
        return try keyLocator.tryService(key: ServiceLocatorEasyKey<ServiceType>())
    }
    
    /// Get Service with params and detailed information throwed error.
    open func tryService<ServiceType, ParamsType>(_ type: ServiceType.Type = ServiceType.self, params: ParamsType) throws -> ServiceType {
        return try keyLocator.tryService(key: ServiceLocatorParamsEasyKey<ServiceType, ParamsType>(), params: params)
    }
    
    /// Get Service if there are no errors.
    open func getService<ServiceType>(_ type: ServiceType.Type = ServiceType.self) -> ServiceType? {
        return try? keyLocator.tryService(key: ServiceLocatorEasyKey<ServiceType>())
    }
    
    /// Get Service with params if there are no errors
    open func getService<ServiceType, ParamsType>(_ type: ServiceType.Type = ServiceType.self, params: ParamsType) -> ServiceType? {
        return try? keyLocator.tryService(key: ServiceLocatorParamsEasyKey<ServiceType, ParamsType>(), params: params)
    }
    
    /// Get ServiceProvider with service
    open func getServiceProvider<ServiceType>(serviceType: ServiceType.Type = ServiceType.self) -> ServiceProvider<ServiceType>? {
        return keyLocator.getServiceProvider(key: ServiceLocatorEasyKey<ServiceType>())
    }
    
    /// Get ServiceParamsProvider with service
    open func getServiceProvider<ServiceType, ParamsType>(serviceType: ServiceType.Type = ServiceType.self) -> ServiceParamsProvider<ServiceType, ParamsType>? {
        return keyLocator.getServiceProvider(key: ServiceLocatorParamsEasyKey<ServiceType, ParamsType>())
    }
    
    // MARK: ObjC
    /// Get Service use typeName as ServiceLocatorKey.storeKey
    open func tryServiceObjC(typeName: String) throws -> NSObject {
        //swiftlint:disable:next syntactic_sugar
        return try tryServiceObjC(typeName: typeName, params: Optional<Any>.none as Any)
    }

    /// Get Service with params use typeName as ServiceLocatorKey.storeKey
    open func tryServiceObjC(typeName: String, params: Any) throws -> NSObject {
        do {
            return try keyLocator.tryServiceObjC(key: ServiceLocatorObjCKey(storeKey: typeName), params: params)
        } catch ServiceLocatorError.serviceNotFound {
        } catch {
            throw error
        }
        
        guard let typeName = serviceTypeNameWithoutBundle(typeName: typeName) else {
            throw ServiceLocatorError.serviceNotFound
        }
        
        return try keyLocator.tryServiceObjC(key: ServiceLocatorObjCKey(storeKey: typeName), params: params)
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
