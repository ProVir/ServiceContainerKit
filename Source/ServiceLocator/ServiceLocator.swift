//
//  ServiceLocator.swift
//  ServiceLocatorSwift 1.1.0
//
//  Created by Короткий Виталий (ViR) on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

///Errors for ServiceLocator
public enum ServiceLocatorError: LocalizedError {
    case serviceNotFound
    case wrongParams
    case sharedRequireSetup

    public var errorDescription: String? {
        switch self {
        case .serviceNotFound: return "Service not found in ServiceLocator"
        case .wrongParams: return "Params type invalid for ServiceParamsFactory"
        case .sharedRequireSetup: return "ServiceLocator don't setuped for use as share (singleton)"
        }
    }
}

/// Protocol for Service, use when used ServiceParamsFactory as factory for service. Added getService function for ServiceLocator with params.
public protocol ServiceSupportFactoryParams {
    associatedtype ParamsType
}

public protocol ServiceLocatorKey {
    associatedtype ServiceType
    var storeKey: String { get }
}

public protocol ServiceLocatorParamsKey: ServiceLocatorKey {
    associatedtype ParamsType
}

public struct ServiceLocatorEasyKey<ServiceType>: ServiceLocatorKey {
    public init() { }
    public var storeKey: String { return "\(ServiceType.self)" }
}



/// ServiceLocator as storage ServiceProviders.
open class ServiceLocator {
    /// ServiceLocator as singleton
    public private(set) static var shared: ServiceLocator?
    
    /// ServiceLocator.shared don't can replace other instance. Also it can also be used to prohibit the use of a singleton
    public private(set) static var readOnlyShared: Bool = false
    
    /// Services list support and factoryes don't can change if is `true`.
    public private(set) var readOnly: Bool = false
    
    public required init() { }
    
    /// Lock used for all public methods
    public let lock = NSRecursiveLock()
    
    /// Private list providers with services
    private var providers = [String: ServiceLocatorProviderBinding]()
    
    // MARK: Setup
    /// Setup ServiceLocator as singleton. If `readOnlySharedAfter = true` (default) - don't change singleton instance after.
    public static func setupShared(serviceLocator: ServiceLocator, readOnlySharedAfter: Bool = true) {
        if readOnlyShared {
            assertionFailure("Don't support setupShared in readOnly regime")
            return
        }
        
        shared = serviceLocator
        readOnlyShared = readOnlySharedAfter
    }
    
    /// In readOnly regime can't use addService and removeService.
    open func setReadOnly() {
        lock.lock()
        readOnly = true
        lock.unlock()
    }
    
    /// Add ServiceProvider with service for ServiceLocator
    open func addService<ServiceType>(provider: ServiceProvider<ServiceType>) {
        addService(key: ServiceLocatorEasyKey<ServiceType>(), provider: provider)
    }
    
    /// Add ServiceProvider by key with service for ServiceLocator
    open func addService<Key: ServiceLocatorKey>(key: Key, provider: ServiceProvider<Key.ServiceType>) {
        lock.lock()
        defer { lock.unlock() }
        
        if readOnly {
            assertionFailure("Don't support addService in readOnly regime")
            return
        }
        
        providers[key.storeKey] = provider
    }
    
    /// Add ServiceParamsProvider with service for ServiceLocator
    open func addService<ServiceType, ParamsType>(provider: ServiceParamsProvider<ServiceType, ParamsType>) {
        addService(key: ServiceLocatorEasyKey<ServiceType>(), provider: provider)
    }
    
    /// Add ServiceParamsProvider by key with service for ServiceLocator
    open func addService<Key: ServiceLocatorKey, ParamsType>(key: Key, provider: ServiceParamsProvider<Key.ServiceType, ParamsType>) {
        lock.lock()
        defer { lock.unlock() }
        
        if readOnly {
            assertionFailure("Don't support addService in readOnly regime")
            return
        }
        
        providers[key.storeKey] = provider
    }
    
    /// Add service at one instance.
    open func addService<ServiceType>(_ service: ServiceType) {
        addService(key: ServiceLocatorEasyKey<ServiceType>(), provider: ServiceProvider(service))
    }
    
    /// Add service by key at one instance.
    open func addService<Key: ServiceLocatorKey>(key: Key, _ service: Key.ServiceType) {
        addService(key: key, provider: ServiceProvider(service))
    }
    
    /// Add factory service
    open func addService<ServiceType, FactoryType: ServiceFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType {
        addService(key: ServiceLocatorEasyKey<ServiceType>(), provider: ServiceProvider(factory: factory))
    }
    
    /// Add factory service by key
    open func addService<Key: ServiceLocatorKey, FactoryType: ServiceFactory>(key: Key, factory: FactoryType) where FactoryType.ServiceType == Key.ServiceType {
        addService(key: key, provider: ServiceProvider(factory: factory))
    }
    
    /// Add factory service with params
    open func addService<ServiceType, ParamsType, FactoryType: ServiceParamsFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType, FactoryType.ParamsType == ParamsType {
        addService(key: ServiceLocatorEasyKey<ServiceType>(), provider: ServiceParamsProvider(factory: factory))
    }
    
    /// Add factory service with params by key
    open func addService<Key: ServiceLocatorKey, ParamsType, FactoryType: ServiceParamsFactory>(key: Key, factory: FactoryType) where FactoryType.ServiceType == Key.ServiceType, FactoryType.ParamsType == ParamsType {
        addService(key: key, provider: ServiceParamsProvider(factory: factory))
    }
    
    /// Add service with lazy create service in closure
    open func addLazyService<ServiceType>(_ lazy: @escaping () throws -> ServiceType) {
        addService(key: ServiceLocatorEasyKey<ServiceType>(), provider: ServiceProvider(lazy: lazy))
    }
    
    /// Add service by key with lazy create service in closure
    open func addLazyService<Key: ServiceLocatorKey>(key: Key, _ lazy: @escaping () throws -> Key.ServiceType) {
        addService(key: key, provider: ServiceProvider(lazy: lazy))
    }
    
    /// Add service with many instance service type, create service in closure
    open func addService<ServiceType>(manyFactory closure: @escaping () throws -> ServiceType) {
        addService(key: ServiceLocatorEasyKey<ServiceType>(), provider: ServiceProvider(manyFactory: closure))
    }
    
    /// Add service by key with many instance service type, create service in closure
    open func addService<Key: ServiceLocatorKey>(key: Key, manyFactory closure: @escaping () throws -> Key.ServiceType) {
        addService(key: key, provider: ServiceProvider(manyFactory: closure))
    }
    
    /// Remove service from ServiceLocator.
    @discardableResult
    open func removeService<ServiceType>(serviceType: ServiceType.Type) -> Bool {
        return removeService(key: ServiceLocatorEasyKey<ServiceType>())
    }
    
    /// Remove service by key from ServiceLocator.
    @discardableResult
    open func removeService<Key: ServiceLocatorKey>(key: Key) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        if readOnly {
            assertionFailure("Don't support removeService in readOnly regime")
            return false
        }

        return providers.removeValue(forKey: key.storeKey) != nil
    }
    
    /// Clone ServiceLocator with all providers, but with readOnly = false in new instance.
    open func clone<T: ServiceLocator>(type: T.Type = T.self) -> T {
        let locator = T.init()
        
        lock.lock()
        locator.providers = self.providers
        lock.unlock()
        
        return locator
    }
    
    
    // MARK: Get from shared
    /// Get shared ServiceLocator or error
    public static func tryShared() throws -> ServiceLocator {
        if let shared = shared {
            return shared
        } else {
            throw ServiceLocatorError.sharedRequireSetup
        }
    }

    /// Get Service with detail information throwed error from ServiceLocator.share.
    public static func tryServiceFromShared<ServiceType>(_ type: ServiceType.Type = ServiceType.self) throws -> ServiceType {
        guard let shared = shared else {
            throw ServiceLocatorError.sharedRequireSetup
        }
        
        return try shared.tryService(ServiceType.self)
    }
    
    /// Get Service with params with detail information throwed error from ServiceLocator.share.
    public static func tryServiceFromShared<ServiceType: ServiceSupportFactoryParams>(_ type: ServiceType.Type = ServiceType.self,
                                                                                      params: ServiceType.ParamsType) throws -> ServiceType {
        guard let shared = shared else {
            throw ServiceLocatorError.sharedRequireSetup
        }
        
        return try shared.tryService(ServiceType.self, params: params)
    }
    
    /// Get Service if there are no errors from ServiceLocator.share.
    public static func getServiceFromShared<ServiceType>(_ type: ServiceType.Type = ServiceType.self) -> ServiceType? {
        guard let shared = shared else { return nil }
        return try? shared.tryService(ServiceType.self)
    }
    
    /// Get Service with params if there are no errors from ServiceLocator.share.
    public static func getServiceFromShared<ServiceType: ServiceSupportFactoryParams>(_ type: ServiceType.Type = ServiceType.self,
                                                                                      params: ServiceType.ParamsType) -> ServiceType? {
        guard let shared = shared else { return nil }
        return try? shared.tryService(ServiceType.self, params: params)
    }
    
    // MARK: Get
    /// Get Service with detail information throwed error.
    open func tryService<ServiceType>(_ type: ServiceType.Type = ServiceType.self) throws -> ServiceType {
        return try tryService(key: ServiceLocatorEasyKey<ServiceType>())
    }
    
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
    
    /// Get Service with params with detail information throwed error.
    open func tryService<ServiceType: ServiceSupportFactoryParams>(_ type: ServiceType.Type = ServiceType.self, params: ServiceType.ParamsType) throws -> ServiceType {
        return try tryService(key: ServiceLocatorEasyKey<ServiceType>(), params: params)
    }
    
    /// Get Service with params with detail information throwed error.
    open func tryService<ServiceType>(_ type: ServiceType.Type = ServiceType.self, params: Any) throws -> ServiceType {
        return try tryService(key: ServiceLocatorEasyKey<ServiceType>(), params: params)
    }
    
    /// Get Service by key with params with detail information throwed error.
    open func tryService<Key: ServiceLocatorKey>(key: Key, params: Any) throws -> Key.ServiceType {
        lock.lock()
        defer { lock.unlock() }
        
        if let provider = providers[key.storeKey] {
            do { return try provider.tryServiceBinding(Key.ServiceType.self, params: params) }
            catch { throw convertError(error) }
        } else {
            throw ServiceLocatorError.serviceNotFound
        }
    }
    
    /// Get Service if there are no errors.
    open func getService<ServiceType>(_ type: ServiceType.Type = ServiceType.self) -> ServiceType? {
        return try? tryService(key: ServiceLocatorEasyKey<ServiceType>())
    }
    
    /// Get Service by key if there are no errors.
    open func getService<Key: ServiceLocatorKey>(key: Key) -> Key.ServiceType? {
        return try? tryService(key: key)
    }
    
    /// Get Service with params if there are no errors
    open func getService<ServiceType: ServiceSupportFactoryParams>(_ type: ServiceType.Type = ServiceType.self, params: ServiceType.ParamsType) -> ServiceType? {
        return try? tryService(key: ServiceLocatorEasyKey<ServiceType>(), params: params)
    }
    
    /// Get Service with params if there are no errors
    open func getService<ServiceType>(_ type: ServiceType.Type = ServiceType.self, params: Any) -> ServiceType? {
        return try? tryService(key: ServiceLocatorEasyKey<ServiceType>(), params: params)
    }
    
    /// Get Service by key with params if there are no errors
    open func getService<Key: ServiceLocatorKey>(key: Key, params: Any) -> Key.ServiceType? {
        return try? tryService(key: key, params: params)
    }
    
    /// Get ServiceProvider with service
    open func getServiceProvider<ServiceType>(serviceType: ServiceType.Type = ServiceType.self) -> ServiceProvider<ServiceType>? {
        return getServiceProvider(key: ServiceLocatorEasyKey<ServiceType>())
    }
    
    /// Get ServiceProvider by key with service
    open func getServiceProvider<Key: ServiceLocatorKey>(key: Key) -> ServiceProvider<Key.ServiceType>? {
        lock.lock()
        defer { lock.unlock() }
        
        return providers[key.storeKey] as? ServiceProvider<Key.ServiceType>
    }
    
    /// Get ServiceParamsProvider with service
    open func getServiceProvider<ServiceType, ParamsType>(serviceType: ServiceType.Type = ServiceType.self) -> ServiceParamsProvider<ServiceType, ParamsType>? {
        return getServiceProvider(key: ServiceLocatorEasyKey<ServiceType>())
    }
    
    /// Get ServiceParamsProvider with service
    open func getServiceProvider<Key: ServiceLocatorKey, ParamsType>(key: Key) -> ServiceParamsProvider<Key.ServiceType, ParamsType>? {
        lock.lock()
        defer { lock.unlock() }
        
        return providers[key.storeKey] as? ServiceParamsProvider<Key.ServiceType, ParamsType>
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

extension ServiceLocator {
    internal static func unitTestClearShared() {
        ServiceLocator.shared = nil
        ServiceLocator.readOnlyShared = false
    }
}
