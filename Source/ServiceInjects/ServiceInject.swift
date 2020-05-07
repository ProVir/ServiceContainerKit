//
//  ServiceInject.swift
//  ServiceContainerKit
//
//  Created by Короткий Виталий on 06.05.2020.
//  Copyright © 2020 ProVir. All rights reserved.
//

import Foundation

private var serviceLocatorShared: ServiceLocator?

public extension ServiceLocator {
    func setupForInject() {
        serviceLocatorShared = self
    }
}

@propertyWrapper
public final class ServiceInject<ServiceType> {
    private var factory: (() -> ServiceType)?
    private var service: ServiceType?
    
    public init<Key: ServiceLocatorKey>(_ key: Key, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) where Key.ServiceType == ServiceType {
        guard let locator = serviceLocatorShared else {
            fatalError("Not found ServiceLocator for Inject", file: file, line: line)
        }
        
        if lazy {
            self.factory = { locator.getServiceOrFatal(key: key, file: file, line: line) }
        } else {
            self.service = locator.getServiceOrFatal(key: key, file: file, line: line)
        }
    }
    
    public init<Key: ServiceLocatorParamsKey>(_ key: Key, params: Key.ParamsType, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) where Key.ServiceType == ServiceType {
        guard let locator = serviceLocatorShared else {
            fatalError("Not found ServiceLocator for Inject", file: file, line: line)
        }
        
        if lazy {
            self.factory = { locator.getServiceOrFatal(key: key, params: params, file: file, line: line) }
        } else {
            self.service = locator.getServiceOrFatal(key: key, params: params, file: file, line: line)
        }
    }
    
    public var wrappedValue: ServiceType {
        if let service = self.service {
            return service
        } else if let service = factory?() {
            self.service = service
            self.factory = nil
            return service
        } else {
            fatalError("Unknown error in Inject")
        }
    }
}

@propertyWrapper
public final class ServiceOptionalInject<ServiceType> {
    private var factory: (() -> ServiceType?)?
    private var service: ServiceType?
    
    public init<Key: ServiceLocatorKey>(_ key: Key, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) where Key.ServiceType == ServiceType {
        guard let locator = serviceLocatorShared else {
            fatalError("Not found ServiceLocator for Inject", file: file, line: line)
        }
        
        if lazy {
            self.factory = { locator.getServiceAsOptional(key: key) }
        } else {
            self.service = locator.getServiceAsOptional(key: key)
        }
    }
    
    public init<Key: ServiceLocatorParamsKey>(_ key: Key, params: Key.ParamsType, lazy: Bool = false, file: StaticString = #file, line: UInt = #line) where Key.ServiceType == ServiceType {
        guard let locator = serviceLocatorShared else {
            fatalError("Not found ServiceLocator for Inject", file: file, line: line)
        }
        
        if lazy {
            self.factory = { locator.getServiceAsOptional(key: key, params: params) }
        } else {
            self.service = locator.getServiceAsOptional(key: key, params: params)
        }
    }
    
    public var wrappedValue: ServiceType? {
        if let service = self.service {
            return service
        } else if let service = factory?() {
            self.service = service
            self.factory = nil
            return service
        } else {
            return nil
        }
    }
}
