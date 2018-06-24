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
    case serviceNotFound
    case wrongParams
    case sharedRequireSetup
}

public protocol ServiceSupportFactoryParams {
    associatedtype ParamsType
}



/// ServiceLocator as storage ServiceProviders.
open class ServiceLocator {
    public private(set) static var shared: ServiceLocator?
    public private(set) static var readOnlyShared: Bool = false
    
    public required init() { }
    
    ///Use for all public methods
    public let lock = NSRecursiveLock()
    public private(set) var readOnly: Bool = false
    
    private var providers = [String : ServiceLocatorProviderBinding]()
    
    
    //MARK: Get
    public static func tryServiceFromShared<ServiceType>() throws -> ServiceType {
        guard let shared = shared else {
            throw ServiceLocatorError.sharedRequireSetup
        }
        
        return try shared.tryService()
    }
    
    public static func tryServiceFromShared<ServiceType: ServiceSupportFactoryParams>(params: ServiceType.ParamsType) throws -> ServiceType {
        guard let shared = shared else {
            throw ServiceLocatorError.sharedRequireSetup
        }
        
        return try shared.tryService(params: params)
    }
    
    public static func getServiceFromShared<ServiceType>() -> ServiceType? {
        guard let shared = shared else { return nil }
        return try? shared.tryService()
    }
    
    public static func getServiceFromShared<ServiceType: ServiceSupportFactoryParams>(params: ServiceType.ParamsType) -> ServiceType? {
        guard let shared = shared else { return nil }
        return try? shared.tryService(params: params)
    }
    
    
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
    
    open func getService<ServiceType>() -> ServiceType? {
        return try? tryService()
    }
    
    open func getService<ServiceType: ServiceSupportFactoryParams>(params: ServiceType.ParamsType) -> ServiceType? {
        return try? tryService(params: params)
    }
    
    open func getServiceProvider<ServiceType>() -> ServiceProvider<ServiceType>? {
        lock.lock()
        defer { lock.unlock() }
        
        let typeName = "\(ServiceType.self)"
        return providers[typeName] as? ServiceProvider<ServiceType>
    }
    
    open func getServiceProvider<ServiceType, ParamsType>() -> ServiceParamsProvider<ServiceType, ParamsType>? {
        lock.lock()
        defer { lock.unlock() }
        
        let typeName = "\(ServiceType.self)"
        return providers[typeName] as? ServiceParamsProvider<ServiceType, ParamsType>
    }
    
    
    //MARK: Setup
    public static func setupShared(serviceLocator: ServiceLocator, readOnlySharedAfter: Bool = true) {
        if readOnlyShared { fatalError("Don't support setupShared in readOnly regime") }
        
        shared = serviceLocator
        readOnlyShared = readOnlySharedAfter
    }
    
    open func setReadOnly() {
        lock.lock()
        readOnly = true
        lock.unlock()
    }
    
    open func addService<ServiceType>(provider: ServiceProvider<ServiceType>) {
        lock.lock()
        defer { lock.unlock() }
        
        if readOnly { fatalError("Don't support addService in readOnly regime") }
        
        let typeName = "\(ServiceType.self)"
        providers[typeName] = provider
    }
    
    open func addService<ServiceType, ParamsType>(provider: ServiceParamsProvider<ServiceType, ParamsType>) {
        lock.lock()
        defer { lock.unlock() }
        
        if readOnly { fatalError("Don't support addService in readOnly regime") }
        
        let typeName = "\(ServiceType.self)"
        providers[typeName] = provider
    }
    
    open func addService<ServiceType>(_ service: ServiceType) {
        addService(provider: ServiceProvider<ServiceType>(service))
    }
    
    open func addService<ServiceType, FactoryType: ServiceFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType {
        addService(provider: ServiceProvider<ServiceType>(factory: factory))
    }
    
    open func addService<ServiceType, ParamsType, FactoryType: ServiceParamsFactory>(factory: FactoryType) where FactoryType.ServiceType == ServiceType, FactoryType.ParamsType == ParamsType {
        addService(provider: ServiceParamsProvider<ServiceType, ParamsType>(factory: factory))
    }
    
    open func addService<ServiceType>(lazy: @escaping () throws -> ServiceType) {
        addService(provider: ServiceProvider<ServiceType>(lazy: lazy))
    }
    
    open func addService<ServiceType>(factory closure: @escaping () throws -> ServiceType) {
        addService(provider: ServiceProvider<ServiceType>.init(factory: closure))
    }
    
    open func removeService<ServiceType>(serviceType: ServiceType.Type) {
        lock.lock()
        defer { lock.unlock() }
        
        if readOnly { fatalError("Don't support removeService in readOnly regime") }
        
        providers.removeValue(forKey: "\(ServiceType.self)")
    }
    
    open func clone<T: ServiceLocator>(type: T.Type = T.self) -> T {
        let locator = T.init()
        
        lock.lock()
        locator.providers = self.providers
        lock.unlock()
        
        return locator
    }
    
    //MARK: PVServiceLocator ObjC support
    static func tryServiceObjC(typeName: String, params: Any) throws -> NSObject {
        guard let shared = shared else {
            throw ServiceLocatorError.sharedRequireSetup
        }
        
        return try shared.tryServiceObjC(typeName: typeName, params: params)
    }
    
    func tryServiceObjC(typeName: String, params: Any) throws -> NSObject {
        lock.lock()
        defer { lock.unlock() }
        
        if let provider = providers[typeName] {
            do { return try provider.tryServiceBinding(params: params) }
            catch { throw convertError(error) }
        } else {
            throw ServiceLocatorError.serviceNotFound
        }
    }
    
    //MARK: - Private
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


//MARK: Provider binding to Locator

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
