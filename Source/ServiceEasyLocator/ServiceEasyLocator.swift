//
//  ServiceEasyLocator.swift
//  ServiceContainerKit 2.0.0
//
//  Created by Короткий Виталий on 16/04/2019.
//  Copyright © 2019 ProVir. All rights reserved.
//

import Foundation

/// ServiceLocator as easy storage ServiceProviders
open class ServiceEasyLocator {
    private let locator: ServiceLocator
    
    public init() {
        locator = ServiceLocator()
    }
    
    public required init(otherLocator: ServiceEasyLocator) {
        self.locator = otherLocator.locator.clone()
    }
    
    /// Lock used for all public methods
    public var lock: NSRecursiveLock {
        return locator.lock
    }
    
    /// ServiceEasyLocator as singleton
    public private(set) static var shared: ServiceEasyLocator?
    
    /// Get shared ServiceLocator or error
    public static func tryShared() throws -> ServiceEasyLocator {
        if let shared = shared {
            return shared
        } else {
            throw ServiceLocatorError.sharedRequireSetup
        }
    }
    
    /// ServiceEasyLocator.shared don't can replace other instance. Also it can also be used to prohibit the use of a singleton
    public private(set) static var readOnlyShared: Bool = false
    
    /// Services list support and factoryes don't can change if is `true`.
    public var readOnly: Bool {
        return locator.readOnly
    }
    
    // MARK: Setup locator
    /// Setup ServiceLocator as singleton. If `readOnlySharedAfter = true` (default) - don't change singleton instance after.
    public static func setupShared(_ serviceLocator: ServiceEasyLocator, readOnlySharedAfter: Bool = true) {
        if readOnlyShared {
            assertionFailure("Don't support setupShared in readOnly regime")
            return
        }
        
        shared = serviceLocator
        readOnlyShared = readOnlySharedAfter
    }
    
    /// In readOnly regime can't use addService and removeService.
    open func setReadOnly() {
        locator.setReadOnly()
    }
    
    /// Clone ServiceLocator with all providers, but with readOnly = false in new instance.
    open func clone<T: ServiceEasyLocator>(type: T.Type = T.self) -> T {
        return T.init(otherLocator: self)
    }
    
    // MARK: - Setup services
    
    /// Add ServiceProvider with service for ServiceLocator
    open func addService<ServiceType>(provider: ServiceProvider<ServiceType>) {
        locator.addService(key: ServiceLocatorEasyKey<ServiceType>(), provider: provider)
    }
    
    /// Add ServiceParamsProvider with service for ServiceLocator
    open func addService<ServiceType, ParamsType>(provider: ServiceParamsProvider<ServiceType, ParamsType>) {
        locator.addService(key: ServiceLocatorEasyKey<ServiceType>(), provider: provider)
    }
    
    /// Add service at one instance.
    open func addService<ServiceType>(_ service: ServiceType) {
        locator.addService(key: ServiceLocatorEasyKey<ServiceType>(), service: service)
    }
    
    /// Add factory service
    open func addService<ServiceType, FactoryType: ServiceFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType {
        locator.addService(key: ServiceLocatorEasyKey<ServiceType>(), factory: factory)
    }
    
    /// Add factory service with params
    open func addService<ServiceType, ParamsType, FactoryType: ServiceParamsFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType, FactoryType.ParamsType == ParamsType {
        locator.addService(key: ServiceLocatorEasyKey<ServiceType>(), factory: factory)
    }
    
    /// Add service with lazy create service in closure
    open func addLazyService<ServiceType>(_ lazy: @escaping () throws -> ServiceType) {
        locator.addLazyService(key: ServiceLocatorEasyKey<ServiceType>(), lazy)
    }
    
    /// Add service with many instance service type, create service in closure
    open func addService<ServiceType>(manyFactory closure: @escaping () throws -> ServiceType) {
        locator.addService(key: ServiceLocatorEasyKey<ServiceType>(), manyFactory: closure)
    }
    
    /// Remove service from ServiceLocator.
    @discardableResult
    open func removeService<ServiceType>(serviceType: ServiceType.Type) -> Bool {
        return locator.removeService(key: ServiceLocatorEasyKey<ServiceType>())
    }
    
    // MARK: - Get
    /// Get Service with detail information throwed error.
    open func tryService<ServiceType>(_ type: ServiceType.Type = ServiceType.self) throws -> ServiceType {
        return try locator.tryService(key: ServiceLocatorEasyKey<ServiceType>())
    }
    
    /// Get Service with params with detail information throwed error.
    open func tryService<ServiceType>(_ type: ServiceType.Type = ServiceType.self, params: Any) throws -> ServiceType {
        return try locator.tryService(key: ServiceLocatorEasyKey<ServiceType>(), params: params)
    }
    
    /// Get Service if there are no errors.
    open func getService<ServiceType>(_ type: ServiceType.Type = ServiceType.self) -> ServiceType? {
        return try? locator.tryService(key: ServiceLocatorEasyKey<ServiceType>())
    }
    
    /// Get Service with params if there are no errors
    open func getService<ServiceType>(_ type: ServiceType.Type = ServiceType.self, params: Any) -> ServiceType? {
        return try? locator.tryService(key: ServiceLocatorEasyKey<ServiceType>(), params: params)
    }
    
    /// Get ServiceProvider with service
    open func getServiceProvider<ServiceType>(serviceType: ServiceType.Type = ServiceType.self) -> ServiceProvider<ServiceType>? {
        return locator.getServiceProvider(key: ServiceLocatorEasyKey<ServiceType>())
    }
    
    /// Get ServiceParamsProvider with service
    open func getServiceProvider<ServiceType, ParamsType>(serviceType: ServiceType.Type = ServiceType.self) -> ServiceParamsProvider<ServiceType, ParamsType>? {
        return locator.getServiceProvider(key: ServiceLocatorEasyKey<ServiceType>())
    }
}
