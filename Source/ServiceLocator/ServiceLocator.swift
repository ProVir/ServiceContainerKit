//
//  ServiceLocator.swift
//  ServiceLocatorSwift 1.0.0
//
//  Created by Короткий Виталий (ViR) on 04.06.2018.
//  Copyright © 2018 ProVir. All rights reserved.
//

import Foundation

///Errors for ServiceLocator
public enum ServiceLocatorError: Error {
    /// Service not found in ServiceLocator
    case serviceNotFound
    
    /// Params type invalid for ServiceParamsFactory
    case wrongParams
    
    /// ServiceLocator don't setuped for use as share (singleton)
    case sharedRequireSetup
}

/// Protocol for Service, use when used ServiceParamsFactory as factory for service. Added getService function for ServiceLocator with params.
public protocol ServiceSupportFactoryParams {
    associatedtype ParamsType
}


/// ServiceLocator as storage ServiceProviders.
open class ServiceLocator {
    /// ServiceLocator as singleton
    public private(set) static var shared: ServiceLocator?
    
    /// ServiceLocator.shared don't can replace other instance. Also it can also be used to prohibit the use of a singleton&
    public private(set) static var readOnlyShared: Bool = false
    
    /// Services list support and factoryes don't can change if is `true`.
    public private(set) var readOnly: Bool = false
    
    public required init() { }
    
    /// Lock used for all public methods
    public let lock = NSRecursiveLock()
    
    /// Private list providers with services
    private var providers = [String : ServiceLocatorProviderBinding]()
    
    
    //MARK: Setup
    
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
        
        let typeName = "\(ServiceType.self)"
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
        
        let typeName = "\(ServiceType.self)"
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
    open func addService<ServiceType>(lazy: @escaping () throws -> ServiceType) -> ServiceProvider<ServiceType> {
        let provider = ServiceProvider<ServiceType>(lazy: lazy)
        addService(provider: provider)
        return provider
    }
    
    /// Add service with many instance service type, create service in closure.
    @discardableResult
    open func addService<ServiceType>(factory closure: @escaping () throws -> ServiceType) -> ServiceProvider<ServiceType> {
        let provider = ServiceProvider<ServiceType>(factory: closure)
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
        
        return providers.removeValue(forKey: "\(ServiceType.self)") != nil
    }
    
    /// Clone ServiceLocator with all providers, but with readOnly = false in new instance.
    open func clone<T: ServiceLocator>(type: T.Type = T.self) -> T {
        let locator = T.init()
        
        lock.lock()
        locator.providers = self.providers
        lock.unlock()
        
        return locator
    }
    
    
    //MARK: Get from shared
    
    /// Get Service with detail information throwed error from ServiceLocator.share.
    public static func tryServiceFromShared<ServiceType>() throws -> ServiceType {
        guard let shared = shared else {
            throw ServiceLocatorError.sharedRequireSetup
        }
        
        return try shared.tryService()
    }
    
    /// Get Service with params with detail information throwed error from ServiceLocator.share.
    public static func tryServiceFromShared<ServiceType: ServiceSupportFactoryParams>(params: ServiceType.ParamsType) throws -> ServiceType {
        guard let shared = shared else {
            throw ServiceLocatorError.sharedRequireSetup
        }
        
        return try shared.tryService(params: params)
    }
    
    /// Get Service if there are no errors from ServiceLocator.share.
    public static func getServiceFromShared<ServiceType>() -> ServiceType? {
        guard let shared = shared else { return nil }
        return try? shared.tryService()
    }
    
    /// Get Service with params if there are no errors from ServiceLocator.share.
    public static func getServiceFromShared<ServiceType: ServiceSupportFactoryParams>(params: ServiceType.ParamsType) -> ServiceType? {
        guard let shared = shared else { return nil }
        return try? shared.tryService(params: params)
    }
    
    
    //MARK: Get
    
    /// Get Service with detail information throwed error.
    open func tryService<ServiceType>() throws -> ServiceType {
        lock.lock()
        defer { lock.unlock() }
        
        let typeName = "\(ServiceType.self)"
        
        if let provider = providers[typeName] {
            do { return try provider.tryServiceBinding(params: Optional<Any>.none as Any) }
            catch { throw convertError(error) }
        } else {
            throw ServiceLocatorError.serviceNotFound
        }
    }
    
    /// Get Service with params with detail information throwed error.
    open func tryService<ServiceType: ServiceSupportFactoryParams>(params: ServiceType.ParamsType) throws -> ServiceType {
        lock.lock()
        defer { lock.unlock() }
        
        let typeName = "\(ServiceType.self)"
        
        if let provider = providers[typeName] {
            do { return try provider.tryServiceBinding(params: params) }
            catch { throw convertError(error) }
        } else {
            throw ServiceLocatorError.serviceNotFound
        }
    }
    
    /// Get Service if there are no errors.
    open func getService<ServiceType>() -> ServiceType? {
        return try? tryService()
    }
    
    /// Get Service with params if there are no errors
    open func getService<ServiceType: ServiceSupportFactoryParams>(params: ServiceType.ParamsType) -> ServiceType? {
        return try? tryService(params: params)
    }
    
    /// Get ServiceProvider with service
    open func getServiceProvider<ServiceType>() -> ServiceProvider<ServiceType>? {
        lock.lock()
        defer { lock.unlock() }
        
        let typeName = "\(ServiceType.self)"
        return providers[typeName] as? ServiceProvider<ServiceType>
    }
    
    /// Get ServiceParamsProvider with service
    open func getServiceProvider<ServiceType, ParamsType>() -> ServiceParamsProvider<ServiceType, ParamsType>? {
        lock.lock()
        defer { lock.unlock() }
        
        let typeName = "\(ServiceType.self)"
        return providers[typeName] as? ServiceParamsProvider<ServiceType, ParamsType>
    }
    
    
    
    //MARK: - ServiceLocatorObjC support
    static func tryServiceObjC(typeName: String, params: Any) throws -> NSObject {
        guard let shared = shared else {
            throw ServiceLocatorError.sharedRequireSetup
        }
        
        return try shared.tryServiceObjC(typeName: typeName, params: params)
    }
    
    func tryServiceObjC(typeName: String, params: Any) throws -> NSObject {
        lock.lock()
        defer { lock.unlock() }
        
        //Find for standart name
        if let provider = providers[typeName] {
            do { return try provider.tryServiceBinding(params: params) }
            catch { throw convertError(error) }
        }
        
        //FIndo without bundle name (Bundle.ServiceName - remove Bundle.)
        if let pointIndex = typeName.index(of: ".") {
            let typeNameWithoutBundle = String(typeName[typeName.index(after: pointIndex)..<typeName.endIndex])
            
            if let provider = providers[typeNameWithoutBundle] {
                do { return try provider.tryServiceBinding(params: params) }
                catch { throw convertError(error) }
            }
        }
        
        throw ServiceLocatorError.serviceNotFound
    }
    
    //MARK: - Private
    
    /// Convert errors from ServiceProviderError to ServiceLocatorError
    private func convertError(_ error: Error) -> Error {
        if let error = error as? ServiceProviderError {
            switch error {
            case .wrongService: return ServiceLocatorError.serviceNotFound
            case .wrongParams: return ServiceLocatorError.wrongParams
            }
        } else {
            return error
        }
    }
}


//MARK: Provider binding to ServiceLocator

/// Base protocol for ServiceProvider<T>
private protocol ServiceLocatorProviderBinding {
    func tryServiceBinding<ServiceType>(params: Any) throws -> ServiceType
}

extension ServiceProvider: ServiceLocatorProviderBinding {
    fileprivate func tryServiceBinding<ServiceType>(params: Any) throws -> ServiceType {
        if let service = try tryService() as? ServiceType {
            return service
        } else {
            throw ServiceLocatorError.serviceNotFound
        }
    }
}

extension ServiceParamsProvider: ServiceLocatorProviderBinding {
    fileprivate func tryServiceBinding<ServiceType>(params: Any) throws -> ServiceType {
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
