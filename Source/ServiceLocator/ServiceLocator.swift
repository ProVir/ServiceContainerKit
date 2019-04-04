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
    private var providers = [String : ServiceLocatorProviderBinding]()
    
    
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
        lock.lock()
        defer { lock.unlock() }
        
        if readOnly {
            assertionFailure("Don't support addService in readOnly regime")
            return
        }
        
        let typeName = serviceTypeName(for: ServiceType.self)
        providers[typeName] = provider
    }
    
    /// Add ServiceParamsProvider with service for ServiceLocator
    open func addService<ServiceType, ParamsType>(provider: ServiceParamsProvider<ServiceType, ParamsType>) {
        lock.lock()
        defer { lock.unlock() }
        
        if readOnly {
            assertionFailure("Don't support addService in readOnly regime")
            return
        }
        
        let typeName = serviceTypeName(for: ServiceType.self)
        providers[typeName] = provider
    }
    
    /// Add service at one instance.
    @discardableResult
    open func addService<ServiceType>(_ service: ServiceType) -> ServiceProvider<ServiceType> {
        let provider = ServiceProvider<ServiceType>(service)
        addService(provider: provider)
        return provider
    }
    
    /// Add factory service
    @discardableResult
    open func addService<ServiceType, FactoryType: ServiceFactory>(factory: FactoryType) -> ServiceProvider<ServiceType> where FactoryType.ServiceType == ServiceType {
        let provider = ServiceProvider<ServiceType>(factory: factory)
        addService(provider: provider)
        return provider
    }
    
    /// Add factory service with params when created instance
    @discardableResult
    open func addService<ServiceType, ParamsType, FactoryType: ServiceParamsFactory>(factory: FactoryType) -> ServiceParamsProvider<ServiceType, ParamsType> where FactoryType.ServiceType == ServiceType, FactoryType.ParamsType == ParamsType {
        let provider = ServiceParamsProvider<ServiceType, ParamsType>(factory: factory)
        addService(provider: provider)
        return provider
    }
    
    /// Add service with lazy create service in closure.
    @discardableResult
    open func addLazyService<ServiceType>(_ lazy: @escaping () throws -> ServiceType) -> ServiceProvider<ServiceType> {
        let provider = ServiceProvider<ServiceType>(lazy: lazy)
        addService(provider: provider)
        return provider
    }
    
    /// Add service with many instance service type, create service in closure.
    @discardableResult
    open func addService<ServiceType>(manyFactory closure: @escaping () throws -> ServiceType) -> ServiceProvider<ServiceType> {
        let provider = ServiceProvider<ServiceType>(manyFactory: closure)
        addService(provider: provider)
        return provider
    }
    
    /// Remove service from ServiceLocator.
    @discardableResult
    open func removeService<ServiceType>(serviceType: ServiceType.Type) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        
        if readOnly {
            assertionFailure("Don't support removeService in readOnly regime")
            return false
        }

        let typeName = serviceTypeName(for: ServiceType.self)
        return providers.removeValue(forKey: typeName) != nil
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
        lock.lock()
        defer { lock.unlock() }
        
        let typeName = serviceTypeName(for: ServiceType.self)
        if let provider = providers[typeName] {
            do { return try provider.tryServiceBinding(ServiceType.self, params: Optional<Any>.none as Any) }
            catch { throw convertError(error) }
        } else {
            throw ServiceLocatorError.serviceNotFound
        }
    }
    
    /// Get Service with params with detail information throwed error.
    open func tryService<ServiceType: ServiceSupportFactoryParams>(_ type: ServiceType.Type = ServiceType.self,
                                                                   params: ServiceType.ParamsType) throws -> ServiceType {
        lock.lock()
        defer { lock.unlock() }
        
        let typeName = serviceTypeName(for: ServiceType.self)
        if let provider = providers[typeName] {
            do { return try provider.tryServiceBinding(ServiceType.self, params: params) }
            catch { throw convertError(error) }
        } else {
            throw ServiceLocatorError.serviceNotFound
        }
    }
    
    /// Get Service if there are no errors.
    open func getService<ServiceType>(_ type: ServiceType.Type = ServiceType.self) -> ServiceType? {
        return try? tryService(ServiceType.self)
    }
    
    /// Get Service with params if there are no errors
    open func getService<ServiceType: ServiceSupportFactoryParams>(_ type: ServiceType.Type = ServiceType.self,
                                                                   params: ServiceType.ParamsType) -> ServiceType? {
        return try? tryService(ServiceType.self, params: params)
    }
    
    /// Get ServiceProvider with service
    open func getServiceProvider<ServiceType>(serviceType: ServiceType.Type = ServiceType.self) -> ServiceProvider<ServiceType>? {
        lock.lock()
        defer { lock.unlock() }
        
        let typeName = serviceTypeName(for: ServiceType.self)
        return providers[typeName] as? ServiceProvider<ServiceType>
    }
    
    /// Get ServiceParamsProvider with service
    open func getServiceProvider<ServiceType, ParamsType>(serviceType: ServiceType.Type = ServiceType.self) -> ServiceParamsProvider<ServiceType, ParamsType>? {
        lock.lock()
        defer { lock.unlock() }
        
        let typeName = serviceTypeName(for: ServiceType.self)
        return providers[typeName] as? ServiceParamsProvider<ServiceType, ParamsType>
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
