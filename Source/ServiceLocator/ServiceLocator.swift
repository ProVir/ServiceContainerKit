//
//  ServiceLocator.swift
//  ServiceContainerKit/ServiceLocator 2.0.0
//
//  Created by Короткий Виталий (ViR) on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

///Errors for ServiceLocator
public enum ServiceLocatorError: LocalizedError {
    case serviceNotFound
    case wrongParams

    public var errorDescription: String? {
        switch self {
        case .serviceNotFound: return "Service not found in ServiceLocator"
        case .wrongParams: return "Params type invalid for ServiceParamsFactory"
        }
    }
}

/// ServiceLocator as storage ServiceProviders.
open class ServiceLocator {

    public required init() { }
    
    /// Lock used for all public methods
    public let lock = NSRecursiveLock()
    
    /// Private list providers with services
    private var providers = [String: ServiceLocatorProviderBinding]()
    
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
    open func addLazyService<Key: ServiceLocatorKey>(key: Key, _ lazy: @escaping () throws -> Key.ServiceType) {
        addService(key: key, provider: ServiceProvider(lazy: lazy))
    }
    
    /// Add service by key with many instance service type, make service in closure
    open func addService<Key: ServiceLocatorKey>(key: Key, manyFactory closure: @escaping () throws -> Key.ServiceType) {
        addService(key: key, provider: ServiceProvider(manyFactory: closure))
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
    
    // MARK: - Get
    /// Get Service by key with detail information throwed error.
    open func tryService<Key: ServiceLocatorKey>(key: Key) throws -> Key.ServiceType {
        //swiftlint:disable:next syntactic_sugar
        return try tryService(storeKey: key.storeKey, params: Optional<Any>.none as Any)
    }
    
    /// Get Service by key with params with detail information throwed error.
    open func tryService<Key: ServiceLocatorParamsKey>(key: Key, params: Key.ParamsType) throws -> Key.ServiceType {
        return try tryService(storeKey: key.storeKey, params: params)
    }
    
    /// Get Service by key if there are no errors.
    open func getService<Key: ServiceLocatorKey>(key: Key) -> Key.ServiceType? {
        return try? tryService(key: key)
    }
    
    /// Get Service by key with params if there are no errors
    open func getService<Key: ServiceLocatorParamsKey>(key: Key, params: Key.ParamsType) -> Key.ServiceType? {
        return try? tryService(key: key, params: params)
    }
    
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
    
    // MARK: ObjC
    /// Get Service by ObjC Key
    open func tryServiceObjC(key: ServiceLocatorObjCKey) throws -> NSObject {
        //swiftlint:disable:next syntactic_sugar
        return try tryService(storeKey: key.storeKey, params: Optional<Any>.none as Any)
    }

    /// Get Service by ObjC Key with params
    open func tryServiceObjC(key: ServiceLocatorObjCKey, params: Any) throws -> NSObject {
        return try tryService(storeKey: key.storeKey, params: params)
    }

    // MARK: - Private
    private func tryService<ServiceType>(storeKey: String, params: Any) throws -> ServiceType {
        lock.lock()
        defer { lock.unlock() }
        
        if let provider = providers[storeKey] {
            do {
                return try provider.tryServiceBinding(ServiceType.self, params: params)
            } catch {
                throw convertError(error)
            }
        } else {
            throw ServiceLocatorError.serviceNotFound
        }
    }
    
    private func convertError(_ error: Error) -> Error {
        if let error = error as? ServiceProviderError {
            switch error {
            case .wrongService: return ServiceLocatorError.serviceNotFound
            case .wrongParams: return ServiceLocatorError.wrongParams
            case .notSupportObjC: return ServiceLocatorError.serviceNotFound
            }
        } else {
            return error
        }
    }
}

// MARK: Provider binding to ServiceLocator
/// Base protocol for ServiceProvider<T>
private protocol ServiceLocatorProviderBinding {
    func tryServiceBinding<ServiceType>(_ type: ServiceType.Type, params: Any) throws -> ServiceType
}

extension ServiceProvider: ServiceLocatorProviderBinding {
    fileprivate func tryServiceBinding<ServiceType>(_ type: ServiceType.Type, params: Any) throws -> ServiceType {
        if let service = try tryService() as? ServiceType {
            return service
        } else {
            throw ServiceLocatorError.serviceNotFound
        }
    }
}

extension ServiceParamsProvider: ServiceLocatorProviderBinding {
    fileprivate func tryServiceBinding<ServiceType>(_ type: ServiceType.Type, params: Any) throws -> ServiceType {
        guard let params = params as? ParamsType else {
            throw ServiceLocatorError.wrongParams
        }
        
        if let service = try tryService(params: params) as? ServiceType {
            return service
        } else {
            throw ServiceLocatorError.serviceNotFound
        }
    }
}
