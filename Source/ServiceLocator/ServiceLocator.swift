//
//  ServiceLocator.swift
//  ServiceLocatorSwift 2.0.0
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
    private var readOnlyAssertionFailure: Bool = true
    
    /// In readOnly regime can't use addService and removeService.
    open func setReadOnly(assertionFailure: Bool = true) {
        lock.lock()
        readOnly = true
        readOnlyAssertionFailure = assertionFailure
        lock.unlock()
    }

    /// Clone ServiceLocator with all providers, but with readOnly = false in new instance.
    open func clone<T: ServiceLocator>(type: T.Type = T.self) -> T {
        let locator = T.init()

        lock.lock()
        locator.providers = self.providers
        lock.unlock()

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
    
    /// Add service by key with lazy create service in closure
    open func addLazyService<Key: ServiceLocatorKey>(key: Key, _ lazy: @escaping () throws -> Key.ServiceType) {
        addService(key: key, provider: ServiceProvider(lazy: lazy))
    }
    
    /// Add service by key with many instance service type, create service in closure
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
    
    // MARK: Get
    /// Get Service by key with detail information throwed error.
    open func tryService<Key: ServiceLocatorKey>(key: Key) throws -> Key.ServiceType {
        lock.lock()
        defer { lock.unlock() }
        
        if let provider = providers[key.storeKey] {
            do { return try provider.tryServiceBinding(Key.ServiceType.self, params: Optional<Any>.none as Any) }
            catch { throw convertError(error) }
        } else {
            throw ServiceLocatorError.serviceNotFound
        }
    }
    
    /// Get Service by key with params with detail information throwed error.
    open func tryService<Key: ServiceLocatorParamsKey>(key: Key, params: Key.ParamsType) throws -> Key.ServiceType {
        lock.lock()
        defer { lock.unlock() }
        
        if let provider = providers[key.storeKey] {
            do { return try provider.tryServiceBinding(Key.ServiceType.self, params: params) }
            catch { throw convertError(error) }
        } else {
            throw ServiceLocatorError.serviceNotFound
        }
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
    
    /// Get ServiceParamsProvider with service
    open func getServiceProvider<Key: ServiceLocatorParamsKey>(key: Key) -> ServiceParamsProvider<Key.ServiceType, Key.ParamsType>? {
        lock.lock()
        defer { lock.unlock() }
        
        return providers[key.storeKey] as? ServiceParamsProvider<Key.ServiceType, Key.ParamsType>
    }
    
    // MARK: - ServiceLocatorObjC support
    func tryServiceObjC(typeName: String, params: Any) throws -> NSObject {
        lock.lock()
        defer { lock.unlock() }
        
        //Find for standart name
        if let provider = providers[typeName] {
            do { return try provider.tryServiceBinding(NSObject.self, params: params) }
            catch { throw convertError(error) }
        }

        if let typeNameWithoutBundle = ServiceLocator.serviceTypeNameWithoutBundle(typeName: typeName),
            let provider = providers[typeNameWithoutBundle] {
            do { return try provider.tryServiceBinding(NSObject.self, params: params) }
            catch { throw convertError(error) }
        }

        throw ServiceLocatorError.serviceNotFound
    }

    // MARK: Service unique key
    open func serviceTypeName(for type: Any.Type) -> String {
        return "\(type)"
    }

    open func serviceTypeName(forObjCProtocol proto: Protocol) -> String {
        return NSStringFromProtocol(proto)
    }

    // MARK: - Private
    //Find without bundle name (Bundle.ServiceName - remove Bundle)
    public static func serviceTypeNameWithoutBundle(typeName: String) -> String? {
        if let pointIndex = typeName.firstIndex(of: ".") {
            return String(typeName[typeName.index(after: pointIndex)..<typeName.endIndex])
        } else {
            return nil
        }
    }
    
    /// Convert errors from ServiceProviderError to ServiceLocatorError
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

