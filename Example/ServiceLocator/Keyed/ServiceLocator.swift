//
//  ServiceLocator.swift
//  ServiceLocator
//
//  Created by Короткий Виталий (ViR) on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation
import ServiceContainerKit

/// ServiceLocator as storage ServiceProviders.
open class ServiceLocator {

    public required init() { }
    
    /// Lock used for all public methods
    public let lock = NSRecursiveLock()
    
    /// Private list providers with services
    private var providers = [AnyHashable: ServiceLocatorProviderBinding]()
    
    // MARK: Setup locator
    /// Services list support and factoryes don't can change if is `true`.
    public private(set) var readOnly: Bool = false
    public private(set) var denyClone: Bool = false
    private var readOnlyAssertionFailure: Bool = true
    
    /// In readOnly regime can't use addService and removeService. Also when denyClone = true (default), can't use clone()
    open func setReadOnly(denyClone setDenyClone: Bool = true, assertionFailure: Bool = true) {
        lock.lock()
        readOnly = true
        denyClone = denyClone || setDenyClone
        readOnlyAssertionFailure = assertionFailure
        lock.unlock()
    }

    /// Clone ServiceLocator with all providers, but with readOnly = false in new instance.
    open func clone<T: ServiceLocator>(type: T.Type = T.self) -> T {
        let locator = T.init()
        
        lock.lock()
        defer { lock.unlock() }
        
        guard denyClone == false else {
            if readOnlyAssertionFailure { assertionFailure("Don't support clone when denyClone = true") }
            return locator
        }
        
        locator.providers = self.providers
        return locator
    }

    // MARK: Setup services
    /// Add ServiceProvider by key with service for ServiceLocator
    open func addService<Key: ServiceLocatorKey>(key: Key, provider: ServiceProvider<Key.ServiceType>) {
        lock.lock()
        defer { lock.unlock() }
        
        if readOnly {
            if readOnlyAssertionFailure { assertionFailure("Don't support addService in readOnly regime") }
            return
        }
        
        providers[key.storeKey] = provider
    }
    
    /// Add ServiceParamsProvider by key with service for ServiceLocator
    open func addService<Key: ServiceLocatorParamsKey>(key: Key, provider: ServiceParamsProvider<Key.ServiceType, Key.ParamsType>) {
        lock.lock()
        defer { lock.unlock() }
        
        if readOnly {
            if readOnlyAssertionFailure { assertionFailure("Don't support addService in readOnly regime") }
            return
        }
        
        providers[key.storeKey] = provider
    }
    
    /// Add service by key at one instance.
    open func addService<Key: ServiceLocatorKey>(key: Key, service: Key.ServiceType) {
        addService(key: key, provider: ServiceProvider(service))
    }
    
    /// Add factory service by key
    open func addService<Key: ServiceLocatorKey, FactoryType: ServiceFactory>(key: Key, factory: FactoryType) where FactoryType.ServiceType == Key.ServiceType {
        addService(key: key, provider: ServiceProvider(factory: factory))
    }
    
    /// Add factory service with params by key
    open func addService<Key: ServiceLocatorParamsKey, FactoryType: ServiceParamsFactory>(key: Key, factory: FactoryType) where FactoryType.ServiceType == Key.ServiceType, FactoryType.ParamsType == Key.ParamsType {
        addService(key: key, provider: ServiceParamsProvider(factory: factory))
    }
    
    /// Add service by key with lazy make service in closure
    open func addLazyService<Key: ServiceLocatorKey>(key: Key, _ factory: @escaping () throws -> Key.ServiceType) {
        addService(key: key, provider: ServiceProvider(lazySingleton: true, factory: factory))
    }
    
    /// Add service by key with many instance service type, make service in closure
    open func addManyService<Key: ServiceLocatorKey>(key: Key, factory: @escaping () throws -> Key.ServiceType) {
        addService(key: key, provider: ServiceProvider(lazySingleton: false, factory: factory))
    }
    
    /// Add service by key with many instance service type, make service in closure
    open func addParamsService<Key: ServiceLocatorParamsKey>(key: Key, factory: @escaping (Key.ParamsType) throws -> Key.ServiceType) {
        addService(key: key, provider: ServiceParamsProvider(factory: factory))
    }
    
    /// Remove service by key from ServiceLocator.
    @discardableResult
    open func removeService<Key: ServiceLocatorKey>(key: Key) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        if readOnly {
            if readOnlyAssertionFailure { assertionFailure("Don't support removeService in readOnly regime") }
            return false
        }

        return providers.removeValue(forKey: key.storeKey) != nil
    }
    
    // MARK: - Get services
    /// Get Service by key with detail information throwed error.
    open func getServiceAsResult<Key: ServiceLocatorKey>(key: Key) -> Result<Key.ServiceType, ServiceObtainError> {
        //swiftlint:disable:next syntactic_sugar
        return internalGetService(storeKey: key.storeKey, params: Optional<Any>.none as Any)
    }

    /// Get Service by key with params with detail information throwed error.
    open func getServiceAsResult<Key: ServiceLocatorParamsKey>(key: Key, params: Key.ParamsType) -> Result<Key.ServiceType, ServiceObtainError> {
        return internalGetService(storeKey: key.storeKey, params: params)
    }

    /// Get Service by key with detail information throwed error.
    public func getService<Key: ServiceLocatorKey>(key: Key) throws -> Key.ServiceType {
        return try getServiceAsResult(key: key).get()
    }
    
    /// Get Service by key with params with detail information throwed error.
    public func getService<Key: ServiceLocatorParamsKey>(key: Key, params: Key.ParamsType) throws -> Key.ServiceType {
        return try getServiceAsResult(key: key, params: params).get()
    }
    
    /// Get Service by key if there are no errors.
    public func getServiceAsOptional<Key: ServiceLocatorKey>(key: Key) -> Key.ServiceType? {
        return try? getServiceAsResult(key: key).get()
    }
    
    /// Get Service by key with params if there are no errors
    public func getServiceAsOptional<Key: ServiceLocatorParamsKey>(key: Key, params: Key.ParamsType) -> Key.ServiceType? {
        return try? getServiceAsResult(key: key, params: params).get()
    }

    /// Get Service by key if there are no errors.
    public func getServiceOrFatal<Key: ServiceLocatorKey>(key: Key, file: StaticString = #file, line: UInt = #line) -> Key.ServiceType {
        let result = getServiceAsResult(key: key)
        switch result {
        case .success(let service): return service
        case .failure(let error): fatalError(error.fatalMessage, file: file, line: line)
        }
    }

    /// Get Service by key if there are no errors.
    public func getServiceOrFatal<Key: ServiceLocatorParamsKey>(key: Key, params: Key.ParamsType, file: StaticString = #file, line: UInt = #line) -> Key.ServiceType {
        let result = getServiceAsResult(key: key, params: params)
        switch result {
        case .success(let service): return service
        case .failure(let error): fatalError(error.fatalMessage, file: file, line: line)
        }
    }

    // MARK: Get providers

    /// Get ServiceProvider by key with service
    open func getServiceProvider<Key: ServiceLocatorKey>(key: Key) -> ServiceProvider<Key.ServiceType>? {
        lock.lock()
        defer { lock.unlock() }
        
        return providers[key.storeKey] as? ServiceProvider<Key.ServiceType>
    }
    
    /// Get ServiceParamsProvider with service by key
    open func getServiceProvider<Key: ServiceLocatorParamsKey>(key: Key) -> ServiceParamsProvider<Key.ServiceType, Key.ParamsType>? {
        lock.lock()
        defer { lock.unlock() }
        
        return providers[key.storeKey] as? ServiceParamsProvider<Key.ServiceType, Key.ParamsType>
    }

    @discardableResult
    open func testContainsService<Key: ServiceLocatorKey>(key: Key, assert: Bool = true, file: StaticString = #file, line: UInt = #line) -> Bool {
        if providers[key.storeKey] != nil {
            return true
        } else {
            if assert { assertionFailure("Service not found: \(Key.ServiceType.self)", file: file, line: line) }
            return false
        }
    }

    @discardableResult
    open func testContainsService<Key: ServiceLocatorParamsKey>(key: Key, assert: Bool = true, file: StaticString = #file, line: UInt = #line) -> Bool {
        if providers[key.storeKey] != nil {
            return true
        } else {
            if assert { assertionFailure("Service not found: \(Key.ServiceType.self)", file: file, line: line) }
            return false
        }
    }
    
    // MARK: ObjC
    /// Get Service by ObjC Key
    open func getServiceObjC(key: ServiceLocatorObjCKey) -> Result<NSObject, ServiceObtainError> {
        //swiftlint:disable:next syntactic_sugar
        return internalGetService(storeKey: key.storeKey, params: Optional<Any>.none as Any)
    }

    /// Get Service by ObjC Key with params
    open func getServiceObjC(key: ServiceLocatorObjCKey, params: Any) -> Result<NSObject, ServiceObtainError> {
        return internalGetService(storeKey: key.storeKey, params: params)
    }

    // MARK: - Private
    private func internalGetService<ServiceType>(storeKey: AnyHashable, params: Any) -> Result<ServiceType, ServiceObtainError> {
        lock.lock()
        defer { lock.unlock() }
        
        if let provider = providers[storeKey] {
            return provider.getServiceBinding(ServiceType.self, params: params)
        } else {
            return .failure(ServiceObtainError(service: ServiceType.self, error: ServiceLocatorError.serviceNotFound))
        }
    }
}

// MARK: Provider binding to ServiceLocator
/// Base protocol for ServiceProvider<T>
private protocol ServiceLocatorProviderBinding {
    func getServiceBinding<ServiceType>(_ type: ServiceType.Type, params: Any) -> Result<ServiceType, ServiceObtainError>
}

extension ServiceProvider: ServiceLocatorProviderBinding {
    fileprivate func getServiceBinding<ServiceType>(_ type: ServiceType.Type, params: Any) -> Result<ServiceType, ServiceObtainError> {
        return getServiceAsResult().flatMap {
            if let service = $0 as? ServiceType {
                return .success(service)
            } else {
                return .failure(ServiceObtainError(service: ServiceType.self, error: ServiceLocatorError.invalidProvider))
            }
        }
    }
}

extension ServiceParamsProvider: ServiceLocatorProviderBinding {
    fileprivate func getServiceBinding<ServiceType>(_ type: ServiceType.Type, params: Any) -> Result<ServiceType, ServiceObtainError> {
        guard let params = params as? ParamsType else {
            return .failure(ServiceObtainError(service: ServiceType.self, error: ServiceFactoryError.wrongParams))
        }
        
        return getServiceAsResult(params: params).flatMap {
            if let service = $0 as? ServiceType {
                return .success(service)
            } else {
                return .failure(ServiceObtainError(service: ServiceType.self, error: ServiceLocatorError.invalidProvider))
            }
        }
    }
}
