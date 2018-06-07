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
    case sharedRequireSetup
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
    public static func tryServiceFromShared<T>(params: Any = Void()) throws -> T {
        guard let shared = shared else {
            throw ServiceLocatorError.sharedRequireSetup
        }
        
        return try shared.tryService(params: params)
    }
    
    public static func getServiceFromShared<T>(params: Any = Void()) -> T? {
        guard let shared = shared else { return nil }
        return try? shared.tryService(params: params)
    }
    
    
    open func tryService<T>(params: Any = Void()) throws -> T {
        lock.lock()
        defer { lock.unlock() }
        
        let typeName = "\(T.self)"
        
        if let provider = providers[typeName] {
            return try provider.tryServiceBinding(params: params)
        } else {
            throw ServiceLocatorError.serviceNotFound
        }
    }
    
    open func getService<T>(params: Any = Void()) -> T? {
        return try? tryService(params: params)
    }
    
    open func getServiceProvider<T>() -> ServiceProvider<T>? {
        lock.lock()
        defer { lock.unlock() }
        
        let typeName = "\(T.self)"
        return providers[typeName] as? ServiceProvider<T>
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
    
    open func addService<T>(provider: ServiceProvider<T>) {
        lock.lock()
        defer { lock.unlock() }
        
        if readOnly { fatalError("Don't support addService in readOnly regime") }
        
        let typeName = "\(T.self)"
        providers[typeName] = provider
    }
    
    open func addService<T>(_ service: T) {
        addService(provider: ServiceProvider<T>(service))
    }
    
    open func addService<T, FactoryType: ServiceFactory>(factory: FactoryType) where FactoryType.ServiceType == T {
        addService(provider: ServiceProvider<T>(factory: factory))
    }
    
    open func addService<T>(lazy: @escaping () throws ->T) {
        addService(provider: ServiceProvider<T>(lazy: lazy))
    }
    
    open func addService<T>(factory closure: @escaping () throws -> T) {
        addService(provider: ServiceProvider<T>.init(factory: closure))
    }
    
    open func removeService<T>(serviceType: T.Type) {
        lock.lock()
        defer { lock.unlock() }
        
        if readOnly { fatalError("Don't support removeService in readOnly regime") }
        
        providers.removeValue(forKey: "\(T.self)")
    }
    
    open func clone<T: ServiceLocator>(type: T.Type = T.self) -> T {
        let locator = T.init()
        
        lock.lock()
        locator.providers = self.providers
        lock.unlock()
        
        return locator
    }
}


//MARK: - Provider binding to Locator

/// Base protocol for ServiceProvider<T>
private protocol ServiceLocatorProviderBinding {
    func tryServiceBinding<T>(params: Any) throws -> T
}

extension ServiceProvider: ServiceLocatorProviderBinding {
    fileprivate func tryServiceBinding<BT>(params: Any) throws -> BT {
        if let service = try tryService() as? BT {
            return service
        } else {
            throw ServiceLocatorError.serviceNotFound
        }
    }
}

